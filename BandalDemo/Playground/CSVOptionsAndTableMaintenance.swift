import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")
        let csvURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        let headerlessURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        defer {
            try? FileManager.default.removeItem(at: csvURL)
            try? FileManager.default.removeItem(at: headerlessURL)
        }

        try sales.select("Country", "Sales_2025").writeCSV(to: csvURL)
        let roundTrip = try DataFrame(contentsOfCSV: csvURL)
        try PlaygroundSupport.validate(
            roundTrip.rowCount == sales.rowCount
                && roundTrip.columnNames == ["Country", "Sales_2025"],
            "CSV write/read round trip mismatch"
        )
        let selectedCSV = try DataFrame(
            contentsOfCSV: PlaygroundSupport.csvURL("global_sales_raw"),
            options: CSVReadOptions(
                maximumRows: 5,
                selectedColumns: ["Country", "Sales_2025"],
                columnTypes: ["Sales_2025": .number]
            )
        )
        try Data("North;NA\nSouth;22\n".utf8).write(to: headerlessURL)
        let headerlessCSV = try DataFrame(
            contentsOfCSV: headerlessURL,
            options: CSVReadOptions(
                delimiter: ";",
                hasHeader: false,
                columnNames: ["team", "amount"],
                missingTokens: ["NA"],
                infersNumbers: false
            )
        )

        print("=== CSV options and round-trip ===")
        print("Selected-column read with explicit type and row limit:\n\(selectedCSV)")
        print("CSV round-trip shape: \(roundTrip.shape)")
        print("Headerless CSV with explicit names and missing token:\n\(headerlessCSV)")

        let batchOne = try DataFrame(columns: [
            (name: "team", values: ["A", "A", "B"].map(DataValue.string)),
            (name: "score", values: [80, 90, 75].map(DataValue.number)),
        ])
        let batchTwo = try DataFrame(columns: [
            (name: "team", values: ["C", "D"].map(DataValue.string)),
            (name: "score", values: [88, 94].map(DataValue.number)),
        ])
        let duplicateMask = try batchOne.duplicatedRows(in: ["team"], keep: .first)
        let uniqueTeams = try batchOne.dropDuplicates(in: ["team"], keep: .last)
        let normalizedBatch = try uniqueTeams.renamedColumns(["team": "department"])
        let nextNormalizedBatch = try batchTwo.renamedColumns(["team": "department"])
        let combinedBatches = try DataFrame.concatenatingRows([
            normalizedBatch,
            nextNormalizedBatch,
        ])
        let sampled = try combinedBatches.sample(2, seed: 42)

        print("\n=== Deduplication, renaming, row concatenation, and sampling ===")
        print("Duplicate mask (keep: .first): \(duplicateMask)")
        print("After keep-last duplicate removal and rename:\n\(normalizedBatch)")
        print("Combined batches:\n\(combinedBatches)")
        print("Reproducible sample(2, seed: 42):\n\(sampled)")
    } catch {
        print("CSV options and table maintenance examples failed: \(error.localizedDescription)")
    }
}
