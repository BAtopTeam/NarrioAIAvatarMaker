//
//  CreateAvatarViewModel.swift
//  SynthesiaAI
//

import SwiftUI
import PhotosUI
internal import Combine

// MARK: - Create Avatar Step
enum CreateAvatarStep: Int {
    case gender = 0
    case photos = 1
    case processing = 2
    case complete = 3
}

// MARK: - Avatar Creation Mode
enum AvatarCreationMode {
    case photo
    case aiPrompt
}

@MainActor
class CreateAvatarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStep: CreateAvatarStep = .gender
    @Published var selectedGender: Gender = .female
    @Published var selectedPhotos: [String] = []
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0
    @Published var avatarCreated = false
    @Published var avatarName = ""
    @Published var showNameInput = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var createdAvatar: Avatar?
    
    // AI Prompt mode
    @Published var creationMode: AvatarCreationMode = .photo
    @Published var aiPrompt = ""
    
    // MARK: - Computed Properties
    var canProceedToProcessing: Bool {
        if creationMode == .photo {
            return selectedImageData != nil || !selectedPhotos.isEmpty
        } else {
            return !aiPrompt.isEmpty
        }
    }
    
    var promptSuggestions: [String] {
        let genderText = selectedGender == .male ? "man" : "woman"
        return [
            "Portrait of a young professional \(genderText). Confident. Business attire.",
            "Friendly \(genderText) in casual clothing. Warm smile. Natural lighting.",
            "Corporate \(genderText) with glasses. Professional headshot style.",
            "Creative \(genderText). Artistic. Modern fashion. Studio lighting."
        ]
    }
    
    // MARK: - Navigation
    func handleBack(dismiss: DismissAction) {
        switch currentStep {
        case .gender:
            dismiss()
        case .photos:
            currentStep = .gender
        case .processing:
            break
        case .complete:
            dismiss()
        }
    }
    
    // MARK: - Photo Management
    func handlePhotoSelection(_ newItem: PhotosPickerItem?) async {
        if let data = try? await newItem?.loadTransferable(type: Data.self) {
            await MainActor.run {
                selectedImageData = data
                if !selectedPhotos.contains("real_photo") {
                    selectedPhotos.append("real_photo")
                }
            }
        }
    }
    
    func removePhoto() {
        selectedImageData = nil
        selectedPhotoItem = nil
        selectedPhotos.removeAll { $0 == "real_photo" }
    }
    
    func addMockPhotos() {
        for i in 1...6 {
            if selectedPhotos.count < 10 {
                selectedPhotos.append("photo_\(i)")
            }
        }
    }
    
    // MARK: - Processing
    func startProcessing(appState: AppState) {
        currentStep = .processing
        
        if selectedImageData != nil {
            simulatePhotoProcessing()
        } else {
            simulateProcessing()
        }
    }
    
    private func startProgressAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.processingProgress >= 0.9 || self.currentStep == .complete {
                timer.invalidate()
            } else {
                let increment = (0.9 - self.processingProgress) * 0.02
                self.processingProgress += max(increment, 0.005)
            }
        }
    }
    
    private func simulatePhotoProcessing() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.processingProgress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let newAvatar = Avatar(
                        id: UUID(),
                        name: self.avatarName.isEmpty ? "Custom Avatar" : self.avatarName,
                        imageURL: "",
                        thumbnailURL: "",
                        gender: self.selectedGender,
                        style: .casual,
                        isCustom: true,
                        createdAt: Date(),
                        heygenAvatarId: nil,
                        localImageData: self.selectedImageData
                    )
                    self.createdAvatar = newAvatar
                    self.currentStep = .complete
                }
            } else {
                self.processingProgress += 0.02
            }
        }
    }
    
    private func simulateProcessing() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.processingProgress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.currentStep = .complete
                }
            } else {
                self.processingProgress += 0.02
            }
        }
    }
    
    // MARK: - Save Avatar
    @MainActor
    func saveAvatar(appState: AppState, dismiss: DismissAction) {
        guard let avatar = createdAvatar else {
            errorMessage = "Avatar was not created"
            showError = true
            return
        }

        var savedAvatar = avatar
        savedAvatar.name = avatarName.isEmpty ? avatar.name : avatarName

        appState.addCustomAvatar(savedAvatar)

        print("✅ Avatar saved locally:", savedAvatar.name)

        dismiss()
    }
    
    // MARK: - Reset
    func resetFlow() {
        currentStep = .gender
        selectedPhotos = []
        selectedImageData = nil
        selectedPhotoItem = nil
        processingProgress = 0
        avatarName = ""
        aiPrompt = ""
        createdAvatar = nil
        errorMessage = nil
        showError = false
    }
}
