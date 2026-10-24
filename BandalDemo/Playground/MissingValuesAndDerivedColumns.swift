import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")
        let filledSales = try sales.fillMissing(in: ["Sales_2024"], with: .number(0))
        let preparedSales = try filledSales
            .combining("Sales_2025", "Sales_2024", using: .subtract, as: "Growth_Amount")
            .scaling("Sales_2025", by: 1.1, using: .multiply, as: "Target_2026")
            .rounded("Target_2026", decimals: 0)
            .ranked("Sales_2025", ascending: false, as: "Sales_Rank")
            .withColumn(name: "Sales_Level") { row in
                guard let amount = row["Sales_2025"]?.numberValue else { return .missing }
                return .string(amount >= 1_000_000 ? "High" : "Normal")
            }
        let largeSales = try preparedSales.query("Sales_2025 >= 1000000")

        print("=== Missing values and derived sales columns ===")
        print("missingSummary().totalMissing = \(sales.missingSummary().totalMissing)")
        print("missingMask() head:\n\(try sales.select("Country", "Sales_2024", "Sales_2025").missingMask().head(5))")
        print("Countries with 2025 sales >= $1M:\n\(try largeSales.select("Country", "Sales_2025").head(10))")
        print("Derived sales columns:\n\(try preparedSales.select("Country", "Growth_Amount", "Target_2026", "Sales_Rank", "Sales_Level").head(5))")

        let sample = try DataFrame(columns: [
            (name: "group", values: [.string("A"), .string("A"), .string("B"), .string("B")]),
            (name: "measurement", values: [.number(10), .missing, .number(20), .number(30)]),
        ])
        let missingMask = try sample.isMissing(in: "measurement")
        let filled = try sample.fillMissing(in: ["measurement"], with: .number(0))
        let replaced = try filled.replacing(.number(0), with: .number(-1), in: ["measurement"])
        let complete = try sample.dropMissing(in: ["measurement"])
        guard let summary = sample.summary()["measurement"] else {
            throw DataFrameError.emptyColumns
        }
        try PlaygroundSupport.validate(
            missingMask == [false, true, false, false],
            "missing-value mask mismatch"
        )
        try PlaygroundSupport.validate(
            sample.missingCounts()["measurement", default: 0] == 1,
            "missing count mismatch"
        )
        try PlaygroundSupport.validate(
            try filled.values(in: "measurement")
                == [.number(10), .number(0), .number(20), .number(30)],
            "fillMissing result mismatch"
        )
        try PlaygroundSupport.validate(complete.rowCount == 3, "dropMissing result mismatch")
        try PlaygroundSupport.validate(
            summary.count == 3
                && summary.mean == 20
                && summary.median == 20
                && summary.standardDeviation == 10,
            "numeric summary statistics mismatch"
        )
        print("Validation passed: missing mask/count, fill, replacing, drop, mean, median, and sample standard deviation.")
        print("Missing counts: \(sample.missingCounts())")
        print("Filled sample:\n\(filled)")
        print("Replaced 0 -> -1:\n\(replaced)")
        print("Rows after dropping missing measurements:\n\(complete)")
    } catch {
        print("Missing-value analysis failed: \(error.localizedDescription)")
    }
}
