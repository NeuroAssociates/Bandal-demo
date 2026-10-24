//
//  DerivedColumns.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeDerivedColumns() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let filled = try sales.fillMissing(in: ["Sales_2024"], with: .number(0))

        let prepared = try filled
            .combining("Sales_2025", "Sales_2024", using: .subtract, as: "Growth_Amount")
            .scaling("Sales_2025", by: 1.1, using: .multiply, as: "Target_2026")
            .rounded("Target_2026", decimals: 0)
            .ranked("Sales_2025", ascending: false, as: "Sales_Rank")
            .withColumn(name: "Sales_Level") { row in
                guard let amount = row["Sales_2025"]?.numberValue else { return .missing }
                return .string(amount >= 1_000_000 ? "High" : "Normal")
            }

        return [
            .text(
                title: String(localized: "Derived columns summary:"),
                content: """
                Growth_Amount = combining("Sales_2025", "Sales_2024", using: .subtract)
                Target_2026 = scaling("Sales_2025", by: 1.1, using: .multiply)
                Sales_Rank = ranked("Sales_2025", ascending: false)
                Sales_Level = withColumn(name:computing:) (Sales_2025 >= 1,000,000 ? "High" : "Normal")
                \(String(localized: "Total rows:")) \(prepared.rowCount)
                """
            ),
            .table(
                title: String(localized: "Prepared sales (first 10 rows):"),
                data: DemoTableData(
                    dataFrame: try prepared
                        .select("Country", "Growth_Amount", "Target_2026", "Sales_Rank", "Sales_Level")
                        .head(10)
                )
            )
        ]
    }

    static func renderDerivedColumns() throws -> String {
        renderText(try executeDerivedColumns())
    }
}
