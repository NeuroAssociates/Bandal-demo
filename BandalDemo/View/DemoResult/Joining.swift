//
//  Joining.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeJoining() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        return [
            .text(
                title: String(localized: "Joined metadata:"),
                content: """
                \(String(localized: "Joined shape:")) \(enriched.shape)

                \(enriched.info())
                """
            ),
            .table(
                title: String(localized: "Joined preview:"),
                data: DemoTableData(dataFrame: try enriched.head())
            )
        ]
    }

    static func renderJoining() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        return """
        \(String(localized: "Joined shape:")) \(enriched.shape)
        \(enriched.info())

        \(String(localized: "Joined preview:"))
        \(try enriched.head())
        """
    }
}
