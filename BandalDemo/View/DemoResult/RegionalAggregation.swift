//
//  RegionalAggregation.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeRegionalAggregation() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        let regionalSales = try enriched
            .groupBy("Region")
            .aggregate("Sales_2025", using: .sum)
        let countriesByTeam = try enriched
            .groupBy("Team")
            .aggregate("Country", using: .count)
        return [
            .table(
                title: String(localized: "Sales by region:"),
                data: DemoTableData(dataFrame: regionalSales)
            ),
            .table(
                title: String(localized: "Countries by team:"),
                data: DemoTableData(dataFrame: countriesByTeam)
            )
        ]
    }

    static func renderRegionalAggregation() throws -> String {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        let regionalSales = try enriched
            .groupBy("Region")
            .aggregate("Sales_2025", using: .sum)
        let countriesByTeam = try enriched
            .groupBy("Team")
            .aggregate("Country", using: .count)
        return """
        \(String(localized: "Sales by region:"))
        \(regionalSales)

        \(String(localized: "Countries by team:"))
        \(countriesByTeam)
        """
    }
}
