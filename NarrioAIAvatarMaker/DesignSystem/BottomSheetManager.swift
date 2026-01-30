//
//  BottomSheetManager.swift
//  NarrioAIAvatarMaker
//
//  Created by b on 29.01.2026.
//

import SwiftUI
internal import Combine

final class BottomSheetManager: ObservableObject {
    @Published var type: ProjectDetailView.BottomSheetType?

    func show(_ type: ProjectDetailView.BottomSheetType) {
        self.type = type
    }

    func hide() {
        type = nil
    }
}
