//
//  StudentAnalysis.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeStudentAnalysis() throws -> [DemoResultBlock] {
        let students = try DataFrame(columns: [
            (name: "name", values: [
                .string("Avery"), .string("Jordan"), .string("Casey"),
                .string("Riley"), .string("Morgan"), .string("Taylor"),
            ]),
            (name: "class", values: [
                .string("A"), .string("B"), .string("A"),
                .string("B"), .string("A"), .string("B"),
            ]),
            (name: "score", values: [85, 92, 78, 95, 64, 88].map(DataValue.number)),
            (name: "attendance", values: [95, 100, 80, 90, 75, 85].map(DataValue.number)),
        ])
        let highScores = try students.filterRows { row in
            guard let score = row["score"].flatMap(numericValue) else { return false }
            return score >= 85
        }.select("name", "score", "class")
        let classAWithAttendance = try students.filterRows { row in
            guard let className = row["class"],
                let attendance = row["attendance"].flatMap(numericValue)
            else {
                return false
            }
            return className == .string("A") && attendance >= 80
        }.select("name", "class", "attendance")
        let score = try students.column("score")
        let attendance = try students.column("attendance")
        let calculated = try students.withColumn(
            name: "total_score",
            values: zip(score, attendance).map {
                .number(($0 + $1) / 2)
            }
        )
        let graded = try calculated
            .withColumn(
                name: "grade_status",
                values: try calculated.values(in: "score").map { value in
                    guard let score = numericValue(value) else { return .missing }
                    if score >= 90 { return .string("PASS") }
                    if score >= 70 { return .string("NORMAL") }
                    return .string("RETEST")
                }
            )
            .filterRows { row in
                guard let attendance = row["attendance"].flatMap(numericValue) else {
                    return false
                }
                return attendance >= 80
            }
            .sorted(by: [
                SortDescriptor("score", order: .descending),
            ])
            .select("name", "class", "score", "total_score", "grade_status")
        let classCount = try students
            .groupBy("class")
            .aggregate([
                Aggregation("name", using: .count),
                Aggregation("score", using: .mean),
                Aggregation("score", using: .max),
            ])
        return [
            .table(
                title: String(localized: "Original data:"),
                data: DemoTableData(dataFrame: students)
            ),
            .table(
                title: String(localized: "Score >= 85:"),
                data: DemoTableData(dataFrame: highScores)
            ),
            .table(
                title: String(localized: "Class A with attendance >= 80:"),
                data: DemoTableData(dataFrame: classAWithAttendance)
            ),
            .table(
                title: String(localized: "Calculated average score; attendance >= 80, graded and ranked:"),
                data: DemoTableData(dataFrame: graded)
            ),
            .table(
                title: String(localized: "Class count, average score, and maximum score:"),
                data: DemoTableData(dataFrame: try classCount.sorted(by: [SortDescriptor("score_mean", order: .descending)]))
            )
        ]
    }

    static func renderStudentAnalysis() throws -> String {
        let students = try DataFrame(columns: [
            (name: "name", values: [
                .string("Avery"), .string("Jordan"), .string("Casey"),
                .string("Riley"), .string("Morgan"), .string("Taylor"),
            ]),
            (name: "class", values: [
                .string("A"), .string("B"), .string("A"),
                .string("B"), .string("A"), .string("B"),
            ]),
            (name: "score", values: [85, 92, 78, 95, 64, 88].map(DataValue.number)),
            (name: "attendance", values: [95, 100, 80, 90, 75, 85].map(DataValue.number)),
        ])
        let highScores = try students.filterRows { row in
            guard let score = row["score"].flatMap(numericValue) else { return false }
            return score >= 85
        }.select("name", "score", "class")
        let classAWithAttendance = try students.filterRows { row in
            guard let className = row["class"],
                let attendance = row["attendance"].flatMap(numericValue)
            else {
                return false
            }
            return className == .string("A") && attendance >= 80
        }.select("name", "class", "attendance")
        let score = try students.column("score")
        let attendance = try students.column("attendance")
        let calculated = try students.withColumn(
            name: "total_score",
            values: zip(score, attendance).map {
                .number(($0 + $1) / 2)
            }
        )
        let graded = try calculated
            .withColumn(
                name: "grade_status",
                values: try calculated.values(in: "score").map { value in
                    guard let score = numericValue(value) else { return .missing }
                    if score >= 90 { return .string("PASS") }
                    if score >= 70 { return .string("NORMAL") }
                    return .string("RETEST")
                }
            )
            .filterRows { row in
                guard let attendance = row["attendance"].flatMap(numericValue) else {
                    return false
                }
                return attendance >= 80
            }
            .sorted(by: [
                SortDescriptor("score", order: .descending),
            ])
            .select("name", "class", "score", "total_score", "grade_status")
        let classCount = try students
            .groupBy("class")
            .aggregate([
                Aggregation("name", using: .count),
                Aggregation("score", using: .mean),
                Aggregation("score", using: .max),
            ])
        return """
        \(String(localized: "Original data:"))
        \(students)

        \(String(localized: "Score >= 85:"))
        \(highScores)

        \(String(localized: "Class A with attendance >= 80:"))
        \(classAWithAttendance)

        \(String(localized: "Calculated average score; attendance >= 80, graded and ranked:"))
        \(graded)

        \(String(localized: "Class count, average score, and maximum score:"))
        \(try classCount.sorted(by: [SortDescriptor("score_mean", order: .descending)]))
        """
    }
}
