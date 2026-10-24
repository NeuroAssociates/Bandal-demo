//
//  BlockText.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    /// Renders structured blocks as plain text so `render…` functions can share the `execute…` output.
    static func renderText(_ blocks: [DemoResultBlock]) -> String {
        blocks.map { block in
            switch block {
            case .text(let title, let content):
                return [title, content].compactMap { $0 }.joined(separator: "\n")
            case .table(let title, let data):
                return [title, tableText(data)].compactMap { $0 }.joined(separator: "\n")
            }
        }
        .joined(separator: "\n\n")
    }

    private static func tableText(_ data: DemoTableData) -> String {
        let titles = data.columns.map(\.title)
        let widths = titles.indices.map { index in
            max(titles[index].count, data.rows.map { $0[index].count }.max() ?? 0)
        }
        func line(_ cells: [String]) -> String {
            zip(cells, widths)
                .map { $0.0.padding(toLength: $0.1, withPad: " ", startingAt: 0) }
                .joined(separator: "  ")
        }
        return ([line(titles)] + data.rows.map { line($0.values) }).joined(separator: "\n")
    }

    /// Rounds every numeric column, leaving other columns untouched.
    static func roundedNumbers(_ frame: DataFrame, decimals: Int) throws -> DataFrame {
        var result = frame
        for name in frame.columnNames where try frame.dataType(of: name) == .number {
            result = try result.rounded(name, decimals: decimals)
        }
        return result
    }

    static func formatted(_ value: Double?) -> String {
        value.map { String(format: "%.4g", $0) } ?? "NaN"
    }
}
