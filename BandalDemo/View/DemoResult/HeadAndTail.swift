//
//  HeadAndTail.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeHeadAndTail() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        return [
            .table(
                title: String(localized: "First 3 rows:"),
                data: DemoTableData(dataFrame: try sales.head(3))
            ),
            .table(
                title: String(localized: "Last 2 rows:"),
                data: DemoTableData(dataFrame: try sales.tail(2))
            )
        ]
    }

    static func renderHeadAndTail() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")
        return """
            \(String(localized: "First 3 rows:"))
            \(try sales.head(3))

            \(String(localized: "Last 2 rows:"))
            \(try sales.tail(2))
            """
    }
}
