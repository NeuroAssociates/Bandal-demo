//
//  ReshapeAndWindows.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeReshapeAndWindows() throws -> [DemoResultBlock] {
        let wide = try DataFrame(columns: [
            (name: "region", values: ["West", "West", "East", "East"].map(DataValue.string)),
            (name: "team", values: ["A", "B", "A", "B"].map(DataValue.string)),
            (name: "sales_q1", values: [10, 20, 30, 40].map(DataValue.number)),
            (name: "sales_q2", values: [15, 25, 35, 45].map(DataValue.number)),
        ])
        let long = try wide.melt(idColumns: ["region", "team"])
        let pivoted = try long.pivotTable(
            index: ["region", "team"],
            columns: "variable",
            values: "value",
            using: .sum
        )

        let tagged = try DataFrame(columns: [
            (name: "team", values: ["Alpha", "Beta"].map(DataValue.string)),
            (name: "skills", values: ["Swift,MLX,CSV", "Data,Analytics"].map(DataValue.string)),
        ])
        let exploded = try tagged.exploded("skills", separator: ",")
        let transposed = try wide.select("sales_q1", "sales_q2")
            .transposed(indexColumnName: "quarter", rowPrefix: "team_")

        let transformed = try wide.groupBy("region").transform("sales_q1", using: .mean)
        let rolling = try wide.rolling("sales_q1", window: 2, using: .mean)
        let rollingAggregations = try wide
            .rolling("sales_q1", window: 2, using: .count)
            .rolling("sales_q1", window: 2, using: .sum)
            .rolling("sales_q1", window: 2, using: .min)
            .rolling("sales_q1", window: 2, using: .max)

        let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
        let timeSeries = try DataFrame(columns: [
            (name: "timestamp", values: [0.0, 1800.0, 3600.0, 9000.0].map {
                .date(baseDate.addingTimeInterval($0))
            }),
            (name: "load", values: [40.0, 60.0, 80.0, 50.0].map(DataValue.number)),
        ])
        let timeRolling = try timeSeries.rolling(
            "load",
            on: "timestamp",
            interval: 3600,
            using: .mean
        )

        let expanding = try wide
            .expanding("sales_q1", using: .count)
            .expanding("sales_q1", using: .sum)
            .expanding("sales_q1", using: .mean)
            .expanding("sales_q1", using: .min)
            .expanding("sales_q1", using: .max)
        return [
            .table(
                title: String(localized: "Wide source:"),
                data: DemoTableData(dataFrame: wide)
            ),
            .table(
                title: String(localized: "Melted (long) form:"),
                data: DemoTableData(dataFrame: long)
            ),
            .table(
                title: String(localized: "Pivoted and aggregated:"),
                data: DemoTableData(dataFrame: pivoted)
            ),
            .table(
                title: String(localized: "exploded(\"skills\", separator: \",\"):"),
                data: DemoTableData(dataFrame: exploded)
            ),
            .table(
                title: String(localized: "transposed(indexColumnName: \"quarter\", rowPrefix: \"team_\"):"),
                data: DemoTableData(dataFrame: transposed)
            ),
            .table(
                title: String(localized: "Group mean broadcast to source rows:"),
                data: DemoTableData(dataFrame: transformed)
            ),
            .table(
                title: String(localized: "Two-row rolling mean (incomplete first window is missing):"),
                data: DemoTableData(dataFrame: rolling)
            ),
            .table(
                title: String(localized: "Time-interval rolling(\"load\", on: \"timestamp\", interval: 3600, using: .mean):"),
                data: DemoTableData(dataFrame: timeRolling)
            ),
            .table(
                title: String(localized: "Rolling count, sum, minimum, and maximum:"),
                data: DemoTableData(dataFrame: rollingAggregations)
            ),
            .table(
                title: String(localized: "Expanding count, sum, mean, minimum, and maximum:"),
                data: DemoTableData(dataFrame: expanding)
            )
        ]
    }

    static func renderReshapeAndWindows() throws -> String {
        renderText(try executeReshapeAndWindows())
    }
}
