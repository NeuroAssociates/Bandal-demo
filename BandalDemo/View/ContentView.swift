//
//  ContentView.swift
//  BandalDemo
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDemo: DemoCase? = .csvOverview
    @State private var result: DemoExecutionResult? = nil

    var body: some View {
        NavigationSplitView {
            DemoSidebar(selection: $selectedDemo)
        } detail: {
            DemoDetailView(demo: selectedDemo, result: result)
                .task(id: selectedDemo) {
                    guard let selectedDemo else { return }
                    result = executeDemo(for: selectedDemo)
                }
        }
    }
}

#Preview {
    ContentView()
}
