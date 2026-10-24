//
//  NumericDataFrame.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeNumericDataFrame() throws -> [DemoResultBlock] {
        let temperatures = try DataFrame(columns: [
            "temperature": [18.0, 21.5, 19.0],
            "humidity": [0.45, 0.50, 0.48],
        ])
        let selected = try temperatures.select("temperature")

        // Use the new structured API to access statistics as Swift objects.
        let description = selected.describeStructured()
        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN"), \
                median=\(stats.median?.description ?? "NaN"), q1=\(stats.q1?.description ?? "NaN"), \
                q3=\(stats.q3?.description ?? "NaN")
                """
            }
        }

        return [
            .table(
                title: String(localized: "Selected temperatures:"),
                data: DemoTableData(dataFrame: selected)
            ),
            .text(
                title: String(localized: "Descriptive statistics:"),
                content: description.describe()
            ),
            .text(
                title: String(localized: "Statistics details:"),
                content: statisticsReport.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            .text(
                title: String(localized: "Column details:"),
                content: selected.info()
            )
        ]
    }

    static func renderNumericDataFrame() throws -> String {
        let temperatures = try DataFrame(columns: [
            "temperature": [18.0, 21.5, 19.0],
            "humidity": [0.45, 0.50, 0.48],
        ])
        let selected = try temperatures.select("temperature")

        // Use the new structured API to access statistics as Swift objects.
        let description = selected.describeStructured()
        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN"), \
                median=\(stats.median?.description ?? "NaN"), q1=\(stats.q1?.description ?? "NaN"), \
                q3=\(stats.q3?.description ?? "NaN")
                """
            }
        }

        return """
        \(String(localized: "Selected temperatures:"))
        \(selected)

        \(String(localized: "Descriptive statistics:"))
        \(description.describe())

        \(statisticsReport)

        \(String(localized: "Column details:"))
        \(selected.info())
        """
    }
}
