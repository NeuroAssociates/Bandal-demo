//
//  Summary.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeSummary() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let description = sales.describeStructured()

        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName):
                  count = \(stats.count)
                  mean = \(stats.mean?.description ?? "NaN")
                  std = \(stats.standardDeviation?.description ?? "NaN")
                  min = \(stats.min?.description ?? "NaN")
                  max = \(stats.max?.description ?? "NaN")
                  median = \(stats.median?.description ?? "NaN")
                  q1 = \(stats.q1?.description ?? "NaN")
                  q3 = \(stats.q3?.description ?? "NaN")\n\n
                """
            } else if let summary = description.nonNumeric[columnName] {
                statisticsReport += """
                \(columnName) (non-numeric):
                  count = \(summary.count)
                  unique = \(summary.unique)
                  top = \(summary.top?.description ?? "NaN")
                  freq = \(summary.freq)\n\n
                """
            }
        }

        return [
            .table(
                title: String(localized: "Sample rows (head 5):"),
                data: DemoTableData(dataFrame: try sales.head(5))
            ),
            .text(
                title: String(localized: "Summary statistics (describe):"),
                content: description.describe()
            ),
            .text(
                title: String(localized: "DataFrame Info:"),
                content: sales.info()
            ),
            .text(
                title: String(localized: "Detailed numeric & text statistics:"),
                content: statisticsReport.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        ]
    }

    static func renderSummary() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")

        // Use the new structured API to access statistics as Swift objects.
        let description = sales.describeStructured()

        // Programmatic access to numeric column statistics.
        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName):
                  count = \(stats.count)
                  mean = \(stats.mean?.description ?? "NaN")
                  std = \(stats.standardDeviation?.description ?? "NaN")
                  min = \(stats.min?.description ?? "NaN")
                  max = \(stats.max?.description ?? "NaN")
                  median = \(stats.median?.description ?? "NaN")
                  q1 = \(stats.q1?.description ?? "NaN")
                  q3 = \(stats.q3?.description ?? "NaN")

                """
            } else if let summary = description.nonNumeric[columnName] {
                statisticsReport += """
                \(columnName) (non-numeric):
                  count = \(summary.count)
                  unique = \(summary.unique)
                  top = \(summary.top?.description ?? "NaN")
                  freq = \(summary.freq)

                """
            }
        }

        // Render pandas-style text table via describe() on the result instance.
        let table = description.describe()

        return "\(table)\n\n\(sales.info())\n\n\(statisticsReport)"
    }
}
