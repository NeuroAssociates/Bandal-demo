//
//  SequenceTransforms.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeSequenceTransforms() throws -> [DemoResultBlock] {
        let prices = try DataFrame(columns: [
            (name: "day", values: (1...6).map { DataValue.number(Double($0)) }),
            (name: "close", values: [
                .number(100), .number(102.456), .number(99), .missing, .number(105), .number(110.5),
            ]),
            (name: "volume", values: [10, 20, 15, 30, 25, 5].map(DataValue.number)),
            (name: "factor", values: [1.1, 1.2, 0.9, 1.05, 1.0, 1.3].map(DataValue.number)),
        ])

        func adding(_ base: DataFrame, _ name: String, _ transformed: DataFrame, from column: String) throws -> DataFrame {
            try base.withColumn(name: name, values: try transformed.values(in: column))
        }

        var cumulative = try prices.select("day", "volume", "factor")
        cumulative = try adding(cumulative, "volume_sum", try prices.cumulative("volume", using: .sum), from: "volume")
        cumulative = try adding(cumulative, "volume_max", try prices.cumulative("volume", using: .maximum), from: "volume")
        cumulative = try adding(cumulative, "volume_min", try prices.cumulative("volume", using: .minimum), from: "volume")
        cumulative = try adding(cumulative, "factor_product", try prices.cumulative("factor", using: .product), from: "factor")

        var changes = try prices.select("day", "close")
        changes = try adding(changes, "shifted", try prices.shifted("close"), from: "close")
        changes = try adding(changes, "difference", try prices.difference("close"), from: "close")
        changes = try adding(
            changes, "percent_change",
            try prices.percentChange("close").rounded("close", decimals: 4), from: "close"
        )

        var limits = try prices.select("day", "close")
        limits = try adding(limits, "clipped_100_105", try prices.clipped("close", lower: 100, upper: 105), from: "close")
        limits = try adding(limits, "rounded_1", try prices.rounded("close", decimals: 1), from: "close")

        let forward = try prices.select("day", "close").forwardFilled()
        let backward = try prices.select("day", "close").backwardFilled()
        var filled = try prices.select("day", "close")
        filled = try adding(filled, "forward_filled", forward, from: "close")
        filled = try adding(filled, "backward_filled", backward, from: "close")

        return [
            .table(title: String(localized: "Source prices (close has one missing value):"), data: DemoTableData(dataFrame: prices)),
            .table(
                title: String(localized: "cumulative(_:using:) — sum, maximum, minimum, and product:"),
                data: DemoTableData(dataFrame: cumulative)
            ),
            .table(
                title: String(localized: "shifted, difference, and percentChange (missing values propagate):"),
                data: DemoTableData(dataFrame: changes)
            ),
            .table(
                title: String(localized: "clipped(_:lower:upper:) and rounded(_:decimals:):"),
                data: DemoTableData(dataFrame: limits)
            ),
            .table(
                title: String(localized: "forwardFilled() and backwardFilled():"),
                data: DemoTableData(dataFrame: filled)
            ),
        ]
    }

    static func renderSequenceTransforms() throws -> String {
        renderText(try executeSequenceTransforms())
    }
}
