//
//  AvatarsViewModel.swift
//  SynthesiaAI
//

import SwiftUI
internal import Combine

@MainActor
class AvatarsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showCreateAvatar = false
    @Published var searchText = ""
    @Published var selectedGenderFilter: Gender?
    @Published var selectedStyleFilter: AvatarStyle = .all
    @Published var showOnlyCustom = false
    @Published var createVideoVM = CreateVideoViewModel()
    
    // MARK: - Filter Methods
    func filteredAvatars(from appState: AppState) -> [Avatar] {
        var avatars: [Avatar]
        
        if showOnlyCustom {
            avatars = appState.customAvatars
        } else {
            avatars = appState.allAvatars
        }
        
        if !searchText.isEmpty {
            avatars = avatars.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let genderFilter = selectedGenderFilter {
            avatars = avatars.filter { $0.gender == genderFilter }
        }
        
        if selectedStyleFilter != .all {
            avatars = avatars.filter { $0.style == selectedStyleFilter }
        }
        
        return avatars
    }
    
    // MARK: - Actions
    func refreshAvatars(appState: AppState) async {
        await appState.fetchPresetAvatars()
    }
    
    func loadInitialData(appState: AppState) async {
        if appState.presetAvatars.isEmpty {
            await appState.fetchPresetAvatars()
        }
    }
    
    func resetFilters() {
        searchText = ""
        selectedGenderFilter = nil
        selectedStyleFilter = .all
        showOnlyCustom = false
    }
    
    func selectAllAvatars() {
        showOnlyCustom = false
        selectedGenderFilter = nil
    }
    
    func selectCustomAvatars() {
        showOnlyCustom = true
    }
    
    func selectGender(_ gender: Gender) {
        showOnlyCustom = false
        selectedGenderFilter = gender
    }
}
