//
//  ProjectDetailView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI
import _AVKit_SwiftUI
import UniformTypeIdentifiers

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    let project: Project
    
    @State private var showVideoPlayer = false
    @State private var showExportOptions = false
    @State private var showDeleteConfirmation = false
    @State private var showRenameInput = false
    @State private var showRateApp = false
    @State private var newProjectName: String = ""
    
    // MARK: - Bottom Sheet
    @State private var bottomSheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var bottomSheetType: BottomSheetType?
    @State private var showBottomSheetType = false
    @GestureState private var dragOffset: CGFloat = 0
    
    enum BottomSheetType {
        
        case delete, export
    }
    
    private var currentProject: Project? {
        appState.projects.first(where: { $0.id == project.id })
    }
    
    @State private var exportedURL: URL?
    @State private var showFileExporter = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastColor: Color = .green
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    videoPreview
                    titleSection
                    actionButtons
                    detailsSection
                    scriptSection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showBottomSheetType, content: {
            bottomSheetOverlay
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
                .background(AppColors.cardBackground)
        })
        .background(AppColors.background)
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .fullScreenCover(isPresented: $showRateApp, content: {
            RateAppView()
        })
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if appState.showRatingView {
                    showRateApp = true
                    appState.showRatingView = false
                }
            }
        })
        .overlay(
            Group {
                if showRenameInput {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showRenameInput = false }
                    
                    VStack(spacing: 16) {
                        Text("Rename Project")
                            .font(AppTypography.headline)
                            .foregroundColor(.black)
                        
                        TextField("Project name", text: $newProjectName)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        
                        HStack(spacing: 16) {
                            Button(action: { showRenameInput = false }) {
                                Text("Cancel")
                                    .font(AppTypography.buttonMedium)
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(AppRadius.medium)
                            }
                            
                            Button(action: {
                                if !newProjectName.trimmingCharacters(in: .whitespaces).isEmpty {
                                    appState.renameProject(projectId: project.id, newName: newProjectName)
                                    showRenameInput = false
                                }
                            }) {
                                Text("Save")
                                    .font(AppTypography.buttonMedium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primary)
                                    .cornerRadius(AppRadius.medium)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1)
                }
            }
        )
        .animation(.easeInOut, value: showRenameInput)
        .fileExporter(
            isPresented: $showFileExporter,
            document: exportedURL.map { VideoDocument(url: $0) },
            contentType: .movie,
            defaultFilename: project.title
        ) { _ in }
        
        if showToast {
            VStack {
                Text(toastMessage)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(toastColor)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showToast)
                    .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private var bottomSheetOverlay: some View {
        if bottomSheetType != nil {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { hideBottomSheet() }
                .transition(.opacity)
                .zIndex(1)
            
            VStack {
                Spacer()
                bottomSheetContent
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                if value.translation.height > 0 {
                                    state = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    hideBottomSheet()
                                }
                            }
                    )
                    .frame(height: 300)
            }
            .animation(.easeOut(duration: 0.25), value: dragOffset)
            .transition(.move(edge: .bottom))
            .zIndex(2)
        }
    }
    
    private var bottomSheetContent: some View {
        VStack(spacing: 16) {
            switch bottomSheetType {
            case .delete:
                HStack {
                    Text("Edit")
                        .font(AppTypography.headline)
                    Spacer()
                }

                VStack {
                    Button {
                        newProjectName = project.title
                        showRenameInput = true
                        hideBottomSheet()
                    } label: {
                        HStack {
                            Image(.rename)
                                .padding(.vertical, 16)
                                .padding(.leading, 16)
                            Text("Rename")
                                .font(AppTypography.buttonMedium)
                                .foregroundColor(.black)
                                
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "EDEEFC").opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    Button {
                        appState.deleteProject(project)
                        hideBottomSheet()
                        dismiss()
                    } label: {
                        HStack {
                            Image(.delete)
                                .padding(.vertical, 16)
                                .padding(.leading, 16)
                            Text("Delete")
                                .font(AppTypography.buttonMedium)
                                .foregroundColor(AppColors.redText)
                                
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(AppColors.redText.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 8)

            case .export:
                HStack {
                    Text("Export Video")
                        .font(AppTypography.headline)
                    Spacer()
                }
                
                VStack {
                    Button {
                        downloadToGallery()
                        hideBottomSheet()
                    } label: {
                        HStack {
                            Image(.gallery)
                                .padding(.vertical, 16)
                                .padding(.leading, 16)
                            Text("Gallery")
                                .font(AppTypography.buttonMedium)
                                .foregroundColor(AppColors.textPrimary)
                                
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "E0E2FF"), lineWidth: 1)
                        )
                    }
                    
                    Button {
                        downloadToFiles()
                        hideBottomSheet()
                    } label: {
                        HStack {
                            Image(.cloud)
                                .padding(.vertical, 16)
                                .padding(.leading, 16)
                            Text("Files")
                                .font(AppTypography.buttonMedium)
                                .foregroundColor(AppColors.textPrimary)
                                
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "346AEA").opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "346AEA").opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 8)
            case .none:
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
    
    private func showBottomSheet(_ type: BottomSheetType) {
        bottomSheetType = type
        bottomSheetOffset = 0
        showBottomSheetType = true
    }

    private func hideBottomSheet() {
        withAnimation(.easeOut(duration: 0.25)) {
            bottomSheetType = nil
            showBottomSheetType = false
        }
    }
    
    // MARK: - Video Preview
    private var videoPreview: some View {
        ZStack {
            if let url = URL(string: project.thumbnailURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.black.opacity(0.2)
                }
                .frame(height: 220)
                .cornerRadius(AppRadius.large)
            }

            Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
        }
        .frame(height: 220)
        .onTapGesture {
            if project.videoURL != nil {
                showVideoPlayer = true
            }
        }
        .sheet(isPresented: $showVideoPlayer) {
            ProjectVideoView(project: project)
        }
    }

    // MARK: - Title
    private var titleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(currentProject?.title ?? project.title)
                    .font(AppTypography.body)
                Text("Created \(project.formattedDate)")
                    .font(AppTypography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            StatusBadge(status: project.status)
        }
    }
    
    private func showToastMessage(_ message: String, color: Color) {
        toastMessage = message
        toastColor = color
        withAnimation { showToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showToast = false }
        }
    }

    // MARK: - Actions
    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            ActionButton(
                icon: .download,
                title: "Download",
                isPrimary: true
            ) {
                showBottomSheet(.export)
            }
            
            ActionButton(
                icon: .share,
                title: "Share",
                isPrimary: false
            ) {
                shareVideo()
            }
            
            ActionButton(
                icon: .edit,
                title: "Edit",
                isPrimary: false
            ) {
                showBottomSheet(.delete)
            }
        }
    }

    // MARK: - Details
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Details")
                .font(AppTypography.headline)

            VStack(spacing: 10) {
                DetailRow(title: "Duration", value: project.formattedDuration)
                Divider()
                DetailRow(title: "Language", value: project.language)
                Divider()
                DetailRow(title: "Avatar", value: project.avatarName)
                Divider()
                DetailRow(title: "Voice", value: project.voiceName)
            }
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large)
                    .stroke(Color(hex: "E0E2FF"), lineWidth: 1)
            )
        }
    }

    // MARK: - Script
    private var scriptSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Script")
                .font(AppTypography.headline)

            Text(project.script)
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .cornerRadius(AppRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large)
                        .stroke(Color(hex: "E0E2FF"), lineWidth: 1)
                )
        }
    }

    // MARK: - Download / Share
    private func downloadToGallery() {
        guard let url = project.videoURL else { return }
        
        VideoDownloader.download(from: url, fileName: "\(project.title).mp4", target: .gallery) { successURL in
            if successURL != nil {
                showToastMessage("Video saved to gallery!", color: .green)
            } else {
                showToastMessage("Failed to save video.", color: .red)
            }
        }
    }

    private func downloadToFiles() {
        guard let url = project.videoURL else { return }

        VideoDownloader.download(from: url, fileName: "\(project.title).mp4", target: .files) {
            exportedURL = $0
            showFileExporter = $0 != nil
        }
    }

    private func shareVideo() {
        guard let urlString = project.videoURL,
              let url = URL(string: urlString) else { return }

        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(vc, animated: true)
    }
}

// MARK: - FileDocument
struct VideoDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.movie] }
    let url: URL

    init(url: URL) { self.url = url }
    init(configuration: ReadConfiguration) throws { fatalError() }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: url)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: ImageResource
    let title: String
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(icon)
        }
        .frame(maxWidth: .infinity)
    }
}


struct ProjectVideoView: View {
    let project: Project
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let urlString = project.videoURL,
               let url = URL(string: urlString) {

                VideoPlayer(player: player)
                    .onAppear {
                        if player == nil {
                            let player = AVPlayer(url: url)
                            self.player = player
                            player.play()
                        }
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
                    .ignoresSafeArea()

            } else {
                videoNotAvailableView
            }
        }
    }

    private var videoNotAvailableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "video.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("Video not available")
                .foregroundColor(.gray)
        }
    }
}
