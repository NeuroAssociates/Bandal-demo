//
//  SeriesBasics.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeSeriesBasics() throws -> [DemoResultBlock] {
        let factory = try loadBundledCSV("factory_data")
        let division = try factory.series("Division")
        let quantity = try factory.series("Quantity_Tons")

        let scores = Series(
            name: "score",
            values: [.number(88), .number(92), .missing, .number(92), .number(75)]
        )
        let bonus = Series(name: "bonus", numbers: [2, 3, 5, 1, 5])
        let curved = try ((scores + bonus) * 1.05).rounded(decimals: 2)
        let rankedScores = try scores.ranked(ascending: false)
        let inCandidateMask = scores.isin([88, 92])
        let betweenMask = scores.between(lower: 80, upper: 90)

        let reductions = AggregateFunction.allCases.map { function in
            [String(describing: function), quantity.reduced(using: function).description]
        }

        return [
            .text(
                title: String(localized: "A small Series with a missing value:"),
                content: scores.description
            ),
            .text(
                title: String(localized: "count, numbers, unique, uniqueCount, quantile, mode, and describe():"),
                content: """
                count = \(scores.count), missingCount = \(scores.missingCount), dtype = \(scores.dtype)
                numbers = \(scores.numbers)
                unique = \(scores.unique()), uniqueCount = \(scores.uniqueCount())
                quantile(0.5) = \(formatted(scores.quantile(0.5))), mode() = \(scores.mode())
                isin([88, 92]) = \(inCandidateMask)
                between(80, 90) = \(betweenMask)

                \(scores.describe())
                """
            ),
            .text(
                title: String(localized: "Vectorized Series arithmetic ((scores + bonus) * 1.05) & ranked(ascending: false):"),
                content: """
                curved = \(curved.values)
                ranked = \(rankedScores.values)
                """
            ),
            .table(
                title: String(localized: "valueCounts() of the score Series:"),
                data: DemoTableData(dataFrame: try scores.valueCounts())
            ),
            .table(
                title: String(localized: "Shipments per division (Division Series valueCounts):"),
                data: DemoTableData(dataFrame: try division.valueCounts())
            ),
            .table(
                title: String(localized: "Shipments per quality status (subscript access):"),
                data: DemoTableData(
                    dataFrame: try (factory["Quality_Status"] ?? division).valueCounts()
                )
            ),
            .table(
                title: String(localized: "Quantity_Tons reduced with every AggregateFunction:"),
                data: DemoTableData(columns: ["function", "value"], rows: reductions)
            ),
            .text(
                title: String(localized: "Subscript returns nil for an unknown column:"),
                content: "factory[\"Unknown\"] = \(String(describing: factory["Unknown"]))"
            ),
        ]
    }

    static func renderSeriesBasics() throws -> String {
        renderText(try executeSeriesBasics())
    }
}
