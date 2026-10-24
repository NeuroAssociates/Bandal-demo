//
//  RuntimeBackend.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeRuntimeBackend() throws -> [DemoResultBlock] {
        let factory = try loadBundledCSV("factory_data")
        let numeric = try factory.select("Quantity_Tons", "Unit_Price_USD_per_Ton")

        let clock = ContinuousClock()
        var statistics: DataFrameStatistics?
        let statisticsTime = clock.measure { statistics = numeric.statistics() }
        var rolled: DataFrame?
        let rollingTime = try clock.measure {
            rolled = try numeric.rolling("Quantity_Tons", window: 30, using: .mean)
        }
        var grouped: DataFrame?
        let groupTime = try clock.measure {
            grouped = try factory.groupBy("Division").aggregate([
                Aggregation("Quantity_Tons", using: .sum),
                Aggregation("Unit_Price_USD_per_Ton", using: .mean),
            ])
        }

        func milliseconds(_ duration: Duration) -> String {
            let parts = duration.components
            let value = Double(parts.seconds) * 1_000 + Double(parts.attoseconds) / 1e15
            return String(format: "%.2f ms", value)
        }

        let policyTimings: [[String]] = try [
            ExecutionPolicy.automatic,
            .cpu,
            .gpu,
            .native,
        ].map { policy in
            var policyBackend = ""
            var meanTons: Double?
            let elapsed = try BandalRuntime.withExecutionPolicy(policy) {
                policyBackend = BandalRuntime.executionBackend
                return try clock.measure {
                    meanTons = try numeric.series("Quantity_Tons").mean()
                }
            }
            return [
                policy.rawValue,
                policyBackend,
                formatted(meanTons),
                milliseconds(elapsed),
            ]
        }

        let sampleSlice = try numeric.head(5)
        let quantityVector = try sampleSlice.toMLXVector("Quantity_Tons")
        let priceVector = try sampleSlice.toMLXVector("Unit_Price_USD_per_Ton")
        let reconstructed = try DataFrame(mlxColumns: [
            (name: "Quantity_Tons", vector: quantityVector),
            (name: "Unit_Price_USD_per_Ton", vector: priceVector),
        ])

        let rows = numeric.columnNames.compactMap { name -> [String]? in
            guard let stats = statistics?.columns[name] else { return nil }
            return [name, String(stats.count), formatted(stats.mean), formatted(stats.standardDeviation),
                    formatted(stats.median), formatted(stats.min), formatted(stats.max)]
        }

        return [
            .text(
                title: String(localized: "BandalRuntime & MLXVector bridge:"),
                content: """
                isMLXAvailable = \(BandalRuntime.isMLXAvailable)
                executionPolicy = \(BandalRuntime.executionPolicy.rawValue)
                executionBackend = \(BandalRuntime.executionBackend)
                rows = \(factory.rowCount)
                MLXVector count = \(quantityVector.count), nonMissingCount = \(quantityVector.nonMissingCount), hasMLXArray = \(quantityVector.makeMLXArray() != nil)
                """
            ),
            .table(
                title: String(localized: "BandalRuntime.withExecutionPolicy(_:operation:) comparison:"),
                data: DemoTableData(
                    columns: ["policy", "activeBackend", "mean(Quantity_Tons)", "time"],
                    rows: policyTimings
                )
            ),
            .table(
                title: String(localized: "DataFrame reconstructed via DataFrame(mlxColumns:):"),
                data: DemoTableData(dataFrame: reconstructed)
            ),
            .table(
                title: String(localized: "statistics() on the large factory column set:"),
                data: DemoTableData(
                    columns: ["column", "count", "mean", "std", "median", "min", "max"],
                    rows: rows
                )
            ),
            .table(
                title: String(localized: "groupBy + aggregate on every row:"),
                data: DemoTableData(dataFrame: try (grouped ?? factory).head(5))
            ),
            .table(
                title: String(localized: "30-row rolling mean (last 3 rows):"),
                data: DemoTableData(dataFrame: try (rolled ?? numeric).tail(3))
            ),
            .table(
                title: String(localized: "Measured time per operation:"),
                data: DemoTableData(
                    columns: ["operation", "time"],
                    rows: [
                        ["statistics()", milliseconds(statisticsTime)],
                        ["rolling(window: 30)", milliseconds(rollingTime)],
                        ["groupBy().aggregate()", milliseconds(groupTime)],
                    ]
                )
            ),
        ]
    }

    static func renderRuntimeBackend() throws -> String {
        renderText(try executeRuntimeBackend())
    }
}
