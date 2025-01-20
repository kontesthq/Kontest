//
//  ChangePasswordScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/25/24.
//

import SwiftUI

struct ChangePasswordScreen: View {
    var body: some View {
#if os(macOS)
        VStack {
            MainChangePasswordView()
        }
#else
        Form {
            MainChangePasswordView()
        }
#endif
    }
}

struct MainChangePasswordView: View {
    @State private var authenticationEmailViewModel: AuthenticationEmailViewModel = .shared

    @FocusState private var focusedField: ChangePasswordField?

    @Environment(\.dismiss) var dismiss
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            SettingsTextFieldView(
                lightModeImage: Image(systemName: "key"),
                darkModeImage: Image(systemName: "key"),
                title: "Password",
                boundaryColor: colorScheme == .light ? .black : .white,
                submitLabel: .next,
                textBinding: Bindable(authenticationEmailViewModel).password,
                fieldID: ChangePasswordField.password,
                focusedField: _focusedField,
                imageSize: CGSize(width: 20, height: 30),
                isPasswordType: true,
                onChangeofText: {_,_ in
                    authenticationEmailViewModel.error = nil
                },
                onPressingNext: {
                    focusedField = .confirmedPassword
                }
            )
#if os(macOS)
            .frame(maxWidth: 400)
#endif

            SettingsTextFieldView(
                lightModeImage: Image(systemName: "key"),
                darkModeImage: Image(systemName: "key"),
                title: "Confirm Password",
                boundaryColor: colorScheme == .light ? .black : .white,
                submitLabel: .return,
                textBinding: Bindable(authenticationEmailViewModel).confirmPassword,
                fieldID: ChangePasswordField.confirmedPassword,
                focusedField: _focusedField,
                imageSize: CGSize(width: 20, height: 30),
                isPasswordType: true,
                onChangeofText: {_,_ in
                    authenticationEmailViewModel.error = nil
                },
                onPressingNext: {
                    focusedField = nil

                    completeForm()
                }
            )
#if os(macOS)
            .frame(maxWidth: 400)
#endif

            if let error = authenticationEmailViewModel.error {
                TextErrorView(error: error)
            }

            Button("Change Password") {
                completeForm()
            }
        }
        .onAppear {
            authenticationEmailViewModel.clearAllFields()
            
            focusedField = .password
        }
#if os(macOS)
        .frame(maxWidth: 400)
#endif
    }

    func completeForm() {
        Task {
            await authenticationEmailViewModel.setNewPassword()

            if authenticationEmailViewModel.error == nil {
                try await AuthenticationManager.shared.signOut()

                authenticationEmailViewModel.clearAllFields()

                Router.instance.goToRootView()
            }
        }
    }
}

enum ChangePasswordField: Hashable {
    case password
    case confirmedPassword
}

#Preview {
    ChangePasswordScreen()
}
