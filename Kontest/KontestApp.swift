//
//  KontestApp.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import Firebase
import OSLog
import SwiftUI

@main
struct KontestApp: App {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "KontestApp")

    init() {
        networkMonitor.start(afterSeconds: 0.5)
    }

    @State private var allKontestsViewModel = Dependencies.instance.allKontestsViewModel
    @State private var router = Router.instance
    @State private var errorState = ErrorState()
    @State private var panelSelection: Panel? = .AllKontestScreen
    @State private var isAlertDisplayed: Bool = false
    @State private var errorWrapper: ErrorWrapper = .init(error: AppError(title: "", description: ""), guidance: "")

    @FocusState private var isSearchFiedFocused: Bool

    let networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            if let defaults = UserDefaults(suiteName: Constants.userDefaultsGroupID) {
                Group {
                    if #available(macOS 15.0, iOS 18.0, *) {
                        TabView(selection: $panelSelection) {
                            Tab("All Kontests", systemImage: "list.bullet", value: .AllKontestScreen) {
                                AllKontestsScreen(isSearchFiedFocused: _isSearchFiedFocused)
                            }

                            Tab("CodeForces", image: "CodeForces Logo Small", value: .CodeForcesGraphView) {
                                CodeForcesChartView()
                            }

                            Tab("LeetCode", image: "LeetCode Logo Small", value: .LeetCodeGraphView) {
                                LeetcodeChartView()
                            }

                            Tab("CodeChef", image: "CodeChef Small Logo", value: .CodeChefGraphView) {
                                CodeChefChartView()
                            }
                        }
                    } else {
                        ContentView(panelSelection: $panelSelection)
                    }
                }
                .onAppear(perform: {
                    print("deviceId: \(KeychainHelper.getUniqueDeviceIdentifier())")
                    print("deviceId sha512: \(CryptoKitUtility.sha512(for: KeychainHelper.getUniqueDeviceIdentifier()))")
                })
                .environment(allKontestsViewModel)
                .environment(router)
                .environment(networkMonitor)
                .environment(errorState)
                .onChange(of: errorState.errorWrapper) {
                    if let errorWrapper = errorState.errorWrapper {
                        self.errorWrapper = errorWrapper
                        self.isAlertDisplayed = true
                    }
                }
#if os(iOS)
//                    .sheet(item: $errorState.errorWrapper) { errorWrapper in
//                        ErrorView(errorWrapper: errorWrapper)
//                            .apply {
//                                if #available(iOS 18.0, *) {
//                                    $0.presentationSizing(.fitted)
//                                } else {
//                                    $0
//                                }
//                            }
//                    }
                .alert(errorState.errorWrapper?.error is AppError ? (errorWrapper.error as! AppError).title : "Error has occurred", isPresented: $isAlertDisplayed, actions: {
                    Button("Dismiss") {}

                    if errorWrapper.error is AppError {
                        let appError = errorWrapper.error as! AppError

                        if let action = appError.action {
                            Button(appError.actionLabel) {
                                action()
                            }
                        }
                    }
                }, message: {
                    Text(errorWrapper.error.localizedDescription)

                    Text(errorWrapper.guidance)
                        .font(.caption)
                })

#endif
#if os(macOS)
                .onAppear(perform: {
    disallowTabbingMode()
})
.frame(minWidth: 900, idealWidth: 1100, minHeight: 500, idealHeight: 600)
#endif
.defaultAppStorage(defaults)
            } else {
                Text("Failed to load user defaults")
            }
        }
        .commands {
            MyMenu(router: $router, panelSelection: $panelSelection, isSearchFiedFocused: _isSearchFiedFocused)
        }

#if os(macOS)
        if #available(macOS 15.0, *) {
            aboutWindow()

            openAlertWindow(errorWrapper: self.errorWrapper, isPresented: $isAlertDisplayed)
        }
#endif
    }
}

#if os(macOS)
@available(macOS 15.0, *)
func openAlertWindow(errorWrapper: ErrorWrapper, isPresented: Binding<Bool>) -> some Scene {
    AlertScene(errorWrapper.error is AppError ? (errorWrapper.error as! AppError).title : "Error has occurred", isPresented: isPresented, actions: {
        Button("Dismiss", role: .cancel) {}

        if errorWrapper.error is AppError {
            let appError = errorWrapper.error as! AppError

            if let action = appError.action {
                Button(appError.actionLabel) {
                    action()
                }
            }
        }
    }, message: {
        Text(errorWrapper.error.localizedDescription)

        Text(errorWrapper.guidance)
            .font(.caption)
    })
}
#endif

#if os(macOS)
@available(macOS 15.0, *)
func aboutWindow() -> some Scene {
    Window("About Kontest", id: "about") {
        AboutView()
            .padding()
//        .fixedSize()
            .toolbar(removing: .title)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            .containerBackground(.thickMaterial, for: .window)
            .windowMinimizeBehavior(.disabled)
            .windowResizeBehavior(.disabled)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)
}

@MainActor
fileprivate func disallowTabbingMode() {
    NSWindow.allowsAutomaticWindowTabbing = false
}
#endif

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

#if os(macOS)
extension Scene {
    func applyRestorationBehavior() -> some Scene {
        if #available(macOS 15.0, *) {
            return self.restorationBehavior(.disabled)
        } else {
            return self
        }
    }
}
#endif

struct AboutView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(.kontestLogo)

            VStack(alignment: .leading, spacing: 0) {
                Text("Kontest")
                    .font(.system(size: 48))
                    .fontWeight(.bold)

                HStack {
                    Text("Version 1.0")

                    Image(systemName: "document.on.document")
                        .onTapGesture {
                            ClipboardUtility.copyToClipBoard("Version 1.0")
                        }

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.thickMaterial, .green)

                        Text("Up-to-date")
                    }
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .contentShape(Capsule())
                }
                .foregroundStyle(.secondary)

                HStack {
                    Link(destination: URL(string: "http://github.com/ayushs-2k4/")!) {
                        Image(.githubLogo)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.bottom)

                VStack(alignment: .leading) {
                    Text("© 2024 Ayush Singhal")

//                    Link(destination: URL(string: "http://github.com/ayushs-2k4/")!) {
//                        Text("About Team")
//                            .underline()
//                    }
//
//                    Link(destination: URL(string: "http://github.com/ayushs-2k4/")!) {
//                        Text("Acknowledgement")
//                            .underline()
//                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AboutView()
}
