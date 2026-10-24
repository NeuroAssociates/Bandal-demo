//
//  CSVOverview.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeCSVOverview() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let factory = try loadBundledCSV("factory_data", maximumRows: 5_000)

        let description = sales.describeStructured()
        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN")\n
                """
            }
        }

        return [
            .table(
                title: String(localized: "Global sales preview:"),
                data: DemoTableData(dataFrame: try sales.head())
            ),
            .text(
                title: String(localized: "Global sales details:"),
                content: sales.info()
            ),
            .text(
                title: String(localized: "Global sales statistics:"),
                content: description.describe()
            ),
            .text(
                title: String(localized: "Column statistics summary:"),
                content: statisticsReport.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            .text(
                title: String(localized: "Dataset shapes:"),
                content: """
                \(String(localized: "Country info:")) \(countryInfo.shape)
                \(String(localized: "Factory sample (maximum 5,000 rows):")) \(factory.shape)
                """
            )
        ]
    }

    static func renderCSVOverview() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let factory = try loadBundledCSV("factory_data", maximumRows: 5_000)

        // Use the new structured API to access statistics as Swift objects.
        let description = sales.describeStructured()
        var statisticsReport = ""
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                statisticsReport += """
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN")
                """
            }
        }

        return """
        \(String(localized: "Global sales preview:"))
        \(try sales.head())

        \(String(localized: "Global sales details:"))
        \(sales.info())

        \(String(localized: "Global sales statistics:"))
        \(description.describe())

        \(statisticsReport)

        \(String(localized: "Country info:")) \(countryInfo.shape)
        \(String(localized: "Factory sample (maximum 5,000 rows):")) \(factory.shape)
        """
    }
}
