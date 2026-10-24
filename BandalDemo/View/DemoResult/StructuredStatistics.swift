//
//  StructuredStatistics.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeStructuredStatistics() throws -> [DemoResultBlock] {
        let cmapss = try loadBundledCSV("cmapss_sample")
        let statistics = cmapss.statistics()
        let info = cmapss.infoSummary()
        let customDesc = cmapss.describeStructured(percentiles: [0.1, 0.5, 0.9], include: [.number])
        let summaryTable = cmapss.summaryTable()
        let missingSummary = cmapss.missingSummary()
        let uniqueSummary = cmapss.uniqueSummary()
        let columnTypes = cmapss.dtypes

        let statisticRows = cmapss.columnNames.compactMap { name -> [String]? in
            guard let stats = statistics.columns[name] else { return nil }
            let p90 = customDesc.numeric[name]?.percentiles["90%"]
            return [
                name, String(stats.count), formatted(stats.mean),
                formatted(stats.standardDeviation), formatted(stats.min),
                formatted(stats.q1), formatted(stats.median),
                formatted(stats.q3), formatted(p90), formatted(stats.max),
            ]
        }
        let infoRows = info.columns.map {
            [
                $0.name,
                String($0.nonMissingCount),
                String(describing: $0.type),
                String(uniqueSummary[$0.name] ?? 0),
                String(missingSummary[$0.name] ?? 0),
            ]
        }
        let reducedMax = try cmapss.reduced(using: .max)
        let reducedMean = try roundedNumbers(try cmapss.reduced(using: .mean), decimals: 3)
        let quantile90 = try roundedNumbers(try cmapss.quantile(0.9), decimals: 3)
        let failureCounts = try cmapss.valueCounts(of: "failure_soon")
        let compact = try cmapss.drop(columns: ["sensor_3", "sensor_7", "sensor_11", "sensor_15"])

        return [
            .text(
                title: String(localized: "statistics(), summaryTable(), and structured metadata:"),
                content: """
                rowCount = \(statistics.rowCount), columnCount = \(statistics.columnCount)
                summaryTable().summaries.count = \(summaryTable.summaries.count)
                missingSummary().totalMissing = \(missingSummary.totalMissing)
                dtypes["RUL"] = \(String(describing: columnTypes["RUL"]))
                infoSummary().estimatedMemoryBytes = \(info.estimatedMemoryBytes) bytes
                """
            ),
            .table(
                title: String(localized: "Per-column ColumnStatistics (with custom 90% percentile):"),
                data: DemoTableData(
                    columns: ["column", "count", "mean", "std", "min", "q1", "median", "q3", "90%", "max"],
                    rows: statisticRows
                )
            ),
            .text(title: String(localized: "infoSummary() description:"), content: info.description),
            .table(
                title: String(localized: "infoSummary(), uniqueSummary(), and missingSummary() per column:"),
                data: DemoTableData(
                    columns: ["column", "nonMissingCount", "type", "uniqueCount", "missingCount"],
                    rows: infoRows
                )
            ),
            .table(
                title: String(localized: "reduced(using: .max) — one row for numeric columns:"),
                data: DemoTableData(dataFrame: reducedMax)
            ),
            .table(
                title: String(localized: "reduced(using: .mean), rounded to 3 decimals:"),
                data: DemoTableData(dataFrame: reducedMean)
            ),
            .table(
                title: String(localized: "quantile(0.9) across numeric columns:"),
                data: DemoTableData(dataFrame: quantile90)
            ),
            .table(
                title: String(localized: "valueCounts(of: \"failure_soon\"):"),
                data: DemoTableData(dataFrame: failureCounts)
            ),
            .table(
                title: String(localized: "largest(3, by: \"sensor_2\"):"),
                data: DemoTableData(dataFrame: try compact.largest(3, by: "sensor_2"))
            ),
            .table(
                title: String(localized: "smallest(3, by: \"RUL\"):"),
                data: DemoTableData(dataFrame: try compact.smallest(3, by: "RUL"))
            ),
            .text(
                title: String(localized: "drop(columns:) keeps the remaining columns:"),
                content: compact.columnNames.joined(separator: ", ")
            ),
        ]
    }

    static func renderStructuredStatistics() throws -> String {
        renderText(try executeStructuredStatistics())
    }
}
