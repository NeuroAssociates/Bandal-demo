//
//  QueryAndPredicates.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeQueryAndPredicates() throws -> [DemoResultBlock] {
        let sales = try loadBundledCSV("global_sales_raw")

        let highSalesQuery = try sales.query("Sales_2025 >= 1000000 && Sales_2024 != nil")
            .select("Country", "Sales_2024", "Sales_2025")

        let predicate: RowPredicate =
            .notMissing("Sales_2024")
            && .column("Sales_2025", between: 500_000, and: 1_500_000)
            && !.column("Country", contains: "North", caseSensitive: false)
        let predicateFiltered = try sales.query(predicate)
            .select("Country", "Sales_2024", "Sales_2025")

        let regional: DataFrame = try DataFrame(columns: [
            (name: "region", values: ["APAC", "EMEA", "AMER", "APAC"]),
            (name: "tier", values: ["Gold", "Silver", "Gold", "Bronze"]),
            (name: "revenue", values: [420, 310, 515, 190]),
            (name: "verified", values: [true, true, false, true]),
        ])
        let setPredicate: RowPredicate =
            .column("region", in: ["APAC", "EMEA"])
            && .column("tier", equals: "Gold")
            || .column("revenue", greaterThan: 500)
        let setFiltered = try regional.query(setPredicate)

        let firstRow = sales[row: 0]
        let slice = sales[rows: 0..<3] ?? sales
        let countryCell = sales["Country", 0]?.stringValue ?? "nil"
        let sales2025Cell = sales["Sales_2025", 0]?.numberValue ?? 0
        let firstPositional = firstRow?[0].description ?? "nil"

        let rowAccessDetails = """
        sales.rowCount = \(sales.rowCount), sales.isEmpty = \(sales.isEmpty)
        sales[row: 0]?.index = \(firstRow?.index ?? -1)
        sales[row: 0]?[0] (positional) = \(firstPositional)
        sales["Country", 0]?.stringValue = \(countryCell)
        sales["Sales_2025", 0]?.numberValue = \(sales2025Cell)
        sales.rows.prefix(2) countries = \(sales.rows.prefix(2).compactMap { $0["Country"]?.stringValue })
        """

        return [
            .table(
                title: String(localized: "query(\"Sales_2025 >= 1000000 && Sales_2024 != nil\"):"),
                data: DemoTableData(dataFrame: highSalesQuery)
            ),
            .table(
                title: String(localized: "Composable RowPredicate (between, notMissing, !contains):"),
                data: DemoTableData(dataFrame: predicateFiltered)
            ),
            .table(
                title: String(localized: "Literal DataValue columns & RowPredicate (.in, &&, ||):"),
                data: DemoTableData(dataFrame: setFiltered)
            ),
            .text(
                title: String(localized: "DataRow & cell subscript access (df[row:], df[col, row], DataValue properties):"),
                content: rowAccessDetails
            ),
            .table(
                title: String(localized: "Row range subscript (sales[rows: 0..<3]):"),
                data: DemoTableData(dataFrame: try slice.select("Country", "Sales_2024", "Sales_2025"))
            ),
        ]
    }

    static func renderQueryAndPredicates() throws -> String {
        renderText(try executeQueryAndPredicates())
    }
}
