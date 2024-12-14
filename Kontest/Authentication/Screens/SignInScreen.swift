//
//  SignInScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/15/24.
//

import OSLog
import SwiftUI

struct SignInScreen: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "SignInScreen")

    let authenticationEmailViewModel: AuthenticationEmailViewModel = .shared

    @State private var isPasswordFieldVisible: Bool = false

    @FocusState private var focusedField: SignInTextField?

    @Environment(Router.self) private var router

    var body: some View {
        VStack {
            #if os(iOS)
                SignInViewTextField(
                    leftText: "Email ID:",
                    textHint: "Email",
                    isPasswordType: false,
                    focusedField: _focusedField,
                    currentField: .email,
                    textBinding: Bindable(authenticationEmailViewModel).email,
                    keyboardType: .emailAddress,
                    submitLabel: .next,
                    onSubmit: {
                        actionToPerformWhenContinuingAfterEnteringEmail()
                    }
                )
                .padding(.horizontal)
                .onChange(of: authenticationEmailViewModel.email) {
                    isPasswordFieldVisible = false
                }
            #else
                SignInViewTextField(
                    leftText: "Email ID:",
                    textHint: "Email",
                    isPasswordType: false,
                    focusedField: _focusedField,
                    currentField: .email,
                    textBinding: Bindable(authenticationEmailViewModel).email,
                    submitLabel: .next,
                    onSubmit: {
                        actionToPerformWhenContinuingAfterEnteringEmail()
                    }
                )
                .padding(.horizontal)
                .onChange(of: authenticationEmailViewModel.email) {
                    isPasswordFieldVisible = false
                }
            #endif

            if isPasswordFieldVisible {
                SignInViewTextField(
                    leftText: "Password:",
                    textHint: "required",
                    isPasswordType: true,
                    focusedField: _focusedField,
                    currentField: .password,
                    textBinding: Bindable(authenticationEmailViewModel).password,
                    submitLabel: .continue,
                    onSubmit: {
                        actionToPerformWhenContinuingAfterEnteringPassword()
                    }
                )
                .padding(.horizontal)
            }

            if let error = authenticationEmailViewModel.error {
                TextErrorView(error: error)
            }

            HStack {
                Spacer()

                if authenticationEmailViewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.horizontal, 1)
                }

                Button {
                    authenticationEmailViewModel.clearPasswordFields()
                    router.popLastScreen()
                    router.appendScreen(screen: Screen.SettingsScreenType(.AuthenticationScreenType(.SignUpScreen)))
                } label: {
                    Text("Sign Up Instead")
                }

                Button("Continue") {
                    authenticationEmailViewModel.error = nil

                    if !isPasswordFieldVisible { // only email field is visible
                        actionToPerformWhenContinuingAfterEnteringEmail()
                    } else {
                        actionToPerformWhenContinuingAfterEnteringPassword()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
            }
            .padding(.horizontal)
        }
        .animation(.linear(duration: 0.2), value: isPasswordFieldVisible)
        .animation(.linear(duration: 0.2), value: authenticationEmailViewModel.error == nil)
        .offset(y: isPasswordFieldVisible ? 43 : 0)
        .offset(y: authenticationEmailViewModel.error != nil ? 20 : 0)
        .onAppear {
            self.focusedField = .email
        }
        #if os(macOS)
        .frame(maxWidth: 400)
        #endif
    }

    func actionToPerformWhenContinuingAfterEnteringEmail() {
        authenticationEmailViewModel.error = nil
        
        if authenticationEmailViewModel.email.isEmpty {
            authenticationEmailViewModel.error = AppError(title: "Email can not be empty.", description: "")
        } else if !checkIfEmailIsCorrect(emailAddress: authenticationEmailViewModel.email) {
            authenticationEmailViewModel.error = AppError(title: "Email is not in correct format.", description: "")
        } else {
            isPasswordFieldVisible = true

            focusedField = .password
        }
    }

    func actionToPerformWhenContinuingAfterEnteringPassword() {
        authenticationEmailViewModel.error = nil
        
        Task {
            let isSignInSuccessful = await authenticationEmailViewModel.signIn()

            if isSignInSuccessful {
                logger.log("Yes, sign in is successful")

                router.goToRootView()

                authenticationEmailViewModel.clearAllFields()
            } else {
                logger.log("No, sign in is not successful")
            }
        }
    }
}

private struct SignInViewTextField: View {
    let leftText: String
    let textHint: String
    var isPasswordType: Bool = false
    @FocusState private var focusedField: SignInTextField?
    let currentField: SignInTextField
    @Binding var textBinding: String

    #if os(iOS)
        let keyboardType: UIKeyboardType
    #endif

    let submitLabel: SubmitLabel

    let onSubmit: () -> ()

    #if os(iOS)
        init(
            leftText: String,
            textHint: String,
            isPasswordType: Bool,
            focusedField: FocusState<SignInTextField?>,
            currentField: SignInTextField,
            textBinding: Binding<String>,
            keyboardType: UIKeyboardType = .default,
            submitLabel: SubmitLabel = .return,
            onSubmit: @escaping () -> () = {}
        ) {
            self.leftText = leftText
            self.textHint = textHint
            self.isPasswordType = isPasswordType
            self._focusedField = focusedField
            self.currentField = currentField
            self._textBinding = textBinding
            self.keyboardType = keyboardType
            self.submitLabel = submitLabel
            self.onSubmit = onSubmit
        }
    #else
        init(
            leftText: String,
            textHint: String,
            isPasswordType: Bool,
            focusedField: FocusState<SignInTextField?>,
            currentField: SignInTextField,
            textBinding: Binding<String>,
            submitLabel: SubmitLabel = .return,
            onSubmit: @escaping () -> () = {}
        ) {
            self.leftText = leftText
            self.textHint = textHint
            self.isPasswordType = isPasswordType
            self._focusedField = focusedField
            self.currentField = currentField
            self._textBinding = textBinding
            self.submitLabel = submitLabel
            self.onSubmit = onSubmit
        }
    #endif

    var body: some View {
        HStack {
            Text(leftText)

            if isPasswordType {
                SecureField(textHint, text: $textBinding)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: currentField)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit()
                    }
            } else {
                TextField(textHint, text: $textBinding)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: currentField)
                #if os(iOS)
                    .keyboardType(keyboardType)
                #endif
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit()
                    }
            }
        }
        .padding(10)
        .overlay( // apply a rounded border
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(.systemGray), lineWidth: 1)
        )
    }
}

struct TextErrorView: View {
    let error: any Error

    var body: some View {
        HStack {
            Spacer()

            if let appError = error as? AppError {
                VStack(alignment: .trailing) {
                    Text(appError.title)
                        .foregroundStyle(.red)
                        .padding(.horizontal)

                    if !appError.description.isEmpty {
                        Text(appError.description)
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
            } else {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
    }
}

enum SignInTextField {
    case email
    case password
}

#Preview {
    SignInScreen()
        .environment(Router.instance)
        .frame(width: 500, height: 500)
}
