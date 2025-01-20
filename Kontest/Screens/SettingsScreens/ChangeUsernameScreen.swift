//
//  ChangeUserNameScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 09/09/23.
//

import OSLog
import SwiftUI

struct ChangeUsernameScreen: View {
    var body: some View {
        #if os(macOS)
            VStack {
                MainChangeUsernameView()
            }
        #else
            Form {
                MainChangeUsernameView()
            }
        #endif
    }
}

struct MainChangeUsernameView: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MainChangeUsernameView")

    let changeUsernameViewModel: ChangeUsernameViewModel = Dependencies.instance.changeUsernameViewModel

    @State private var leetcodeUsername: String = ""
    @State private var codeForcesUsername: String = ""
    @State private var codeChefUsername: String = ""

    @FocusState private var focusedField: SettingsTextField?

    @Environment(\.dismiss) var dismiss

    init() {
        _leetcodeUsername = State(initialValue: changeUsernameViewModel.leetcodeUsername)
        _codeForcesUsername = State(initialValue: changeUsernameViewModel.codeForcesUsername)
        _codeChefUsername = State(initialValue: changeUsernameViewModel.codeChefUsername)
    }

    var body: some View {
        SettingsTextFieldView(
            lightModeImage: Image(.codeForcesLogo),
            darkModeImage: Image(.codeForcesLogo),
            title: "Enter CodeForces Username",
            boundaryColor: .accent,
            submitLabel: .next,
            textBinding: $codeForcesUsername,
            fieldID: SettingsTextField.CodeForces,
            focusedField: _focusedField,
            onPressingNext: {
                focusedField = .LeetCode
            }
        )

        SettingsTextFieldView(
            lightModeImage: Image(.leetCodeLightLogo),
            darkModeImage: Image(.leetCodeDarkLogo),
            title: "Enter LeetCode Username",
            boundaryColor: KontestModel.getColorForIdentifier(
                siteAbbreviation: "LeetCode"
            ),
            submitLabel: .next,
            textBinding: $leetcodeUsername,
            fieldID: SettingsTextField.LeetCode,
            focusedField: _focusedField,
            onPressingNext: {
                focusedField = .CodeChef
            }
        )

        SettingsTextFieldView(
            lightModeImage: Image(.codeChefLogo),
            darkModeImage: Image(.codeChefLogo),
            title: "Enter CodeChef Username",
            boundaryColor: KontestModel.getColorForIdentifier(siteAbbreviation: "CodeChef"),
            submitLabel: .return,
            textBinding: $codeChefUsername,
            fieldID: SettingsTextField.CodeChef,
            focusedField: _focusedField,
            onPressingNext: {
                focusedField = nil

                Task {
                    await completeForm()
                }
            }
        )

        Button("Save") {
            Task {
                await completeForm()
            }
        }
    }

    func completeForm() async {
        do {
            try await UserManager.shared.updateUserDetails(
                leetcodeUsername: leetcodeUsername,
                codeForcesUsername: codeForcesUsername,
                codeChefUsername: codeChefUsername
            )
        }
        catch {
            logger.error("Error in uploading usernames to server: \(error.localizedDescription)")
        }

        changeUsernameViewModel.setCodeForcesUsername(newCodeForcesUsername: codeForcesUsername)
        changeUsernameViewModel.setLeetcodeUsername(newLeetcodeUsername: leetcodeUsername)
        changeUsernameViewModel.setCodeChefUsername(newCodeChefUsername: codeChefUsername)

        dismiss()
    }
}

struct SettingsTextFieldView<ID: Hashable>: View {
    let lightModeImage: Image
    let darkModeImage: Image
    let title: String
    let boundaryColor: Color
    let submitLabel: SubmitLabel
    @Binding var textBinding: String
    let fieldID: ID // Generic field identifier
    @FocusState var focusedField: ID? // Use the generic type directly
    let imageSize: CGSize
    var isPasswordType: Bool
    let onChangeofText: (_ oldValue: String, _ newValue: String) -> Void
    let onPressingNext: () -> Void

    init(
        lightModeImage: Image,
        darkModeImage: Image,
        title: String,
        boundaryColor: Color,
        submitLabel: SubmitLabel,
        textBinding: Binding<String>,
        fieldID: ID,
        focusedField: FocusState<ID?>,
        imageSize: CGSize = .init(width: 30, height: 30),
        isPasswordType: Bool = false,
        onChangeofText: @escaping (String, String) -> Void = {_,_ in },
        onPressingNext: @escaping () -> Void = {}
    ) {
        self.lightModeImage = lightModeImage
        self.darkModeImage = darkModeImage
        self.title = title
        self.boundaryColor = boundaryColor
        self.submitLabel = submitLabel
        self._textBinding = textBinding
        self.fieldID = fieldID
        self._focusedField = focusedField
        self.imageSize = imageSize
        self.isPasswordType = isPasswordType
        self.onChangeofText = onChangeofText
        self.onPressingNext = onPressingNext
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            if colorScheme == .light {
                lightModeImage
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
            }
            else {
                darkModeImage
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
            }

            if isPasswordType {
                SecureField(title, text: $textBinding)
                    .textFieldStyle(.plain)
                    .submitLabel(submitLabel)
                    .focused($focusedField, equals: fieldID) // Bind focus to the generic field ID
                    .onChange(of: textBinding) { oldText, newText in
                        onChangeofText(oldText, newText)
                    }
                    .onSubmit {
                        onPressingNext()
                    }
            }
            else {
                TextField(title, text: $textBinding)
                    .textFieldStyle(.plain)
                    .submitLabel(submitLabel)
                    .focused($focusedField, equals: fieldID) // Bind focus to the generic field ID
                    .onChange(of: textBinding) { oldText, newText in
                        onChangeofText(oldText, newText)
                    }
                    .onSubmit {
                        onPressingNext()
                    }
            }
        }
        .padding(5)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(boundaryColor))
        #if os(macOS)
            .frame(maxWidth: 400)
        #endif
    }
}

enum SettingsTextField: Hashable {
    case CodeForces
    case LeetCode
    case CodeChef
}

#Preview {
    ChangeUsernameScreen()
}
