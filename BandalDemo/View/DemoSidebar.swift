//
//  DemoSidebar.swift
//  BandalDemo
//

import SwiftUI

struct DemoSidebar: View {
    @Binding var selection: DemoCase?

    var body: some View {
        List(DemoCase.allCases, selection: $selection) { demo in
            Label(demo.title, systemImage: demo.symbol)
                .accessibilityIdentifier("demo-\(demo.rawValue)")
                .tag(demo)
        }
        .accessibilityIdentifier("demoList")
        .navigationTitle("Bandal Demo")
        .navigationSplitViewColumnWidth(min: 220, ideal: 260)
    }
}
