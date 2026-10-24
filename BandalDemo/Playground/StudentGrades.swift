import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
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
        let scores = try students.column("score")
        let attendance = try students.column("attendance")
        let highScoreStudents = try students.filterRows { row in
            guard let score = row["score"].flatMap(PlaygroundSupport.number) else {
                return false
            }
            return score >= 85
        }.select("name", "score", "class")
        let classAStudents = try students.filterRows { row in
            guard let className = row["class"],
                let attendance = row["attendance"].flatMap(PlaygroundSupport.number)
            else {
                return false
            }
            return className == .string("A") && attendance >= 80
        }.select("name", "class", "attendance")
        let calculatedStudents = try students.withColumn(
            name: "total_score",
            values: zip(scores, attendance).map { score, attendance in
                .number((score + attendance) / 2)
            }
        )
        let gradedStudents = try calculatedStudents
            .withColumn(
                name: "grade_status",
                values: try calculatedStudents.values(in: "score").map { value in
                    guard let score = PlaygroundSupport.number(value) else { return .missing }
                    if score >= 90 { return .string("PASS") }
                    if score >= 70 { return .string("NORMAL") }
                    return .string("RETEST")
                }
            )
            .filterRows { row in
                guard let attendance = row["attendance"].flatMap(PlaygroundSupport.number) else {
                    return false
                }
                return attendance >= 80
            }
            .sorted(by: [SortDescriptor("score", order: .descending)])
            .select("name", "class", "score", "total_score", "grade_status")
        let classSummary = try students
            .groupBy("class")
            .aggregate([
                Aggregation("name", using: .count),
                Aggregation("score", using: .mean),
                Aggregation("score", using: .max),
            ])
        let rankedClassSummary = try classSummary.sorted(by: [
            SortDescriptor("score_mean", order: .descending),
        ])

        // Broadcast class average score back to each student using transform
        let withClassAverage = try students
            .groupBy("class")
            .transform("score", using: .mean)

        print("=== Fictional student grades workflow ===")
        print("Original students:\n\(students)")
        print("Score >= 85:\n\(highScoreStudents)")
        print("Class A with attendance >= 80:\n\(classAStudents)")
        print("Calculated score, attendance filter, and grades:\n\(gradedStudents)")
        print("Class statistics (multi-aggregation):\n\(rankedClassSummary)")
        print("Class mean score broadcast via transform:\n\(withClassAverage)")
    } catch {
        print("Student grades analysis failed: \(error.localizedDescription)")
    }
}
