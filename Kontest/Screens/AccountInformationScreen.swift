//
//  AccountInformationScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/16/24.
//

import OSLog
import SwiftUI

struct AccountInformationScreen: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "AccountInformationScreen")
    
    @Environment(Router.self) private var router
    
    let accountInformationViewModel = AccountInformationViewModel.shared
    @State private var isAuthenticated: Bool = false
    
    @State private var isNameChangeSheetPresented: Bool = false
    @State private var isCollegeChangeSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                if let email = accountInformationViewModel.user?.email {
                    HStack {
                        Text("Email")
                        
                        Spacer()
                        
                        Text(email)
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray.opacity(0.3))
                }
                
                HStack {
                    Text("Name")
                    
                    Spacer()
                    
                    Text(accountInformationViewModel.fullName)
                }
                .onTapGesture(perform: {
                    if !accountInformationViewModel.isLoading {
                        isNameChangeSheetPresented = true
                    }
                })
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(0.3))
                
                HStack {
                    Text("College")
                    
                    Spacer()
                    
                    Text(accountInformationViewModel.fullCollegeName)
                }
                .onTapGesture(perform: {
                    if !accountInformationViewModel.isLoading {
                        isCollegeChangeSheetPresented = true
                    }
                })
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray)
                    .padding(1)
            }
            
            Button("Sign Out") {
                do {
                    Task {
                        try await AuthenticationManager.shared.signOut()
                    }
                    
                    accountInformationViewModel.clearAllFields()
                    
                    router.goToRootView()
                } catch {
                    logger.log("Error in Signing out: \(error)")
                }

                Task {
                    isAuthenticated = await AuthenticationManager.shared.checkAuthenticationStatus()
                }
            }
            
            if accountInformationViewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .hidden()
            }
        }
        .onAppear(perform: {
            if accountInformationViewModel.user == nil {
                accountInformationViewModel.getAuthenticatedUser()
            }
        })
        .padding()
        .frame(maxWidth: 400)
        .sheet(isPresented: $isNameChangeSheetPresented, content: {
            ChangeNameSheetView()
                .frame(minWidth: 400)
                .padding()
        })
        .sheet(isPresented: $isCollegeChangeSheetPresented, content: {
            ChangeCollegeSheetView()
                .frame(minWidth: 400)
                .padding()
        })
    }
}

struct ChangeNameSheetView: View {
    let accountInformationViewModel = AccountInformationViewModel.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    
    @State private var isFirstNameErrorShown: Bool = false
    @State private var isLastNameErrorShown: Bool = false
    
    init() {
        self._firstName = State(initialValue: accountInformationViewModel.firstName)
        self._lastName = State(initialValue: accountInformationViewModel.lastName)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("First Name:")
                        
                    TextField("", text: $firstName)
                        .padding(0)
                }
                
                if isFirstNameErrorShown {
                    Text("                      Enter a first name")
                        .foregroundStyle(Color(.systemRed))
                        .padding(0)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Last Name:")
                        
                    TextField("", text: $lastName)
                        .padding(0)
                }
                
                if isLastNameErrorShown {
                    Text("                      Enter a last name")
                        .foregroundStyle(Color(.systemRed))
                        .padding(0)
                }
            }
            .padding(.horizontal)
            
//            Rectangle()
//                .frame(height: 1)
//                .foregroundStyle(.gray.opacity(0.3))
//                .padding(.vertical)
            
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    isFirstNameErrorShown = firstName.isEmpty
                    isLastNameErrorShown = lastName.isEmpty
                    
                    if !firstName.isEmpty && !lastName.isEmpty {
                        Task {
                            do {
                                try await accountInformationViewModel.updateName(firstName: self.firstName, lastName: self.lastName)
                            } catch {
                                print("Error in updating name: \(error.localizedDescription)")
                            }
                        }
                    
                        dismiss()
                    }
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                .keyboardShortcut(.return)
            }
            .padding(.horizontal)
        }
        .onChange(of: firstName) {
            if isFirstNameErrorShown {
                if !firstName.isEmpty {
                    isFirstNameErrorShown = false
                }
            }
        }
        .onChange(of: lastName) {
            if isLastNameErrorShown {
                if !lastName.isEmpty {
                    isLastNameErrorShown = false
                }
            }
        }
    }
}

struct ChangeCollegeSheetView: View {
    let accountInformationViewModel = AccountInformationViewModel.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var collegesList: [College] = []
    @State private var isCollegeListDownloading = false
    
    @State private var selectedState: String = ""
    @State private var selectedCollege: String = ""
    
    init() {
        self._selectedState = State(initialValue: accountInformationViewModel.collegeState)
        self._selectedCollege = State(initialValue: accountInformationViewModel.collegeName)
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("   Select State:", selection: $selectedState) {
                    ForEach(Constants.states, id: \.self) { state in
                        Text(state)
                    }
                }

                ProgressView()
                    .controlSize(.small)
                    .padding(1)
                    .hidden()
            }
            .onChange(of: selectedState) {
                collegesList.removeAll()

                Task {
                    isCollegeListDownloading = true
                    let downloadedCollegesList = try await CollegesRepository.shared.getAllCollegesOfAStateFromFirestore(state: selectedState)
                        .sorted { college1, college2 in
                            college1.name < college2.name
                        }

                    self.collegesList.append(contentsOf: downloadedCollegesList)

                    isCollegeListDownloading = false

                    selectedCollege = downloadedCollegesList[0].name
                }
            }
            .onAppear(perform: {
                Task {
                    isCollegeListDownloading = true
                    let downloadedCollegesList = try await CollegesRepository.shared.getAllCollegesOfAStateFromFirestore(state: selectedState)
                        .sorted { college1, college2 in
                            college1.name < college2.name
                        }

                    self.collegesList.append(contentsOf: downloadedCollegesList)

                    isCollegeListDownloading = false
                }
            })

            HStack {
                Picker("Select College:", selection: $selectedCollege) {
                    ForEach(collegesList.map { clg in
                        clg.name
                    }, id: \.self) { college in
                        Text(college)
                    }
                }

                if isCollegeListDownloading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(1)
                } else {
                    ProgressView()
                        .controlSize(.small)
                        .padding(1)
                        .hidden()
                }
            }
            
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    Task {
                        do {
                            try await accountInformationViewModel.updateCollege(collegeStateName: selectedState, collegeName: selectedCollege)
                        } catch {
                            print("Error in updating college: \(error.localizedDescription)")
                        }
                    }
                    
                    dismiss()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                .disabled(isCollegeListDownloading)
                .keyboardShortcut(.return)
            }
            .padding(.horizontal)
        }
    }
}

#Preview("AccountInformationScreen") {
    AccountInformationScreen()
        .frame(width: 400, height: 400)
        .environment(Router.instance)
}

#Preview("ChangeNameSheetView") {
    ChangeNameSheetView()
        .frame(width: 400, height: 400)
        .environment(Router.instance)
}

#Preview("ChangeCollegeSheetView") {
    ChangeCollegeSheetView()
        .frame(width: 400, height: 400)
        .environment(Router.instance)
}
