//
//  JoinStrategies.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeJoinStrategies() throws -> [DemoResultBlock] {
        let left = try DataFrame(columns: [
            (name: "id", values: [1, 2, 3, 4].map(DataValue.number)),
            (name: "region", values: ["West", "West", "East", "West"].map(DataValue.string)),
            (name: "team", values: ["A", "B", "A", "A"].map(DataValue.string)),
            (name: "sales", values: [100, 150, 80, 140].map(DataValue.number)),
        ])
        let right = try DataFrame(columns: [
            (name: "id", values: [2, 3, 5].map(DataValue.number)),
            (name: "manager", values: ["Mina", "Jin", "Ara"].map(DataValue.string)),
        ])
        let inner = try left.join(right, on: "id", kind: .inner)
        let full = try left.join(right, on: "id", kind: .full)

        let targets = try DataFrame(columns: [
            (name: "area", values: ["West", "West", "East"].map(DataValue.string)),
            (name: "unit", values: ["A", "B", "A"].map(DataValue.string)),
            (name: "sales", values: [110, 140, 75].map(DataValue.number)),
        ])
        let multiKeyJoin = try left.join(
            targets,
            leftOn: ["region", "team"],
            rightOn: ["area", "unit"],
            kind: .left,
            suffixes: (left: "_actual", right: "_target")
        )

        let multiAggregation = try left
            .groupBy("region")
            .aggregate([
                Aggregation("sales", using: .sum),
                Aggregation("sales", using: .count),
                Aggregation("sales", using: .mean),
                Aggregation("sales", using: .median),
                Aggregation("sales", using: .standardDeviation),
                Aggregation("sales", using: .first),
                Aggregation("sales", using: .last),
            ])
        let qualifyingGroups = try multiAggregation.filterRows { row in
            guard let mean = row["sales_mean"].flatMap(numericValue) else {
                return false
            }
            return mean >= 100
        }
        return [
            .table(
                title: String(localized: "Inner join (matching ids only):"),
                data: DemoTableData(dataFrame: inner)
            ),
            .table(
                title: String(localized: "Full join (unmatched rows retained with missing values):"),
                data: DemoTableData(dataFrame: full)
            ),
            .table(
                title: String(localized: "Multi-key join(leftOn:rightOn:suffixes:) with overlapping column names:"),
                data: DemoTableData(dataFrame: multiKeyJoin)
            ),
            .table(
                title: String(localized: "Sum, count, mean, median, std, first, and last by region:"),
                data: DemoTableData(dataFrame: multiAggregation)
            ),
            .table(
                title: String(localized: "Aggregated groups with mean sales >= 100:"),
                data: DemoTableData(dataFrame: qualifyingGroups)
            )
        ]
    }

    static func renderJoinStrategies() throws -> String {
        renderText(try executeJoinStrategies())
    }
}
