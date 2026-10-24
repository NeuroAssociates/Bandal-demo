//
//  BandalDemoTests.swift
//  BandalDemoTests
//
//  Created by Ned Park on 10/21/26.
//

import Foundation
import Testing
@testable import Bandal
@testable import BandalDemo

@Suite("BandalDemo Validation Tests")
struct BandalDemoTests {
    
    // MARK: - Helper Functions
    
    private func loadBundledCSV(_ name: String, maximumRows: Int? = nil) throws -> DataFrame {
        guard let url = Bundle.main.url(forResource: name, withExtension: "csv") else {
            throw DataFrameError.invalidCSV("Bundled resource '\(name).csv' was not found.")
        }
        if let maximumRows {
            return try DataFrame(contentsOfCSV: url, maximumRows: maximumRows)
        }
        return try DataFrame(contentsOfCSV: url)
    }
    
    private func numericValue(_ value: DataValue) -> Double? {
        guard case .number(let number) = value else { return nil }
        return number
    }
    
    // MARK: - CSV Loading and Inspection Tests
    
    @Test("Load and inspect global sales CSV")
    func testCSVOverview() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        #expect(sales.rowCount == 10)
        #expect(sales.columnNames.contains("Country"))
        #expect(sales.columnNames.contains("Sales_2024"))
        #expect(sales.columnNames.contains("Sales_2025"))
        
        let countryInfo = try loadBundledCSV("country_info")
        #expect(countryInfo.rowCount == 10)
        #expect(countryInfo.columnNames.contains("Region"))
        #expect(countryInfo.columnNames.contains("Team"))
        
        let factory = try loadBundledCSV("factory_data", maximumRows: 5000)
        #expect(factory.rowCount == 5000)
        #expect(factory.columnNames.contains("Shipment_Date"))
        #expect(factory.columnNames.contains("Quantity_Tons"))
        #expect(factory.columnNames.contains("Unit_Price_USD_per_Ton"))
    }
    
    @Test("View first and last rows")
    func testHeadAndTail() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let first = try sales.head(3)
        #expect(first.rowCount == 3)
        #expect(first.columnNames == sales.columnNames)
        
        let last = try sales.tail(2)
        #expect(last.rowCount == 2)
        #expect(last.columnNames == sales.columnNames)
    }
    
    @Test("Numeric column summary statistics")
    func testSummary() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let description = sales.describe()
        #expect(!description.isEmpty)
        
        let info = sales.info()
        #expect(!info.isEmpty)
        #expect(info.contains("DataFrame"))
    }
    
    // MARK: - Missing Values Tests
    
    @Test("Inspect and fill missing values")
    func testMissingValues() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let missingMask = try sales.isMissing(in: "Sales_2024")
        #expect(missingMask.count == sales.rowCount)
        #expect(missingMask.filter { $0 }.count == sales.missingCounts()["Sales_2024", default: 0])
        
        let fullMask = try sales.missingMask()
        #expect(fullMask.rowCount == sales.rowCount)
        #expect(sales.missingSummary().totalMissing >= 1)
        
        let filled = try sales.fillMissing(in: ["Sales_2024"], with: .number(0))
        #expect(filled.missingCounts()["Sales_2024", default: 0] == 0)
        
        let replaced = try filled.replacing(.number(0), with: .number(-1), in: ["Sales_2024"])
        #expect(try replaced.values(in: "Sales_2024").contains(.number(-1)))
        
        let complete = try sales.dropMissing(in: ["Sales_2024"])
        #expect(complete.rowCount + sales.missingCounts()["Sales_2024", default: 0] == sales.rowCount)
        
        // Test synthetic data
        let synthetic = try DataFrame(columns: [
            (name: "measurement", values: [.number(10), .missing, .number(20), .number(30)])
        ])
        guard let summary = synthetic.summary()["measurement"] else {
            Issue.record("Numeric summary was not returned")
            return
        }
        #expect(summary.count == 3)
        #expect(summary.mean == 20)
        #expect(summary.median == 20)
        #expect(summary.standardDeviation == 10)
    }
    
    // MARK: - Derived Columns Tests
    
    @Test("Create calculated and categorized columns")
    func testDerivedColumns() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let filled = try sales.fillMissing(in: ["Sales_2024"], with: .number(0))
        let prepared = try filled
            .combining("Sales_2025", "Sales_2024", using: .subtract, as: "Growth_Amount")
            .scaling("Sales_2025", by: 1.1, using: .multiply, as: "Target_2026")
            .ranked("Sales_2025", ascending: false, as: "Sales_Rank")
            .withColumn(name: "Sales_Level") { row in
                guard let amount = row["Sales_2025"]?.numberValue else { return .missing }
                return .string(amount >= 1_000_000 ? "High" : "Normal")
            }
        let selected = try prepared.select("Country", "Growth_Amount", "Target_2026", "Sales_Rank", "Sales_Level")
        #expect(selected.rowCount == sales.rowCount)
        #expect(selected.columnNames.contains("Growth_Amount"))
        #expect(selected.columnNames.contains("Target_2026"))
        #expect(selected.columnNames.contains("Sales_Rank"))
        #expect(selected.columnNames.contains("Sales_Level"))
    }
    
    // MARK: - Filtering Tests
    
    @Test("Filter rows by condition")
    func testFiltering() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let largeSales = try sales.filterRows { row in
            guard let amount = row["Sales_2025"].flatMap(numericValue) else {
                return false
            }
            return amount >= 1_000_000
        }
        #expect(largeSales.rowCount == 3)
        let selected = try largeSales.select("Country", "Sales_2025")
        #expect(selected.rowCount == 3)
    }
    
    // MARK: - JSON, Markdown, Query, and Strings/Dates Tests
    
    @Test("JSON I/O, RenderOptions, and Markdown export")
    func testJSONAndMarkdown() throws {
        let recordsJSON = """
        [
          {"country": "Korea", "sales": 1250.5, "active": true, "updated": "2025-03-01"},
          {"country": "Japan", "sales": 980.0, "active": true, "updated": "2025-03-15"}
        ]
        """
        let df = try DataFrame(jsonData: Data(recordsJSON.utf8), dateFormat: "yyyy-MM-dd")
        #expect(df.rowCount == 2)
        #expect(try df.dataType(of: "updated") == .date)
        
        let exported = try df.jsonData(prettyPrinted: true)
        let reloaded = try DataFrame(jsonData: exported, dateFormat: "yyyy-MM-dd")
        #expect(reloaded.rowCount == 2)
        #expect(reloaded.toDictionary()["country"]?.count == 2)
        
        let md = df.toMarkdown(maxRows: 2, maxColumns: 3)
        #expect(md.contains("|"))
        let rendered = df.render(options: RenderOptions(maxRows: 2, maxColumns: 2, maxColumnWidth: 8))
        #expect(!rendered.isEmpty)
    }
    
    @Test("Query expressions, RowPredicate, and DataRow access")
    func testQueryAndPredicates() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let queried = try sales.query("Sales_2025 >= 1000000 && Sales_2024 != nil")
        #expect(queried.rowCount >= 1)
        
        let predicate: RowPredicate =
            .notMissing("Sales_2024")
            && .column("Sales_2025", between: 500_000, and: 1_500_000)
        let byPred = try sales.query(predicate)
        #expect(byPred.rowCount >= 1)
        
        #expect(sales[row: 0]?.index == 0)
        #expect(sales[rows: 0..<3]?.rowCount == 3)
        #expect(sales["Country", 0]?.stringValue != nil)
    }
    
    @Test("String operations, DateComponent extraction, and vectorized math")
    func testStringsAndDates() throws {
        let catalog = try DataFrame(columns: [
            (name: "product", values: ["  Bandal Pro-X  ", "  bandal mini-s "]),
            (name: "launch_date", values: ["2025-01-15", "2025-06-20"]),
            (name: "price", values: [120.0, 80.0]),
            (name: "cost", values: [75.0, 90.0]),
        ])
        let processed = try catalog
            .trimmed("product")
            .lowercased("product", as: "lower")
            .uppercased("product", as: "upper")
            .stringLength("product", as: "length")
            .replacingSubstring(in: "product", target: "-", with: " ", as: "normalized")
            .containsSubstring("product", "Bandal", caseSensitive: false, as: "is_bandal")
            .castColumn("launch_date", to: .date, dateFormat: "yyyy-MM-dd")
            .dateComponent(.year, from: "launch_date", as: "year")
            .dateComponent(.month, from: "launch_date", as: "month")
            .combining("price", "cost", using: .subtract, as: "margin")
            .abs("margin")
        #expect(processed["year", 0]?.numberValue == 2025)
        #expect(processed["is_bandal", 1]?.boolValue == true)
        #expect(processed["margin", 1]?.numberValue == 10.0)
    }
    
    // MARK: - Joining Tests
    
    @Test("Join country information")
    func testJoining() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        #expect(enriched.rowCount == sales.rowCount)
        #expect(enriched.columnNames.contains("Region"))
        #expect(enriched.columnNames.contains("Team"))
        #expect(enriched.shape[1] == sales.columnNames.count + countryInfo.columnNames.count - 1)
    }
    
    // MARK: - Grouping and Aggregation Tests
    
    @Test("Aggregate by region and team")
    func testRegionalAggregation() throws {
        let sales = try loadBundledCSV("global_sales_raw")
        let countryInfo = try loadBundledCSV("country_info")
        let enriched = try sales.leftJoin(countryInfo, on: "Country")
        let regionalSales = try enriched
            .groupBy("Region")
            .aggregate("Sales_2025", using: .sum)
        #expect(regionalSales.rowCount > 0)
        #expect(regionalSales.columnNames.contains("Region"))
        #expect(regionalSales.columnNames.contains("Sales_2025_sum"))
        
        let countriesByTeam = try enriched
            .groupBy("Team")
            .aggregate("Country", using: .count)
        #expect(countriesByTeam.rowCount > 0)
    }
    
    @Test("Analyze factory shipments")
    func testFactoryAnalysis() throws {
        let factory = try loadBundledCSV("factory_data", maximumRows: 5000)
        let quantities = try factory.values(in: "Quantity_Tons")
        let prices = try factory.values(in: "Unit_Price_USD_per_Ton")
        let revenue = zip(quantities, prices).map { quantity, price in
            guard let quantity = numericValue(quantity),
                  let price = numericValue(price)
            else {
                return DataValue.missing
            }
            return DataValue.number(quantity * price)
        }
        let months = try factory.values(in: "Shipment_Date").map { value -> DataValue in
            guard case .string(let date) = value, date.count >= 7 else {
                return .missing
            }
            return .string(String(date.prefix(7)))
        }
        let prepared = try factory
            .withColumn(name: "Revenue_USD", values: revenue)
            .withColumn(name: "Shipment_Month", values: months)
        let monthlyRevenue = try prepared
            .groupBy("Shipment_Month")
            .aggregate("Revenue_USD", using: .sum)
        #expect(monthlyRevenue.rowCount > 0)
        
        let departmentShipments = try prepared
            .groupBy("Division")
            .aggregate("Quantity_Tons", using: .sum)
        #expect(departmentShipments.rowCount > 0)
    }
    
    // MARK: - Numeric DataFrame Tests
    
    @Test("Create a numeric DataFrame")
    func testNumericDataFrame() throws {
        let temperatures = try DataFrame(columns: [
            "temperature": [18.0, 21.5, 19.0],
            "humidity": [0.45, 0.50, 0.48]
        ])
        #expect(temperatures.rowCount == 3)
        #expect(temperatures.columnNames.sorted() == ["humidity", "temperature"])
        
        let selected = try temperatures.select("temperature")
        #expect(selected.columnNames == ["temperature"])
        #expect(try selected.column("temperature") == [18.0, 21.5, 19.0])
        
        let description = selected.describe()
        #expect(!description.isEmpty)
        let info = selected.info()
        #expect(!info.isEmpty)
    }
    
    // MARK: - CSV Options Tests
    
    @Test("CSV options and round-trip")
    func testCSVOptions() throws {
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
        #expect(parsed.columnNames == ["name", "amount"])
        #expect(parsed.rowCount == 2)
        
        try parsed.writeCSV(to: outputURL, delimiter: ";", includeHeader: false)
        let roundTrip = try DataFrame(contentsOfCSV: outputURL, options: CSVReadOptions(
            delimiter: ";",
            hasHeader: false,
            columnNames: ["name", "amount"],
            missingTokens: ["", "NA"],
            columnTypes: ["amount": .number]
        ))
        #expect(roundTrip.columnNames == parsed.columnNames)
        #expect(roundTrip.rowCount == parsed.rowCount)
        #expect(try roundTrip.values(in: "amount") == (try parsed.values(in: "amount")))
        
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
        #expect(headerless.rowCount == 2)
        #expect(headerless.columnNames == ["name", "amount"])
    }
    
    // MARK: - Table Maintenance Tests
    
    @Test("Deduplicate, rename, concatenate, and sample")
    func testTableMaintenance() throws {
        let first = try DataFrame(columns: [
            (name: "team", values: [.string("A"), .string("A"), .string("B")]),
            (name: "score", values: [80, 90, 75].map(DataValue.number))
        ])
        let nextBatch = try DataFrame(columns: [
            (name: "team", values: [.string("C")]),
            (name: "score", values: [.number(88)])
        ])
        let dupMask = try first.duplicatedRows(in: ["team"], keep: .first)
        #expect(dupMask == [false, true, false])
        let uniqueTeams = try first.dropDuplicates(in: ["team"], keep: .last)
        #expect(uniqueTeams.rowCount == 2)
        let renamed = try uniqueTeams.renamedColumns(["team": "department"])
        #expect(renamed.columnNames.contains("department"))
        #expect(!renamed.columnNames.contains("team"))
        let combined = try DataFrame.concatenatingRows([renamed, nextBatch.renamedColumns(["team": "department"])])
        #expect(combined.rowCount == 3)
        let sampled = try combined.sample(2, seed: 42)
        #expect(sampled.rowCount == 2)
    }
    
    // MARK: - Join Strategies Tests
    
    @Test("Join types, multi-key joins, and multiple aggregations")
    func testJoinStrategies() throws {
        let left = try DataFrame(columns: [
            (name: "id", values: [1, 2, 3].map(DataValue.number)),
            (name: "region", values: ["West", "West", "East"].map(DataValue.string)),
            (name: "team", values: ["A", "B", "A"].map(DataValue.string)),
            (name: "sales", values: [100, 150, 80].map(DataValue.number))
        ])
        let right = try DataFrame(columns: [
            (name: "id", values: [2, 3, 4].map(DataValue.number)),
            (name: "manager", values: ["Mina", "Jin", "Ara"].map(DataValue.string))
        ])
        let inner = try left.join(right, on: "id", kind: .inner)
        #expect(inner.rowCount == 2)
        
        let full = try left.join(right, on: "id", kind: .full)
        #expect(full.rowCount == 4)
        
        let targets = try DataFrame(columns: [
            (name: "area", values: ["West", "East"].map(DataValue.string)),
            (name: "sales", values: [120, 75].map(DataValue.number)),
        ])
        let multiKey = try left.join(
            targets,
            leftOn: ["region"],
            rightOn: ["area"],
            kind: .left,
            suffixes: (left: "_actual", right: "_target")
        )
        #expect(multiKey.columnNames.contains("sales_actual"))
        #expect(multiKey.columnNames.contains("sales_target"))
        
        let multiAggregation = try left
            .groupBy("region", "team")
            .aggregate([
                Aggregation("sales", using: .sum),
                Aggregation("sales", using: .count),
                Aggregation("sales", using: .mean)
            ])
        #expect(multiAggregation.rowCount == 3)
        #expect(multiAggregation.columnNames.contains("sales_sum"))
        #expect(multiAggregation.columnNames.contains("sales_count"))
        #expect(multiAggregation.columnNames.contains("sales_mean"))
        
        let qualifyingGroups = try multiAggregation.filterRows { row in
            guard let mean = row["sales_mean"].flatMap(numericValue) else {
                return false
            }
            return mean >= 100
        }
        #expect(qualifyingGroups.rowCount >= 1)
    }
    
    // MARK: - Typed Values Tests
    
    @Test("Convert boolean and date values")
    func testTypedValues() throws {
        let raw = try DataFrame(columns: [
            (name: "enabled_text", values: [.string("true"), .string("false"), .missing]),
            (name: "amount_text", values: [.string("$1,250"), .string("48.5"), .missing]),
            (name: "created_text", values: [
                .string("2024/01/02"), .string("2024/02/15"), .missing
            ])
        ])
        let converted = try raw
            .castColumn("enabled_text", to: .boolean)
            .castColumn("amount_text", to: .number)
            .castColumn("created_text", to: .date, dateFormat: "yyyy/MM/dd")
        #expect(try converted.dataType(of: "enabled_text") == .boolean)
        #expect(try converted.dataType(of: "amount_text") == .number)
        #expect(try converted.dataType(of: "created_text") == .date)
        
        let flags = try converted.select(columnsOfType: .boolean)
        #expect(flags.rowCount == converted.rowCount)
        
        let raw2 = try DataFrame(columns: [
            (name: "active", values: [.string("true"), .string("false")])
        ])
        let typed = try raw2.castColumn("active", to: .boolean)
        #expect(try typed.dataType(of: "active") == .boolean)
    }
    
    // MARK: - Reshaping and Window Tests
    
    @Test("Melt, pivot, explode, transpose, group transforms, and window statistics")
    func testReshapeAndWindows() throws {
        let wide = try DataFrame(columns: [
            (name: "region", values: ["West", "West", "East", "East"].map(DataValue.string)),
            (name: "team", values: ["A", "B", "A", "B"].map(DataValue.string)),
            (name: "sales_q1", values: [10, 20, 30, 40].map(DataValue.number)),
            (name: "sales_q2", values: [15, 25, 35, 45].map(DataValue.number))
        ])
        let long = try wide.melt(idColumns: ["region", "team"])
        #expect(long.columnNames.contains("variable"))
        #expect(long.columnNames.contains("value"))
        #expect(long.rowCount == wide.rowCount * 2)
        
        let pivoted = try long.pivotTable(
            index: ["region", "team"],
            columns: "variable",
            values: "value",
            using: .sum
        )
        #expect(pivoted.rowCount == 4)
        
        let tagged = try DataFrame(columns: [
            (name: "team", values: ["Alpha", "Beta"].map(DataValue.string)),
            (name: "skills", values: ["Swift,MLX", "CSV"].map(DataValue.string)),
        ])
        let exploded = try tagged.exploded("skills", separator: ",")
        #expect(exploded.rowCount == 3)
        
        let transposed = try wide.select("sales_q1", "sales_q2").transposed()
        #expect(transposed.rowCount == 2)
        
        let broadcast = try wide.groupBy("region").transform("sales_q1", using: .mean)
        #expect(broadcast.columnNames.contains("sales_q1_mean"))
        #expect(broadcast.rowCount == wide.rowCount)
        
        let rolling = try wide.rolling("sales_q1", window: 2, using: .mean)
        #expect(rolling.columnNames.contains("sales_q1_mean_rolling_2"))
        
        let expanding = try wide.expanding("sales_q1", using: .sum)
        #expect(expanding.columnNames.contains("sales_q1_sum_expanding"))
    }
    
    // MARK: - Student Analysis Tests
    
    @Test("Student grades analysis")
    func testStudentAnalysis() throws {
        let students = try DataFrame(columns: [
            (name: "name", values: [
                .string("Avery"), .string("Jordan"), .string("Casey"),
                .string("Riley"), .string("Morgan"), .string("Taylor")
            ]),
            (name: "class", values: [
                .string("A"), .string("B"), .string("A"),
                .string("B"), .string("A"), .string("B")
            ]),
            (name: "score", values: [85, 92, 78, 95, 64, 88].map(DataValue.number)),
            (name: "attendance", values: [95, 100, 80, 90, 75, 85].map(DataValue.number))
        ])
        let highScores = try students.filterRows { row in
            guard let score = row["score"].flatMap(numericValue) else { return false }
            return score >= 85
        }.select("name", "score", "class")
        #expect(highScores.rowCount == 4)
        
        let classAWithAttendance = try students.filterRows { row in
            guard let className = row["class"],
                  let attendance = row["attendance"].flatMap(numericValue)
            else {
                return false
            }
            return className == .string("A") && attendance >= 80
        }.select("name", "class", "attendance")
        #expect(classAWithAttendance.rowCount == 2)
        
        let scores = try students.column("score")
        let attendance = try students.column("attendance")
        let calculated = try students.withColumn(
            name: "total_score",
            values: zip(scores, attendance).map { .number(($0 + $1) / 2) }
        )
        #expect(calculated.columnNames.contains("total_score"))
        
        let classSummary = try students
            .groupBy("class")
            .aggregate([
                Aggregation("name", using: .count),
                Aggregation("score", using: .mean),
                Aggregation("score", using: .max)
            ])
        #expect(classSummary.rowCount == 2)
    }
    
    // MARK: - CMAPSS Analysis Tests
    
    @Test("CMAPSS engine failure risk analysis")
    func testCMAPSSAnalysis() throws {
        let cmapss = try loadBundledCSV("cmapss_sample")
        #expect(cmapss.rowCount == 1000)
        #expect(cmapss.columnNames.contains("RUL"))
        #expect(cmapss.columnNames.contains("failure_soon"))
        #expect(cmapss.columnNames.contains("sensor_2"))
        
        let riskSummary = try cmapss
            .groupBy("failure_soon")
            .aggregate([
                Aggregation("RUL", using: .count),
                Aggregation("RUL", using: .mean),
                Aggregation("sensor_2", using: .mean),
                Aggregation("sensor_4", using: .mean)
            ])
        #expect(riskSummary.rowCount == 2)
        
        let nearFailure = try cmapss
            .filterRows { row in
                guard let rul = row["RUL"].flatMap(numericValue) else { return false }
                return rul <= 30
            }
            .select("RUL", "sensor_2", "sensor_3", "failure_soon")
            .sorted(by: [SortDescriptor("RUL")])
            .head(5)
        #expect(nearFailure.rowCount == 5)
    }
    
    // MARK: - MIMII Analysis Tests
    
    @Test("MIMII acoustic anomaly analysis")
    func testMIMIIAnalysis() throws {
        let mimii = try loadBundledCSV("mimii_sample")
        #expect(mimii.rowCount == 800)
        #expect(mimii.columnNames.contains("rms"))
        #expect(mimii.columnNames.contains("spectral_centroid"))
        #expect(mimii.columnNames.contains("label"))
        
        let labelSummary = try mimii
            .groupBy("label")
            .aggregate([
                Aggregation("rms", using: .mean),
                Aggregation("spectral_centroid", using: .mean),
                Aggregation("label", using: .count)
            ])
        #expect(labelSummary.rowCount == 2)
        
        let highRMS = try mimii
            .filterRows { $0["label"] == .number(1) }
            .select("spectral_centroid", "rms", "label")
            .sorted(by: [SortDescriptor("rms", order: .descending)])
            .head(5)
        #expect(highRMS.rowCount == 5)
    }
    
    // MARK: - Additional Validation Tests
    
    @Test("Demo data integrity checks")
    func testDemoDataIntegrity() throws {
        // Verify all bundled CSV files exist and are readable
        let csvFiles = ["global_sales_raw", "country_info", "factory_data", "cmapss_sample", "mimii_sample"]
        for file in csvFiles {
            if let url = Bundle.main.url(forResource: file, withExtension: "csv") {
                #expect(FileManager.default.fileExists(atPath: url.path))
            } else {
                Issue.record("Missing CSV file: \(file).csv")
            }
        }
    }
    
    @Test("Error handling validation")
    func testErrorHandling() throws {
        let data = try DataFrame(columns: [
            (name: "a", values: [.number(1), .number(2)])
        ])
        
        #expect(throws: DataFrameError.self) {
            _ = try data.select("nonexistent")
        }
        
        #expect(throws: DataFrameError.self) {
            _ = try data.values(in: "missing_column")
        }
    }
}
