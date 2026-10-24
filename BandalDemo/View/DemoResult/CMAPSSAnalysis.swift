//
//  CMAPSSAnalysis.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeCMAPSSAnalysis() throws -> [DemoResultBlock] {
        let cmapss = try loadBundledCSV("cmapss_sample")
        let riskSummary = try cmapss
            .groupBy("failure_soon")
            .aggregate([
                Aggregation("RUL", using: .count),
                Aggregation("RUL", using: .mean),
                Aggregation("sensor_2", using: .mean),
                Aggregation("sensor_4", using: .mean),
            ])
        let nearFailure = try cmapss
            .filterRows { row in
                guard let rul = row["RUL"].flatMap(numericValue) else { return false }
                return rul <= 30
            }
            .select("RUL", "sensor_2", "sensor_3", "failure_soon")
            .sorted(by: [SortDescriptor("RUL")])
            .head(5)
        return [
            .text(
                title: String(localized: "Dataset info:"),
                content: "\(String(localized: "CMAPSS sample:")) \(cmapss.shape)"
            ),
            .table(
                title: String(localized: "Preview:"),
                data: DemoTableData(dataFrame: try cmapss.head(5))
            ),
            .table(
                title: String(localized: "Sensor and remaining-life summary by failure_soon:"),
                data: DemoTableData(dataFrame: riskSummary)
            ),
            .table(
                title: String(localized: "Five shortest remaining-life rows (RUL <= 30):"),
                data: DemoTableData(dataFrame: nearFailure)
            )
        ]
    }

    static func renderCMAPSSAnalysis() throws -> String {
        let cmapss = try loadBundledCSV("cmapss_sample")
        let riskSummary = try cmapss
            .groupBy("failure_soon")
            .aggregate([
                Aggregation("RUL", using: .count),
                Aggregation("RUL", using: .mean),
                Aggregation("sensor_2", using: .mean),
                Aggregation("sensor_4", using: .mean),
            ])
        let nearFailure = try cmapss
            .filterRows { row in
                guard let rul = row["RUL"].flatMap(numericValue) else { return false }
                return rul <= 30
            }
            .select("RUL", "sensor_2", "sensor_3", "failure_soon")
            .sorted(by: [SortDescriptor("RUL")])
            .head(5)
        return """
        \(String(localized: "CMAPSS sample:")) \(cmapss.shape)
        \(String(localized: "Preview:"))
        \(try cmapss.head(5))

        \(String(localized: "Sensor and remaining-life summary by failure_soon:"))
        \(riskSummary)

        \(String(localized: "Five shortest remaining-life rows (RUL <= 30):"))
        \(nearFailure)
        """
    }
}
