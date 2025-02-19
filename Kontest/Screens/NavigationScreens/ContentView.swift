//
//  ContentView.swift
//  Kontest
//
//  Created by Ayush Singhal on 30/09/23.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Binding var panelSelection: Panel?
    @State private var coluVis: NavigationSplitViewVisibility = .automatic

    let deviceType = getDeviceType()

    var body: some View {
        if deviceType == .iPadOS || deviceType == .macOS {
            GeometryReader { geometryProxy in
                NavigationSplitView(columnVisibility: $coluVis) {
                    Sidebar(panelSelection: $panelSelection)
                    #if os(macOS)
                        .navigationSplitViewColumnWidth(min: 200, ideal: 200, max: max(250, geometryProxy.size.width / 5))
                    #endif
                } detail: {
                    DetailColumn(panelSelection: $panelSelection)
                }
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        } else if deviceType == .iOS {
            iOSVeiw()
        }
    }
}

struct iOSVeiw: View {
    @State private var panelSelection: Panel? = .AllKontestScreen // we are making a new panelSelection and using it from @Binding, because in iOS, panelSelection is not changing (KontestApp.swift) when we are changing tabs, but it works perfectly fine in macOS.
    let path = Router.instance.path

    var body: some View {
        TabView(selection: $panelSelection) {
            AllKontestsScreen(panelSelection: $panelSelection)
                .tabItem {
                    Label("All Kontests", systemImage: "chart.bar")
                }
                .tag(Panel.AllKontestScreen)
            #if os(iOS)
                .toolbar((path.first == .screen(.AllKontestScreen) || path.isEmpty) ? .visible : .hidden, for: .tabBar)
                .animation(path.contains(.screen(.SettingsScreen)) ? nil : .default, value: path)
            #endif

            CodeForcesChartView()
                .tabItem {
                    Label("CodeForces Ratings", image: .codeForcesLogoSmall)
                }
                .tag(Panel.CodeForcesGraphView)

            LeetcodeChartView()
                .tabItem {
                    Label("LeetCode Ratings", image: .leetCodeLogoSmall)
                }
                .tag(Panel.LeetCodeGraphView)

            CodeChefChartView()
                .tabItem {
                    Label("CodeChef Ratings", image: .codeChefSmallLogo)
                }
                .tag(Panel.CodeChefGraphView)
        }
    }
}

@available(macOS 15.0, iOS 18.0, *)
#Preview {
    @Previewable @State var panelSelection: Panel? = .AllKontestScreen

    return ContentView(panelSelection: $panelSelection)
        .environment(Dependencies.instance.allKontestsViewModel)
        .environment(Router.instance)
        .environment(NetworkMonitor.shared)
        .environment(ErrorState())
}
