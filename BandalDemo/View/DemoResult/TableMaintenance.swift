//
//  TableMaintenance.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeTableMaintenance() throws -> [DemoResultBlock] {
        let first = try DataFrame(columns: [
            (name: "team", values: [.string("A"), .string("A"), .string("B")]),
            (name: "score", values: [80, 90, 75].map(DataValue.number)),
        ])
        let nextBatch = try DataFrame(columns: [
            (name: "team", values: [.string("C"), .string("D")]),
            (name: "score", values: [.number(88), .number(94)]),
        ])
        let duplicateMaskFirst = try first.duplicatedRows(in: ["team"], keep: .first)
        let duplicateMaskNone = try first.duplicatedRows(in: ["team"], keep: .none)
        let uniqueTeams = try first.dropDuplicates(in: ["team"], keep: .last)
        let renamed = try uniqueTeams.renamedColumns(["team": "department"])
        let combined = try DataFrame.concatenatingRows([
            renamed,
            nextBatch.renamedColumns(["team": "department"]),
        ])
        let sampled = try combined.sample(2, seed: 42)

        return [
            .table(
                title: String(localized: "Original rows:"),
                data: DemoTableData(dataFrame: first)
            ),
            .text(
                title: String(localized: "duplicatedRows(in: [\"team\"]) masks:"),
                content: """
                keep: .first -> \(duplicateMaskFirst)
                keep: .none  -> \(duplicateMaskNone)
                """
            ),
            .table(
                title: String(localized: "Keep last row per team, then rename team to department:"),
                data: DemoTableData(dataFrame: renamed)
            ),
            .table(
                title: String(localized: "Vertically concatenated batches:"),
                data: DemoTableData(dataFrame: combined)
            ),
            .table(
                title: String(localized: "Reproducible random sample(2, seed: 42):"),
                data: DemoTableData(dataFrame: sampled)
            ),
        ]
    }

    static func renderTableMaintenance() throws -> String {
        renderText(try executeTableMaintenance())
    }
}
