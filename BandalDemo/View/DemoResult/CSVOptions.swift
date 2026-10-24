//
//  CSVOptions.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeCSVOptions() throws -> [DemoResultBlock] {
        let source = """
        name;amount;active
        "North, team";1200.5;true
        South;;false
        """
        let inputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        let headerlessURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        defer {
            try? FileManager.default.removeItem(at: inputURL)
            try? FileManager.default.removeItem(at: outputURL)
            try? FileManager.default.removeItem(at: headerlessURL)
        }
        try Data(source.utf8).write(to: inputURL)
        let options = CSVReadOptions(
            delimiter: ";",
            selectedColumns: ["name", "amount"],
            columnTypes: ["amount": .number]
        )
        let parsed = try DataFrame(contentsOfCSV: inputURL, options: options)
        try parsed.writeCSV(to: outputURL, delimiter: ";", includeHeader: false)
        let roundTrip = try DataFrame(contentsOfCSV: outputURL, options: CSVReadOptions(
            delimiter: ";",
            hasHeader: false,
            columnNames: ["name", "amount"],
            missingTokens: ["", "NA"],
            columnTypes: ["amount": .number]
        ))
        try Data("North;NA\nSouth;22\n".utf8).write(to: headerlessURL)
        let headerless = try DataFrame(
            contentsOfCSV: headerlessURL,
            options: CSVReadOptions(
                delimiter: ";",
                hasHeader: false,
                columnNames: ["name", "amount"],
                missingTokens: ["NA"],
                infersNumbers: false
            )
        )
        try validateDemo(
            roundTrip.columnNames == parsed.columnNames
                && roundTrip.rowCount == parsed.rowCount
                && (try roundTrip.values(in: "amount")) == (try parsed.values(in: "amount")),
            "CSV write/read round trip mismatch"
        )
        return [
            .text(
                title: String(localized: "CSV parse options:"),
                content: """
                \(String(localized: "Read options: delimiter=semicolon, selectedColumns=name/amount,"))
                \(String(localized: "amount explicitly parsed as number."))
                """
            ),
            .table(
                title: String(localized: "Parsed values:"),
                data: DemoTableData(dataFrame: parsed)
            ),
            .table(
                title: String(localized: "CSV write/read round trip:"),
                data: DemoTableData(dataFrame: roundTrip)
            ),
            .table(
                title: String(localized: "Headerless input with explicit names and NA missing token:"),
                data: DemoTableData(dataFrame: headerless)
            )
        ]
    }

    static func renderCSVOptions() throws -> String {
        let source = """
        name;amount;active
        "North, team";1200.5;true
        South;;false
        """
        let inputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        let headerlessURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("csv")
        defer {
            try? FileManager.default.removeItem(at: inputURL)
            try? FileManager.default.removeItem(at: outputURL)
            try? FileManager.default.removeItem(at: headerlessURL)
        }
        try Data(source.utf8).write(to: inputURL)
        let options = CSVReadOptions(
            delimiter: ";",
            selectedColumns: ["name", "amount"],
            columnTypes: ["amount": .number]
        )
        let parsed = try DataFrame(contentsOfCSV: inputURL, options: options)
        try parsed.writeCSV(to: outputURL, delimiter: ";", includeHeader: false)
        let roundTrip = try DataFrame(contentsOfCSV: outputURL, options: CSVReadOptions(
            delimiter: ";",
            hasHeader: false,
            columnNames: ["name", "amount"],
            missingTokens: ["", "NA"],
            columnTypes: ["amount": .number]
        ))
        try Data("North;NA\nSouth;22\n".utf8).write(to: headerlessURL)
        let headerless = try DataFrame(
            contentsOfCSV: headerlessURL,
            options: CSVReadOptions(
                delimiter: ";",
                hasHeader: false,
                columnNames: ["name", "amount"],
                missingTokens: ["NA"],
                infersNumbers: false
            )
        )
        try validateDemo(
            roundTrip.columnNames == parsed.columnNames
                && roundTrip.rowCount == parsed.rowCount
                && (try roundTrip.values(in: "amount")) == (try parsed.values(in: "amount")),
            "CSV write/read round trip mismatch"
        )
        return """
        \(String(localized: "Read options: delimiter=semicolon, selectedColumns=name/amount,"))
        \(String(localized: "amount explicitly parsed as number."))

        \(String(localized: "Parsed values:"))
        \(parsed)

        \(String(localized: "CSV write/read round trip:"))
        \(roundTrip)

        \(String(localized: "Headerless input with explicit names and NA missing token:"))
        \(headerless)
        """
    }
}
