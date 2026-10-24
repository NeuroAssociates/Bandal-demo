//
//  MissingValues.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeMissingValues() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let missingMask = try sales.isMissing(in: "Sales_2024")
        let fullMaskTable = try sales.select("Country", "Sales_2024", "Sales_2025").missingMask()
        let missingSummary = sales.missingSummary()
        let filled = try sales.fillMissing(
            in: ["Sales_2024"],
            with: .number(0)
        )
        let replaced = try filled.replacing(.number(0), with: .number(-1), in: ["Sales_2024"])
        let complete = try sales.dropMissing(in: ["Sales_2024"])
        let synthetic = try DataFrame(columns: [
            (
                name: "measurement",
                values: [.number(10), .missing, .number(20), .number(30)]
            ),
        ])
        guard let summary = synthetic.summary()["measurement"] else {
            throw DemoValidationError.failed("numeric summary was not returned")
        }
        try validateDemo(
            missingMask.filter { $0 }.count
                == sales.missingCounts()["Sales_2024", default: 0],
            "CSV missing-value count does not match its mask"
        )
        try validateDemo(
            filled.missingCounts()["Sales_2024", default: 0] == 0,
            "fillMissing left values missing"
        )
        try validateDemo(
            complete.rowCount + sales.missingCounts()["Sales_2024", default: 0] == sales.rowCount,
            "dropMissing row count mismatch"
        )
        try validateDemo(
            summary.count == 3
                && summary.mean == 20
                && summary.median == 20
                && summary.standardDeviation == 10,
            "numeric summary statistics mismatch"
        )

        let validationText = """
        \(String(localized: "Validation result: Passed"))
        \(String(localized: "CSV missing-value counts:")) \(sales.missingCounts())
        missingSummary().totalMissing = \(missingSummary.totalMissing)
        \(String(localized: "Sales_2024 missing mask (first 10):")) \(Array(missingMask.prefix(10)))
        \(String(localized: "Rows after dropping missing Sales_2024:")) \(complete.rowCount)
        \(String(localized: "Synthetic summary checks: count=3, mean=20, median=20, sample std=10"))
        """

        return [
            .text(
                title: String(localized: "Missing values validation:"),
                content: validationText
            ),
            .table(
                title: String(localized: "missingMask() boolean DataFrame (first 5 rows):"),
                data: DemoTableData(dataFrame: try fullMaskTable.head(5))
            ),
            .table(
                title: String(localized: "Filled preview (Sales_2024 filled with 0):"),
                data: DemoTableData(dataFrame: try filled.select("Country", "Sales_2024").head())
            ),
            .table(
                title: String(localized: "replacing(.number(0), with: .number(-1), in: [\"Sales_2024\"]):"),
                data: DemoTableData(dataFrame: try replaced.select("Country", "Sales_2024").head())
            ),
            .table(
                title: String(localized: "Rows with missing Sales_2024 dropped:"),
                data: DemoTableData(dataFrame: try complete.select("Country", "Sales_2024").head())
            )
        ]
    }

    static func renderMissingValues() throws -> String {
        renderText(try executeMissingValues())
    }
}
