//
//  DemoTableData.swift
//  BandalDemo
//

import Foundation
import Bandal

/// Structured tabular data for displaying demo results in a SwiftUI ``Table``.
///
/// Each column has a title and each row contains one value per column.
struct DemoTableData: Equatable {
    struct Column: Identifiable, Equatable {
        let id: Int
        let title: String
    }

    struct Row: Identifiable, Equatable {
        let id: Int
        let values: [String]

        subscript(index: Int) -> String {
            guard values.indices.contains(index) else { return "" }
            return values[index]
        }
    }

    /// Column titles displayed in the table header.
    let columns: [Column]
    /// Row values, where each row's values align with ``columns``.
    let rows: [Row]

    var isEmpty: Bool { rows.isEmpty }

    init(columns: [String], rows: [[String]]) {
        self.columns = columns.enumerated().map { Column(id: $0.offset, title: $0.element) }
        self.rows = rows.enumerated().map { Row(id: $0.offset, values: $0.element) }
    }

    /// Creates table data directly from a Bandal ``DataFrame``.
    init(dataFrame: DataFrame) {
        let columnNames = dataFrame.columnNames
        var rows: [[String]] = []
        let columnValues = columnNames.compactMap { try? dataFrame.values(in: $0) }
        if columnValues.count == columnNames.count {
            for rowIndex in 0..<dataFrame.rowCount {
                let row = columnValues.map { values in
                    Self.displayValue(values[rowIndex])
                }
                rows.append(row)
            }
        }
        self.init(columns: columnNames, rows: rows)
    }

    private static func displayValue(_ value: DataValue) -> String {
        switch value {
        case .number(let number): String(format: "%.6g", number)
        case .string(let string): string
        case .boolean(let flag): String(flag)
        case .date(let date): date.formatted(.iso8601)
        case .missing: "NaN"
        }
    }

    /// Creates table data from a multi-line string, placing each non-empty line
    /// into a single "Result" column.
    static func fromText(_ text: String) -> DemoTableData {
        let lines = text.componentsSeparatedByNewlines()
            .filter { !$0.isEmpty }
        return DemoTableData(
            columns: [String(localized: "Result")],
            rows: lines.map { [$0] }
        )
    }
}

private extension String {
    func componentsSeparatedByNewlines() -> [String] {
        components(separatedBy: CharacterSet.newlines)
    }
}
