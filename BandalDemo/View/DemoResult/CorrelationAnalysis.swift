//
//  CorrelationAnalysis.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeCorrelationAnalysis() throws -> [DemoResultBlock] {
        let cmapss = try loadBundledCSV("cmapss_sample")
        let engine = try cmapss.select("sensor_2", "sensor_4", "sensor_11", "RUL")
        let mimii = try loadBundledCSV("mimii_sample")

        return [
            .table(
                title: String(localized: "CMAPSS correlation() (Pearson):"),
                data: DemoTableData(dataFrame: try roundedNumbers(try engine.correlation(), decimals: 3))
            ),
            .table(
                title: String(localized: "CMAPSS covariance() (sample, n - 1):"),
                data: DemoTableData(dataFrame: try roundedNumbers(try engine.covariance(), decimals: 3))
            ),
            .table(
                title: String(localized: "MIMII correlation() including the anomaly label:"),
                data: DemoTableData(dataFrame: try roundedNumbers(try mimii.correlation(), decimals: 3))
            ),
        ]
    }

    static func renderCorrelationAnalysis() throws -> String {
        renderText(try executeCorrelationAnalysis())
    }
}
