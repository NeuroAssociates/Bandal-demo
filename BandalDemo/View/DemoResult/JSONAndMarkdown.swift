//
//  JSONAndMarkdown.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeJSONAndMarkdown() throws -> [DemoResultBlock] {
        let recordsJSON = """
        [
          {"country": "Korea", "sales": 1250.5, "active": true, "updated": "2025-03-01"},
          {"country": "Japan", "sales": 980.0, "active": true, "updated": "2025-03-15"},
          {"country": "Germany", "sales": null, "active": false, "updated": "2025-04-01"}
        ]
        """
        let fromRecords = try DataFrame(
            jsonData: Data(recordsJSON.utf8),
            dateFormat: "yyyy-MM-dd"
        )

        let columnJSON = """
        {
          "team": ["Alpha", "Beta", "Gamma"],
          "score": [91, 84, 96]
        }
        """
        let fromColumns = try DataFrame(jsonData: Data(columnJSON.utf8))

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        try fromRecords.writeJSON(to: tempURL, prettyPrinted: true)
        let roundTrip = try DataFrame(contentsOfJSON: tempURL, dateFormat: "yyyy-MM-dd")
        let exportedJSON = String(
            decoding: try fromColumns.jsonData(prettyPrinted: true),
            as: UTF8.self
        )

        let dictionary = fromColumns.toDictionary()
        let dictionaryPreview = fromColumns.columnNames.map { name in
            "\(name): \(dictionary[name] ?? [])"
        }.joined(separator: "\n")

        let sales = try loadBundledCSV("global_sales_raw")
        let customRendered = sales.render(
            options: RenderOptions(maxRows: 4, maxColumns: 3, maxColumnWidth: 12)
        )
        let markdownTable = sales.toMarkdown(maxRows: 4, maxColumns: 4)

        try validateDemo(
            roundTrip.rowCount == fromRecords.rowCount
                && roundTrip.columnNames == fromRecords.columnNames,
            "JSON write/read round trip mismatch"
        )

        return [
            .table(
                title: String(localized: "DataFrame loaded from JSON records array (with dateFormat):"),
                data: DemoTableData(dataFrame: fromRecords)
            ),
            .table(
                title: String(localized: "DataFrame loaded from column-oriented JSON object:"),
                data: DemoTableData(dataFrame: fromColumns)
            ),
            .table(
                title: String(localized: "JSON file writeJSON / contentsOfJSON round-trip:"),
                data: DemoTableData(dataFrame: roundTrip)
            ),
            .text(
                title: String(localized: "jsonData(prettyPrinted: true) output:"),
                content: exportedJSON
            ),
            .text(
                title: String(localized: "toDictionary() column snapshot:"),
                content: dictionaryPreview
            ),
            .text(
                title: String(localized: "render(options: RenderOptions(maxRows: 4, maxColumns: 3, maxColumnWidth: 12)):"),
                content: customRendered
            ),
            .text(
                title: String(localized: "toMarkdown(maxRows: 4, maxColumns: 4):"),
                content: markdownTable
            ),
        ]
    }

    static func renderJSONAndMarkdown() throws -> String {
        renderText(try executeJSONAndMarkdown())
    }
}
