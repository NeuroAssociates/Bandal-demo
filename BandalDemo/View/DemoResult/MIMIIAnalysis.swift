//
//  MIMIIAnalysis.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeMIMIIAnalysis() throws -> [DemoResultBlock] {
        let mimii = try loadBundledCSV("mimii_sample")
        let labelSummary = try mimii
            .groupBy("label")
            .aggregate([
                Aggregation("rms", using: .mean),
                Aggregation("spectral_centroid", using: .mean),
                Aggregation("label", using: .count),
            ])
        let highRMS = try mimii
            .filterRows { $0["label"] == .number(1) }
            .select("spectral_centroid", "rms", "label")
            .sorted(by: [SortDescriptor("rms", order: .descending)])
            .head(5)
        return [
            .text(
                title: String(localized: "Dataset info:"),
                content: "\(String(localized: "MIMII acoustic sample:")) \(mimii.shape)"
            ),
            .table(
                title: String(localized: "Preview:"),
                data: DemoTableData(dataFrame: try mimii.head(5))
            ),
            .table(
                title: String(localized: "Mean acoustic features and sample count by label:"),
                data: DemoTableData(dataFrame: labelSummary)
            ),
            .table(
                title: String(localized: "Top 5 abnormal samples by RMS:"),
                data: DemoTableData(dataFrame: highRMS)
            )
        ]
    }

    static func renderMIMIIAnalysis() throws -> String {
        let mimii = try loadBundledCSV("mimii_sample")
        let labelSummary = try mimii
            .groupBy("label")
            .aggregate([
                Aggregation("rms", using: .mean),
                Aggregation("spectral_centroid", using: .mean),
                Aggregation("label", using: .count),
            ])
        let highRMS = try mimii
            .filterRows { $0["label"] == .number(1) }
            .select("spectral_centroid", "rms", "label")
            .sorted(by: [SortDescriptor("rms", order: .descending)])
            .head(5)
        return """
        \(String(localized: "MIMII acoustic sample:")) \(mimii.shape)
        \(String(localized: "Preview:"))
        \(try mimii.head(5))

        \(String(localized: "Mean acoustic features and sample count by label:"))
        \(labelSummary)

        \(String(localized: "Top 5 abnormal samples by RMS:"))
        \(highRMS)
        """
    }
}
