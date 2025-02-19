//
//  Router.swift
//  Kontest
//
//  Created by Ayush Singhal on 25/08/23.
//

import Foundation
import OSLog

enum SelectionState: Hashable {
    case screen(Screen)
    case kontestModel(KontestModel)
}

@Observable
final class Router: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "Router")

    var path = [SelectionState]() {
        didSet {
            currentSelectionState = path.last ?? .screen(.AllKontestScreen)
            logger.info("path: \(self.path)")
            logger.info("currentSelectionState: \("\(self.currentSelectionState)")")
        }
    }

    var currentSelectionState: SelectionState = .screen(.AllKontestScreen)
    private init() {}

    func appendScreen(screen: Screen) {
        if path.contains(.screen(.SettingsScreen)) || path.contains(.screen(.SettingsScreenType(.ChangeUserNamesScreen))) || path.contains(.screen(.SettingsScreenType(.FilterWebsitesScreen))), screen == .SettingsScreen {
        } else {
            path.append(SelectionState.screen(screen))
        }
    }

    func popLastScreen() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func goToRootView() {
        path.removeAll()
    }

    #if os(iOS)
        func openKontestScreen(kontestModel: KontestModel) {
            path.append(.kontestModel(kontestModel))
        }
    #endif

    static let instance: Router = .init()
}
