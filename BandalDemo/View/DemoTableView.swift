//
//  DemoTableView.swift
//  BandalDemo
//

import SwiftUI

/// Displays structured demo results mixing formatted text blocks and native SwiftUI tables.
struct DemoResultView: View {
    let result: DemoExecutionResult?

    private var statusText: String {
        guard let result else {
            return String(localized: "Preparing output…")
        }
        if result.totalRowCount > 0 {
            return String(localized: "\(result.totalRowCount) rows")
        } else {
            return String(localized: "Ready")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(String(localized: "Output"))
                    .font(.headline)
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("demoOutput")
                    .accessibilityValue(statusText)
            }

            if let result {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(result.blocks) { block in
                        switch block {
                        case .text(let title, let content):
                            DemoTextBlockView(title: title, content: content)
                        case .table(let title, let data):
                            DemoTableBlockView(title: title, data: data)
                        }
                    }

                    if let ms = result.executionTimeMilliseconds as Double? {
                        Text("\(String(localized: "Processing time:")) \(String(format: "%.2f", ms)) ms")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text(String(localized: "Preparing output…"))
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

/// Displays formatted monospaced text output, styled consistently with the example code block.
struct DemoTextBlockView: View {
    let title: String?
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            Text(content)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

/// Displays DataFrame tabular data using SwiftUI's native ``Table`` view.
struct DemoTableBlockView: View {
    let title: String?
    let data: DemoTableData

    private var tableHeight: CGFloat {
        let rowCount = max(data.rows.count, 1)
        let headerHeight: CGFloat = 32
        let rowHeight: CGFloat = 28
        let estimated = headerHeight + CGFloat(rowCount) * rowHeight + 16
        return min(max(estimated, 140), 320)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text("\(data.rows.count) rows × \(data.columns.count) columns")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if data.isEmpty {
                Text(String(localized: "No rows"))
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            } else {
                Table(data.rows) {
                    TableColumnForEach(data.columns) { column in
                        TableColumn(column.title) { row in
                            Text(row[column.id])
                                .font(.system(.callout, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: tableHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

/// Displays demo result data using SwiftUI's native ``Table`` view.
/// Provided for backwards compatibility with direct table data usage.
struct DemoTableView: View {
    let data: DemoTableData

    var body: some View {
        DemoTableBlockView(title: nil, data: data)
    }
}

#Preview {
    DemoResultView(result: DemoExecutionResult(
        blocks: [
            .text(
                title: "Summary Info",
                content: "RangeIndex: 3 entries\nData columns (total 2 columns)"
            ),
            .table(
                title: "Preview Data",
                data: DemoTableData(
                    columns: ["Column", "Value"],
                    rows: [["Count", "3"], ["Mean", "20.0"], ["Median", "20.0"]]
                )
            ),
        ],
        executionTimeMilliseconds: 1.25
    ))
    .padding()
}
