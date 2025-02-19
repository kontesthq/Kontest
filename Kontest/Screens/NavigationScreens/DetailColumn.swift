//
//  DetailColumn.swift
//  Kontest
//
//  Created by Ayush Singhal on 30/09/23.
//

import SwiftUI

struct DetailColumn: View {
    @Binding var panelSelection: Panel?

    var body: some View {
        switch panelSelection {
        case .AllKontestScreen:
            AllKontestsScreen(panelSelection: $panelSelection)

        case .LeetCodeGraphView:
            LeetcodeChartView()

        case .CodeForcesGraphView:
            CodeForcesChartView()

        case .CodeChefGraphView:
            CodeChefChartView()

        case nil:
            Text("Nil")
        }
    }
}
