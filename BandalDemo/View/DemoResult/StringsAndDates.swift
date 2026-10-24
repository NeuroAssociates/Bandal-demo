//
//  StringsAndDates.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeStringsAndDates() throws -> [DemoResultBlock] {
        let catalog = try DataFrame(columns: [
            (name: "product", values: ["  Bandal Pro-X  ", "  bandal mini-s ", "  Legacy Core-1 "]),
            (name: "launch_date", values: ["2025-01-15", "2025-06-20", "2025-11-03"]),
            (name: "price", values: [120.0, 80.0, 95.0]),
            (name: "cost", values: [75.0, 50.0, 110.0]),
        ])

        let stringProcessed = try catalog
            .select("product")
            .trimmed("product", as: "trimmed")
            .lowercased("trimmed", as: "lower")
            .uppercased("trimmed", as: "upper")
            .stringLength("trimmed", as: "length")
            .replacingSubstring(in: "trimmed", target: "-", with: " ", as: "normalized")
            .containsSubstring("trimmed", "Bandal", caseSensitive: false, as: "is_bandal")

        let dateProcessed = try catalog
            .select("product", "launch_date")
            .trimmed("product")
            .castColumn("launch_date", to: .date, dateFormat: "yyyy-MM-dd")
            .dateComponent(.year, from: "launch_date", as: "year")
            .dateComponent(.month, from: "launch_date", as: "month")
            .dateComponent(.day, from: "launch_date", as: "day")
            .dateComponent(.weekday, from: "launch_date", as: "weekday")

        let mathProcessed = try catalog
            .select("product", "price", "cost")
            .trimmed("product")
            .combining("price", "cost", using: .subtract, as: "margin")
            .abs("margin")
            . renamedColumns(["margin": "abs_margin"])
            .combining("price", "cost", using: .subtract, as: "net_margin")
            .scaling("price", by: 1.1, using: .multiply, as: "price_with_tax")
            .rounded("price_with_tax", decimals: 2)
            .ranked("price", ascending: false, as: "price_rank")
            .mapped("price") { value in
                guard let number = value.numberValue else { return .missing }
                return .string(number >= 100 ? "Premium" : "Standard")
            }
            .withColumn(name: "profitable") { row in
                let net = row["net_margin"]?.numberValue ?? 0
                return .boolean(net > 0)
            }

        return [
            .table(
                title: String(localized: "String operations (trimmed, lowercased, uppercased, stringLength, replacingSubstring, containsSubstring):"),
                data: DemoTableData(dataFrame: stringProcessed)
            ),
            .table(
                title: String(localized: "Date component extraction (.year, .month, .day, .weekday):"),
                data: DemoTableData(dataFrame: dateProcessed)
            ),
            .table(
                title: String(localized: "Vectorized column math, abs, ranked, mapped, and row-computed withColumn:"),
                data: DemoTableData(dataFrame: mathProcessed)
            ),
        ]
    }

    static func renderStringsAndDates() throws -> String {
        renderText(try executeStringsAndDates())
    }
}
