//
//  TypedValues.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeTypedValues() throws -> [DemoResultBlock] {
        let raw = try DataFrame(columns: [
            (name: "enabled_text", values: [.string("true"), .string("false"), .missing]),
            (name: "amount_text", values: [.string("$1,250"), .string("48.5"), .missing]),
            (name: "created_text", values: [
                .string("2024/01/02"), .string("2024/02/15"), .missing,
            ]),
        ])
        let converted = try raw
            .castColumn("enabled_text", to: .boolean)
            .castColumn("amount_text", to: .number)
            .castColumn("created_text", to: .date, dateFormat: "yyyy/MM/dd")
        return [
            .text(
                title: String(localized: "Type inference and cast:"),
                content: """
                \(String(localized: "Inferred source types:"))
                enabled_text: \(try raw.dataType(of: "enabled_text"))
                amount_text: \(try raw.dataType(of: "amount_text"))

                \(String(localized: "Converted types:"))
                enabled_text: \(try converted.dataType(of: "enabled_text"))
                amount_text: \(try converted.dataType(of: "amount_text"))
                created_text: \(try converted.dataType(of: "created_text"))
                """
            ),
            .table(
                title: String(localized: "Boolean columns:"),
                data: DemoTableData(dataFrame: try converted.select(columnsOfType: .boolean))
            ),
            .table(
                title: String(localized: "Converted data:"),
                data: DemoTableData(dataFrame: converted)
            )
        ]
    }

    static func renderTypedValues() throws -> String {
        let raw = try DataFrame(columns: [
            (name: "enabled_text", values: [.string("true"), .string("false"), .missing]),
            (name: "amount_text", values: [.string("$1,250"), .string("48.5"), .missing]),
            (name: "created_text", values: [
                .string("2024/01/02"), .string("2024/02/15"), .missing,
            ]),
        ])
        let converted = try raw
            .castColumn("enabled_text", to: .boolean)
            .castColumn("amount_text", to: .number)
            .castColumn("created_text", to: .date, dateFormat: "yyyy/MM/dd")
        return """
        \(String(localized: "Inferred source types:"))
        enabled_text: \(try raw.dataType(of: "enabled_text"))
        amount_text: \(try raw.dataType(of: "amount_text"))

        \(String(localized: "Converted types:"))
        enabled_text: \(try converted.dataType(of: "enabled_text"))
        amount_text: \(try converted.dataType(of: "amount_text"))
        created_text: \(try converted.dataType(of: "created_text"))

        \(String(localized: "Boolean columns:"))
        \(try converted.select(columnsOfType: .boolean))

        \(String(localized: "Converted data:"))
        \(converted)
        """
    }
}
