//
//  Filtering.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeFiltering() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let largeSales = try sales.filterRows { row in
            guard let amount = row["Sales_2025"].flatMap(numericValue) else {
                return false
            }
            return amount >= 1_000_000
        }
        return [
            .text(
                title: String(localized: "Filter condition:"),
                content: """
                Sales_2025 >= 1,000,000
                \(String(localized: "Matching rows:")) \(largeSales.rowCount) / \(sales.rowCount)
                """
            ),
            .table(
                title: String(localized: "Matching sales:"),
                data: DemoTableData(dataFrame: try largeSales.select("Country", "Sales_2025"))
            )
        ]
    }

    static func renderFiltering() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")
        let largeSales = try sales.filterRows { row in
            guard let amount = row["Sales_2025"].flatMap(numericValue) else {
                return false
            }
            return amount >= 1_000_000
        }
        return """
        \(String(localized: "Matching rows:")) \(largeSales.rowCount)
        \(String(localized: "Matching sales:"))
        \(try largeSales.select("Country", "Sales_2025"))
        """
    }
}
