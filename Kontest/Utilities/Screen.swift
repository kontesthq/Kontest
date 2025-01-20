//
//  Screens.swift
//  Kontest
//
//  Created by Ayush Singhal on 16/08/23.
//

import Foundation

enum Screen: Hashable {
    case AllKontestScreen
    case SettingsScreen
    case SettingsScreenType(SettingsScreens)
    case PendingNotificationsScreen
}

enum SettingsScreens: Hashable {
    case ChangeUserNamesScreen
    case FilterWebsitesScreen
    case RotatingMapScreen
    case AuthenticationScreenType(AuthenticationScreens)
    case ChangePasswordScreen
}

enum AuthenticationScreens {
    case SignInScreen
    case SignUpScreen
    case AccountInformationScreen
}
