//
//  DemoCase+CodeSample.swift
//  BandalDemo
//

import Foundation

extension DemoCase {
    var codeSample: String {
        switch self {
        case .csvOverview:
            """
            let sales = try DataFrame(contentsOfCSV: salesURL)
            print(sales.head())
            print(sales.info())
            print(sales.describe())
            """
        case .headAndTail:
            """
            let first = try sales.head(3)
            let last = try sales.tail(2)
            print(first)
            print(last)
            """
        case .summary:
            """
            let desc = sales.describeStructured()
            print(desc.describe())
            print(sales.info())
            """
        case .missingValues:
            """
            let counts = sales.missingCounts()
            let maskDF = try sales.missingMask()
            let summary = sales.missingSummary()
            let filled = try sales.fillMissing(in: ["Sales_2024"], with: .number(0))
            let replaced = try filled.replacing(.number(0), with: .number(-1), in: ["Sales_2024"])
            let complete = try sales.dropMissing(in: ["Sales_2024"])
            """
        case .derivedColumns:
            """
            let prepared = try filled
                .combining("Sales_2025", "Sales_2024", using: .subtract, as: "Growth_Amount")
                .scaling("Sales_2025", by: 1.1, using: .multiply, as: "Target_2026")
                .ranked("Sales_2025", ascending: false, as: "Sales_Rank")
                .withColumn(name: "Sales_Level") { row in
                    guard let amount = row["Sales_2025"]?.numberValue else { return .missing }
                    return .string(amount >= 1_000_000 ? "High" : "Normal")
                }
            """
        case .filtering:
            """
            let largeSales = try sales.filterRows { row in
                guard let amount = row["Sales_2025"].flatMap(numericValue) else {
                    return false
                }
                return amount >= 1_000_000
            }
            """
        case .joining:
            """
            let enriched = try sales.leftJoin(countryInfo, on: "Country")
            """
        case .regionalAggregation:
            """
            let totals = try enriched
                .groupBy("Region")
                .aggregate("Sales_2025", using: .sum)
            """
        case .factoryAnalysis:
            """
            let prepared = try factory
                .withColumn(name: "Revenue_USD", values: revenue)
                .withColumn(name: "Shipment_Month", values: shipmentMonths)
            let monthly = try prepared
                .groupBy("Shipment_Month")
                .aggregate("Revenue_USD", using: .sum)
            """
        case .numericDataFrame:
            """
            let temperatures = try DataFrame(columns: [
                "temperature": [18.0, 21.5, 19.0],
                "humidity": [0.45, 0.50, 0.48]
            ])
            let selected = try temperatures.select("temperature")
            print(selected)
            print(selected.describe())
            print(selected.info())
            """
        case .csvOptions:
            """
            let options = CSVReadOptions(
                delimiter: ";",
                maximumRows: 100,
                selectedColumns: ["name", "amount"],
                missingTokens: ["", "NA"],
                columnTypes: ["amount": .number]
            )
            let data = try DataFrame(contentsOfCSV: csvURL, options: options)
            try data.writeCSV(to: outputURL, delimiter: ";", includeHeader: false)
            let roundTrip = try DataFrame(contentsOfCSV: outputURL, options: CSVReadOptions(
                delimiter: ";",
                hasHeader: false,
                columnNames: ["name", "amount"],
                missingTokens: ["", "NA"],
                columnTypes: ["amount": .number]
            ))
            """
        case .jsonAndMarkdown:
            """
            let df = try DataFrame(jsonData: jsonData, dateFormat: "yyyy-MM-dd")
            try df.writeJSON(to: jsonURL, prettyPrinted: true)
            let reloaded = try DataFrame(contentsOfJSON: jsonURL, dateFormat: "yyyy-MM-dd")
            let dict = reloaded.toDictionary()
            let compact = sales.render(options: RenderOptions(maxRows: 4, maxColumns: 3, maxColumnWidth: 12))
            let markdown = sales.toMarkdown(maxRows: 4, maxColumns: 4)
            """
        case .queryAndPredicates:
            """
            let queried = try sales.query("Sales_2025 >= 1000000 && Sales_2024 != nil")
            let predicate: RowPredicate =
                .notMissing("Sales_2024")
                && .column("Sales_2025", between: 500_000, and: 1_500_000)
                && !.column("Country", contains: "North", caseSensitive: false)
            let filtered = try sales.query(predicate)
            let firstRow = sales[row: 0]
            let slice = sales[rows: 0..<3]
            let country = sales["Country", 0]?.stringValue
            """
        case .stringsAndDates:
            """
            let strings = try catalog
                .trimmed("product", as: "trimmed")
                .lowercased("trimmed", as: "lower")
                .uppercased("trimmed", as: "upper")
                .stringLength("trimmed", as: "length")
                .replacingSubstring(in: "trimmed", target: "-", with: " ", as: "normalized")
                .containsSubstring("trimmed", "Bandal", caseSensitive: false, as: "is_bandal")
            let dates = try catalog
                .castColumn("launch_date", to: .date, dateFormat: "yyyy-MM-dd")
                .dateComponent(.year, from: "launch_date", as: "year")
                .dateComponent(.month, from: "launch_date", as: "month")
                .dateComponent(.weekday, from: "launch_date", as: "weekday")
            """
        case .tableMaintenance:
            """
            let dupMask = try data.duplicatedRows(in: ["team"], keep: .first)
            let unique = try data.dropDuplicates(in: ["team"], keep: .last)
            let renamed = try unique.renamedColumns(["team": "department"])
            let combined = try DataFrame.concatenatingRows([renamed, moreRows])
            let sampled = try combined.sample(2, seed: 42)
            """
        case .joinStrategies:
            """
            let inner = try left.join(right, on: "id", kind: .inner)
            let full = try left.join(right, on: "id", kind: .full)
            let multiKey = try left.join(
                targets,
                leftOn: ["region", "team"],
                rightOn: ["area", "unit"],
                kind: .left,
                suffixes: (left: "_actual", right: "_target")
            )
            let totals = try left.groupBy("region").aggregate([
                Aggregation("sales", using: .sum),
                Aggregation("sales", using: .median),
                Aggregation("sales", using: .standardDeviation),
                Aggregation("sales", using: .first),
                Aggregation("sales", using: .last),
            ])
            """
        case .typedValues:
            """
            let typed = try DataFrame(contentsOfCSV: csvURL, options: CSVReadOptions(
                columnTypes: ["active": .boolean, "created": .date]
            ))
            let flags = try typed.select(columnsOfType: .boolean)
            let scores = try typed.castColumn("score", to: .number)
            """
        case .reshapeAndWindows:
            """
            let long = try wide.melt(idColumns: ["region", "team"])
            let pivoted = try long.pivotTable(
                index: ["region", "team"], columns: "variable", values: "value", using: .sum
            )
            let exploded = try tagged.exploded("skills", separator: ",")
            let transposed = try wide.select("sales_q1", "sales_q2")
                .transposed(indexColumnName: "quarter", rowPrefix: "team_")
            let timeRolling = try timeSeries.rolling(
                "load", on: "timestamp", interval: 3600, using: .mean
            )
            """
        case .studentAnalysis:
            """
            let ranked = try students.sorted(by: [
                SortDescriptor("score", order: .descending),
                SortDescriptor("attendance")
            ])
            let classSummary = try students
                .groupBy("class")
                .aggregate([
                    Aggregation("name", using: .count),
                    Aggregation("score", using: .mean),
                    Aggregation("score", using: .max)
                ])
            """
        case .cmapssAnalysis:
            """
            let riskSummary = try cmapss
                .groupBy("failure_soon")
                .aggregate([
                    Aggregation("RUL", using: .count),
                    Aggregation("RUL", using: .mean),
                    Aggregation("sensor_2", using: .mean),
                    Aggregation("sensor_4", using: .mean)
                ])
            let nearFailure = try cmapss
                .filterRows { row in
                    guard let rul = row["RUL"].flatMap(numericValue) else { return false }
                    return rul <= 30
                }
                .select("RUL", "sensor_2", "sensor_3", "failure_soon")
                .sorted(by: [SortDescriptor("RUL")])
            """
        case .mimiiAnalysis:
            """
            let byLabel = try mimii
                .groupBy("label")
                .aggregate([
                    Aggregation("rms", using: .mean),
                    Aggregation("spectral_centroid", using: .mean),
                    Aggregation("label", using: .count)
                ])
            let highRMS = try mimii
                .filterRows { $0["label"] == .number(1) }
                .sorted(by: [SortDescriptor("rms", order: .descending)])
                .head(5)
            """
        case .seriesBasics:
            """
            let scores = Series(name: "score", values: [.number(88), .number(92), .missing, .number(92), .number(75)])
            let bonus = Series(name: "bonus", numbers: [2, 3, 5, 1, 5])
            let curved = try (scores + bonus) * 1.05
            let ranked = scores.ranked(ascending: false)
            print(scores.quantile(0.5), scores.mode(), scores.isin([88, 92]), scores.between(lower: 80, upper: 90))
            let counts = try scores.valueCounts()
            """
        case .structuredStatistics:
            """
            let stats = cmapss.statistics()
            let customDesc = cmapss.describeStructured(percentiles: [0.1, 0.5, 0.9], include: [.number])
            let summaryTable = cmapss.summaryTable()
            let missing = cmapss.missingSummary()
            let unique = cmapss.uniqueSummary()
            let dtypes = cmapss.dtypes
            let q90 = try cmapss.quantile(0.9)
            let counts = try cmapss.valueCounts(of: "failure_soon")
            """
        case .correlationAnalysis:
            """
            let engine = try cmapss.select("sensor_2", "sensor_4", "RUL")
            let correlation = try engine.correlation()
            let covariance = try engine.covariance()
            """
        case .sequenceTransforms:
            """
            let running = try prices.cumulative("volume", using: .sum)
            let product = try prices.cumulative("factor", using: .product)
            let previous = try prices.shifted("close")
            let delta = try prices.difference("close")
            let change = try prices.percentChange("close")
            let limited = try prices.clipped("close", lower: 100, upper: 105)
            let rounded = try prices.rounded("close", decimals: 1)
            let forward = try prices.forwardFilled()
            let backward = try prices.backwardFilled()
            """
        case .runtimeBackend:
            """
            print(BandalRuntime.isMLXAvailable, BandalRuntime.executionPolicy, BandalRuntime.executionBackend)
            let cpuMean = try BandalRuntime.withExecutionPolicy(.cpu) {
                try factory.series("Quantity_Tons").mean()
            }
            let vector = try factory.head(5).toMLXVector("Quantity_Tons")
            let rebuilt = try DataFrame(mlxColumns: [(name: "Quantity_Tons", vector: vector)])
            """
        }
    }
}
