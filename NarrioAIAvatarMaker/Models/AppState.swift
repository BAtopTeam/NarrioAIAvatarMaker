//
//  AppState.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI
internal import Combine
import AppTrackingTransparency
import ApphudSDK
import AdSupport
import StoreKit

@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties
    @Published var hasCompletedOnboarding: Bool = false
    @Published var generationsCount: Int = 0
    @Published var currentUser: User = .mock
    @Published var selectedTab: TabItem = .home
    @Published var isShowingVideoGeneration = false
    @Published var isShowingPaywall = false
    @Published var selectedAvatar: Avatar? = nil
    @Published var showRatingView = false
    @Published var templates: [VideoTemplate] = []
    
    private var didShowRatingThisSession = false
    
    // MARK: - Avatars
    @Published var customAvatars: [Avatar] = []
    @Published var presetAvatars: [Avatar] = []
    
    // MARK: - Voices
    @Published var apiVoices: [Voice] = []
    
    // MARK: - Projects
    @Published var projects: [Project] = []
    @Published var recentVideos: [Project] = []
    
    // MARK: - Video Creation
    @Published var createVideoState = CreateVideoState()
    @Published var isCreatingVideo = false
    @Published var videoGenerationProgress = VideoGenerationProgress()
    var videoGenerationManager: VideoGenerationManager?
    
    var totalVideosCount: Int {
        projects.count
    }
    
    var videosCreatedThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return 0
        }
        
        return projects.filter { project in
            project.createdAt >= startOfWeek
        }.count
    }
    
    // MARK: - API State
    @Published var isLoadingAvatars = false
    @Published var isLoadingVoices = false
    @Published var apiError: String?
    @Published var currentTaskId: String?
    @Published var currentTaskStatus: TaskStatus?
    
    // MARK: - Settings
    @Published var defaultVoice: Voice?
    @Published var defaultLanguage: Language = Language.languages[0]
    @Published var notificationsEnabled: Bool = true
    
    // MARK: - API Service
    private let apiService = APIService.shared
    
    // MARK: - Computed Properties
    var allAvatars: [Avatar] {
        customAvatars + presetAvatars
    }
    
    var allVoices: [Voice] {
        apiVoices
    }
    
    var videosThisWeek: Int {
        projects.filter { $0.createdAt > Date().addingTimeInterval(-7 * 86400) }.count
    }
    
    // MARK: - Initialization
    init(currentUser: User) {
        self.currentUser = currentUser
        loadLocalData()
        Task {
            await loadInitialData()
            await makePresets()
        }
    }
    
    func tryShowRatingIfNeeded() {
        guard !didShowRatingThisSession else { return }

        didShowRatingThisSession = true
        showRatingView = true
    }
    
    @MainActor
    func makePresets() async {
        guard !presetAvatars.isEmpty, !apiVoices.isEmpty else {
            print("⚠️ Avatars or voices are empty")
            templates = []
            return
        }

        let baseTemplates = VideoTemplateBase.templates

        var result: [VideoTemplate] = []

        for (index, base) in baseTemplates.enumerated() {
            let avatar = presetAvatars[index % presetAvatars.count]

            let voice = apiVoices[index % apiVoices.count]

            let template = VideoTemplate(
                id: base.id,
                title: base.title,
                category: base.category,
                duration: base.duration,
                thumbnailURL: base.thumbnailURL,
                script: base.script,
                avatar: avatar,
                voice: voice,
                background: base.background
            )

            result.append(template)
        }

        templates = result
    }

    
    @MainActor
    func setup(videoGenerationManager: VideoGenerationManager) {
        self.videoGenerationManager = videoGenerationManager
        restoreActiveGenerations()
    }
    
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchPresetAvatars() }
            group.addTask { await self.fetchVoices() }
        }
    }
    
    private func loadLocalData() {
        if let savedProjects = LocalStorage.shared.load([Project].self, key: StorageKeys.projects) {
            self.projects = savedProjects
            self.recentVideos = Array(savedProjects.prefix(3))
        }

        if let savedAvatars = LocalStorage.shared.load([Avatar].self, key: StorageKeys.customAvatars) {
            self.customAvatars = savedAvatars
        }

        self.hasCompletedOnboarding =
            UserDefaults.standard.bool(forKey: StorageKeys.hasCompletedOnboarding)
        self.generationsCount =
            UserDefaults.standard.integer(forKey: StorageKeys.generationCount)
    }
    
    private func persistProjects() {
        LocalStorage.shared.save(projects, key: StorageKeys.projects)
    }
    
    // MARK: - Fetch Avatars
    func fetchPresetAvatars() async {
        isLoadingAvatars = true
        apiError = nil
        do {
            let avatars = try await apiService.getAllAvatarPresets()
            self.presetAvatars = avatars.map { Avatar.fromHeyGen($0) }
        } catch {
            apiError = error.localizedDescription
            print("[AppState] Failed to fetch avatars: \(error)")
        }
        isLoadingAvatars = false
    }
    
    // MARK: - Fetch Voices
    func fetchVoices() async {
        isLoadingVoices = true
        apiError = nil
        do {
            let voices = try await apiService.getAllVoices()
            self.apiVoices = voices.filter { $0.previewAudio != nil && !($0.previewAudio?.isEmpty ?? false) }.map { Voice.fromHeyGen($0) }
        } catch {
            apiError = error.localizedDescription
            print("[AppState] Failed to fetch voices: \(error)")
        }
        isLoadingVoices = false
    }
    
    // MARK: - Video Generation
    func createVideoFromPreset(
        avatar: Avatar,
        voice: Voice,
        script: String,
        background: Background? = nil,
        dimensions: VideoDimensions = .landscape
    ) async throws -> String {
        guard let avatarId = avatar.heygenAvatarId else {
            throw APIError.serverError("Avatar does not have a HeyGen ID")
        }
        
        let backgroundColor = background?.colors.first.map { colorToHex($0) }
        
        let request = VideoFromPresetsRequest(
            width: dimensions.width,
            height: dimensions.height,
            avatarId: avatarId,
            voiceId: voice.heygenVoiceId,
            inputText: script,
            audioFile: nil,
            audioFileName: nil,
            speed: 1.0,
            pitch: 0,
            emotion: .friendly,
            locale: voice.languageCode,
            backgroundColor: backgroundColor,
            backgroundImage: nil,
            backgroundImageName: nil
        )
        
        let taskId = try await apiService.createVideoFromPreset(request: request)
        currentTaskId = taskId
        return taskId
    }
    
    func createVideoFromImage(
        imageData: Data,
        imageName: String,
        voice: Voice,
        script: String,
        background: Background? = nil,
        dimensions: VideoDimensions = .landscape
    ) async throws -> String {
        let backgroundColor = background?.colors.first.map { colorToHex($0) }
        
        let request = VideoFromImagesRequest(
            width: dimensions.width,
            height: dimensions.height,
            avatarImage: imageData,
            avatarImageName: imageName,
            voiceId: voice.heygenVoiceId,
            inputText: script,
            audioFile: nil,
            audioFileName: nil,
            speed: 1.0,
            pitch: 0,
            emotion: .friendly,
            locale: voice.languageCode,
            backgroundColor: backgroundColor,
            backgroundImage: nil,
            backgroundImageName: nil
        )
        
        let taskId = try await apiService.createVideoFromImage(request: request)
        currentTaskId = taskId
        return taskId
    }
    
    // MARK: - Task Helpers
    func pollTaskStatus(taskId: String) async throws -> TaskStatusResponse {
        try await apiService.getTaskStatus(taskId: taskId)
    }
    
    func waitForTaskCompletion(taskId: String, progressHandler: ((TaskStatusResponse) -> Void)? = nil) async throws -> TaskStatusResponse {
        try await apiService.waitForTaskCompletion(taskId: taskId, progressHandler: progressHandler)
    }
    
    func downloadTaskResult(taskId: String) async throws -> Data {
        try await apiService.getTaskResult(taskId: taskId)
    }
    
    func restoreActiveGenerations() {
        let savedInstances = LocalStorage.shared.load([SavedTask].self, key: "activeTasks") ?? []

        for saved in savedInstances {
            let state = CreateVideoState(
                script: "",
                selectedAvatar: nil,
                selectedVoice: nil,
                selectedBackground: nil,
                currentProjectId: saved.projectId
            )
            
            let instance = VideoGenerationInstance(state: state, appState: self)
        
            videoGenerationManager?.activeGenerations.append(instance)
            instance.startPolling(taskId: saved.taskId)
        }
    }
    
    func removeSavedTask(currentProjectId: UUID?) {
        guard let projectId = currentProjectId else { return }
        var savedTasks = LocalStorage.shared.load([SavedTask].self, key: "activeTasks") ?? []
        savedTasks.removeAll { $0.projectId == projectId }
        LocalStorage.shared.save(savedTasks, key: "activeTasks")
    }
    
    // MARK: - Helpers
    private func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            isShowingPaywall = true
        }
        UserDefaults.standard.set(true, forKey: StorageKeys.hasCompletedOnboarding)
    }
    
    func incrementGenerationCount() {
        generationsCount += 1
        UserDefaults.standard.set(generationsCount, forKey: StorageKeys.generationCount)
    }

    func fetchTaskResult(taskId: String) async throws -> VideoResultData {
        let data = try await downloadTaskResult(taskId: taskId)
        let decoded = try JSONDecoder().decode(TaskResultResponse.self, from: data)
        return decoded.result.data
    }
    
    func createProject(
        from state: CreateVideoState,
        taskId: String?,
        videoResult: VideoResultData?
    ) -> Project {

        let project = Project(
            id: state.currentProjectId ?? UUID(),
            title: "New Video",
            thumbnailURL: state.selectedAvatar?.thumbnailURL ?? "",
            status: .inProgress,
            duration: videoResult?.duration ?? state.estimatedDuration,
            createdAt: Date(),
            language: state.language.name,
            avatarName: state.selectedAvatar?.name ?? "Unknown",
            voiceName: state.selectedVoice?.name ?? "Default",
            script: state.script,
            taskId: taskId,
            videoURL: videoResult?.video_url
        )

        projects.insert(project, at: 0)
        recentVideos = Array(projects.prefix(3))
        persistProjects()
        return project
    }
    
    func updateProjectStatus(
        _ projectId: UUID,
        status: ProjectStatus,
        videoURL: String? = nil,
        thumbnailURL: String? = nil,
        taskId: String?,
        duration: TimeInterval?
    ) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }

        var updatedProject = projects[index]
        updatedProject.status = status
        updatedProject.thumbnailURL = thumbnailURL ?? updatedProject.thumbnailURL
        updatedProject.taskId = taskId
        updatedProject.duration = duration ?? updatedProject.duration

        if let url = videoURL {
            updatedProject.videoURL = url
        }

        projects[index] = updatedProject
        removeSavedTask(currentProjectId: projectId)
        recentVideos = Array(projects.prefix(3))
        persistProjects()
    }

    func renameProject(projectId: UUID, newName: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].title = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        persistProjects()
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        recentVideos = Array(projects.prefix(3))
        persistProjects()
    }
    
    // MARK: - Avatars Helpers
    func addCustomAvatar(_ avatar: Avatar) {
        customAvatars.insert(avatar, at: 0)
        LocalStorage.shared.save(customAvatars, key: StorageKeys.customAvatars)
    }
    
    func resetCreateVideoState() {
        createVideoState = CreateVideoState()
    }
}

// MARK: - Tab Items
enum TabItem: String, CaseIterable {
    case home = "Home"
    case avatars = "Avatars"
    case projects = "Projects"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .avatars: return "person.2"
        case .projects: return "rectangle.stack"
        case .profile: return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .avatars: return "person.2.fill"
        case .projects: return "rectangle.stack.fill"
        case .profile: return "gearshape.fill"
        }
    }
}

final class LocalStorage {
    static let shared = LocalStorage()
    private let defaults = UserDefaults.standard

    private init() {}

    func save<T: Codable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func load<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func clear(key: String) {
        defaults.removeObject(forKey: key)
    }
}

private enum StorageKeys {
    static let projects = "projects"
    static let customAvatars = "customAvatars"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let generationCount = "generationCount"
}

@MainActor
extension AppState {
    func clearAllData() {
        // MARK: - Reset Published Properties
        hasCompletedOnboarding = false
        currentUser = .mock
        selectedTab = .home
        isShowingVideoGeneration = false
        
        customAvatars = []
        presetAvatars = []
        
        apiVoices = []
        
        projects = []
        recentVideos = []
        
        createVideoState = CreateVideoState()
        isCreatingVideo = false
        videoGenerationProgress = VideoGenerationProgress()
        
        isLoadingAvatars = false
        isLoadingVoices = false
        apiError = nil
        currentTaskId = nil
        currentTaskStatus = nil
        
        notificationsEnabled = true
        
        // MARK: - Clear Local Storage
        LocalStorage.shared.clear(key: StorageKeys.projects)
        LocalStorage.shared.clear(key: StorageKeys.customAvatars)
        UserDefaults.standard.removeObject(forKey: StorageKeys.hasCompletedOnboarding)
        
        // MARK: - Optionally cancel ongoing tasks
        currentTaskId = nil
        currentTaskStatus = nil
    }
    
    func requestIDFAPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                        print("IDFA access granted:", ASIdentifierManager.shared().advertisingIdentifier)
                    case .denied:
                        print("IDFA denied")
                    case .notDetermined:
                        print("IDFA not determined")
                    case .restricted:
                        print("IDFA restricted")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
    
    func requestRating() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
