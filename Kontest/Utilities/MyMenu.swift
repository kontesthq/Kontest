//
//  MyMenu.swift
//  Kontest
//
//  Created by Ayush Singhal on 01/09/23.
//

import SwiftUI

#if os(macOS)
struct MyMenu: Commands {
    @Binding var router: Router
    @Binding var panelSelection: Panel?
    @FocusState var isSearchFiedFocused: Bool
    let networkMonitor = NetworkMonitor.shared

    var body: some Commands {
        CommandGroup(after: .appSettings) {
            Button("Settings...") {
                if networkMonitor.currentStatus == .satisfied {
                    if panelSelection != .AllKontestScreen {
                        panelSelection = .AllKontestScreen
                    }
                    router.appendScreen(screen: .SettingsScreen)
                }
            }
            .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
        }

        CommandGroup(replacing: CommandGroupPlacement.newItem) {}

        CommandGroup(before: .textEditing) {
            Button("Find...") {
                self.isSearchFiedFocused = true
            }
            .keyboardShortcut(KeyEquivalent("f"), modifiers: .command)
        }

        CommandGroup(replacing: .appInfo, addition: {
            Button("About Kontest") {
                @Environment(\.openWindow) var openWindow

                openWindow(id: "about")
            }
        })
    }
}
#endif
