import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")

        let queried = try sales
            .query("Sales_2025 >= 1000000 && Sales_2024 != nil")
            .select("Country", "Sales_2024", "Sales_2025")

        let predicate: RowPredicate =
            .notMissing("Sales_2024")
            && .column("Sales_2025", between: 500_000, and: 1_500_000)
            && !.column("Country", contains: "North", caseSensitive: false)
        let filteredByPredicate = try sales
            .query(predicate)
            .select("Country", "Sales_2024", "Sales_2025")

        let regional = try DataFrame(columns: [
            (name: "region", values: ["APAC", "EMEA", "AMER", "APAC"]),
            (name: "tier", values: ["Gold", "Silver", "Gold", "Bronze"]),
            (name: "revenue", values: [420, 310, 515, 190]),
            (name: "verified", values: [true, true, false, true]),
        ])
        let setFiltered = try regional.query(
            .column("region", in: ["APAC", "EMEA"])
                && .column("tier", equals: "Gold")
                || .column("revenue", greaterThan: 500)
        )

        print("=== String query() and composable RowPredicate ===")
        print("String query result:\n\(queried)")
        print("Composable RowPredicate result:\n\(filteredByPredicate)")
        print("Set membership & boolean literal DataFrame query:\n\(setFiltered)")

        print("\n=== DataRow, row slices, and typed cell access ===")
        if let firstRow = sales[row: 0] {
            print("First DataRow: \(firstRow)")
            print("Positional cell [0]: \(firstRow[0])")
            print("Named cell [\"Country\"]: \(firstRow["Country"]?.stringValue ?? "nil")")
        }
        print("Cell subscript sales[\"Sales_2025\", 0]?.numberValue = \(sales["Sales_2025", 0]?.numberValue ?? 0)")
        if let slice = sales[rows: 0..<3] {
            print("Row slice sales[rows: 0..<3]:\n\(try slice.select("Country", "Sales_2025"))")
        }
    } catch {
        print("Query, predicates, and row access playground failed: \(error.localizedDescription)")
    }
}
