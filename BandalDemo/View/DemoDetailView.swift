//
//  DemoDetailView.swift
//  BandalDemo
//

import SwiftUI

struct DemoDetailView: View {
    let demo: DemoCase?
    let result: DemoExecutionResult?

    init(demo: DemoCase?, result: DemoExecutionResult?) {
        self.demo = demo
        self.result = result
    }

    init(demo: DemoCase?, tableData: DemoTableData?) {
        self.demo = demo
        if let tableData {
            self.result = DemoExecutionResult(
                blocks: [.table(title: nil, data: tableData)],
                executionTimeMilliseconds: 0
            )
        } else {
            self.result = nil
        }
    }

    var body: some View {
        if let demo {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(demo.title)
                            .font(.largeTitle.bold())
                        Text(demo.explanation)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    DemoCodeSampleView(codeSample: demo.codeSample)
                    DemoResultView(result: result)
                }
                .padding(24)
                .frame(maxWidth: 900, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .accessibilityIdentifier("selectedDemo-\(demo.rawValue)")
            .navigationTitle(demo.title)
        } else {
            ContentUnavailableView(
                "Select a Demo",
                systemImage: "list.bullet.rectangle",
                description: Text("Choose a Bandal feature from the list on the left.")
            )
        }
    }
}

private struct DemoCodeSampleView: View {
    let codeSample: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Example Code")
                .font(.headline)
            Text(codeSample)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
