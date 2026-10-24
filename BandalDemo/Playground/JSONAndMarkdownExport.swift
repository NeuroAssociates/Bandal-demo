import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
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

        let jsonURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        defer { try? FileManager.default.removeItem(at: jsonURL) }

        try fromRecords.writeJSON(to: jsonURL, prettyPrinted: true)
        let roundTrip = try DataFrame(contentsOfJSON: jsonURL, dateFormat: "yyyy-MM-dd")
        let prettyJSON = String(
            decoding: try fromColumns.jsonData(prettyPrinted: true),
            as: UTF8.self
        )

        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")
        let compactRendered = sales.render(
            options: RenderOptions(maxRows: 4, maxColumns: 3, maxColumnWidth: 12)
        )
        let markdown = sales.toMarkdown(maxRows: 4, maxColumns: 4)

        print("=== JSON I/O ===")
        print("Loaded from JSON records array:\n\(fromRecords)")
        print("Loaded from column-oriented JSON:\n\(fromColumns)")
        print("JSON file round-trip:\n\(roundTrip)")
        print("Exported pretty JSON:\n\(prettyJSON)")
        print("toDictionary() keys: \(fromColumns.toDictionary().keys.sorted())")

        print("\n=== Custom RenderOptions and Markdown export ===")
        print("render(options:):\n\(compactRendered)")
        print("toMarkdown(maxRows: 4, maxColumns: 4):\n\(markdown)")
    } catch {
        print("JSON and Markdown playground failed: \(error.localizedDescription)")
    }
}
