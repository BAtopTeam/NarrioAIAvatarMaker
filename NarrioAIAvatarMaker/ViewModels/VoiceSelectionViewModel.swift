//
//  VoiceSelectionViewModel.swift
//  SynthesiaAI
//

import SwiftUI
import AVFoundation
internal import Combine

@MainActor
class VoiceSelectionViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var selectedLanguageFilter: String?
    @Published var isPlayingPreview = false
    @Published var currentlyPlayingVoiceId: String?
    private var player: AVPlayer?

    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Computed Filters
    func filteredVoices(from appState: AppState) -> [Voice] {
        var voices = appState.allVoices
        
        if !searchText.isEmpty {
            voices = voices.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.accent.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let languageFilter = selectedLanguageFilter {
            voices = voices.filter {
                $0.accent.localizedCaseInsensitiveContains(languageFilter) ||
                ($0.languageCode?.localizedCaseInsensitiveContains(languageFilter) ?? false)
            }
        }
        
        return voices
    }
    
    func availableLanguages(from appState: AppState) -> [String] {
        let languages = Set(appState.allVoices.map { $0.accent })
        return Array(languages).sorted()
    }
    
    // MARK: - Actions
    func refreshVoices(appState: AppState) async {
        await appState.fetchVoices()
    }
    
    func loadInitialData(appState: AppState) async {
        if appState.allVoices.isEmpty || appState.apiVoices.isEmpty {
            await appState.fetchVoices()
        }
    }
    
    func resetFilters() {
        searchText = ""
        selectedLanguageFilter = nil
    }
    
    func togglePlayback(for voice: Voice) {
        if currentlyPlayingVoiceId == voice.id {
            player?.pause()
            currentlyPlayingVoiceId = nil
            isPlayingPreview = false
            return
        }

        player?.pause()
        player = nil
        currentlyPlayingVoiceId = nil
        isPlayingPreview = false

        guard
            let preview = voice.previewURL,
            !preview.isEmpty,
            let url = URL(string: preview)
        else {
            print("❌ No preview audio")
            return
        }

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            currentlyPlayingVoiceId = nil
            isPlayingPreview = false
        }

        newPlayer.play()
        currentlyPlayingVoiceId = voice.id
        isPlayingPreview = true
    }

    func stopPlayback() {
        player?.pause()
        player = nil
        currentlyPlayingVoiceId = nil
        isPlayingPreview = false
    }
}

extension VoiceSelectionViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentlyPlayingVoiceId = nil
        isPlayingPreview = false
    }
}
