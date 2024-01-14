//
//  RootView.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/14/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false

    var body: some View {
        ZStack {
            NavigationStack {
                Text("Settings")
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()

            self.showSignInView = authUser == nil ? true : false
        }

        if showSignInView {
            AuthenticationView()
        }
        else {
            Button {
                do {
                    try AuthenticationManager.shared.signOut()
                }
                catch {}
            } label: {
                Text("Sign Out")
            }
        }
    }
}

#Preview {
    RootView()
        .frame(width: 500, height: 500)
}
