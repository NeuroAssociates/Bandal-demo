//
//  FactoryAnalysis.swift
//  BandalDemo
//

import Foundation
import Bandal

extension DemoResult {
    static func executeFactoryAnalysis() throws -> [DemoResultBlock] {
        let factory = try loadBundledCSV("factory_data", maximumRows: 5_000)
        let quantities = try factory.values(in: "Quantity_Tons")
        let prices = try factory.values(in: "Unit_Price_USD_per_Ton")
        let revenue = zip(quantities, prices).map { quantity, price in
            guard let quantity = numericValue(quantity),
                let price = numericValue(price)
            else {
                return DataValue.missing
            }
            return DataValue.number(quantity * price)
        }
        let months = try factory.values(in: "Shipment_Date").map { value -> DataValue in
            guard case .string(let date) = value, date.count >= 7 else {
                return .missing
            }
            return .string(String(date.prefix(7)))
        }
        let prepared = try factory
            .withColumn(name: "Revenue_USD", values: revenue)
            .withColumn(name: "Shipment_Month", values: months)
        let monthlyRevenue = try prepared
            .groupBy("Shipment_Month")
            .aggregate("Revenue_USD", using: .sum)
        let departmentShipments = try prepared
            .groupBy("Division")
            .aggregate("Quantity_Tons", using: .sum)
        return [
            .text(
                title: String(localized: "Source summary:"),
                content: "\(String(localized: "Source rows:")) \(factory.rowCount)"
            ),
            .table(
                title: String(localized: "Monthly revenue (head 5):"),
                data: DemoTableData(dataFrame: try monthlyRevenue.head(5))
            ),
            .table(
                title: String(localized: "Department shipment totals:"),
                data: DemoTableData(dataFrame: departmentShipments)
            )
        ]
    }

    static func renderFactoryAnalysis() throws -> String {
        let factory = try loadBundledCSV("factory_data", maximumRows: 5_000)
        let quantities = try factory.values(in: "Quantity_Tons")
        let prices = try factory.values(in: "Unit_Price_USD_per_Ton")
        let revenue = zip(quantities, prices).map { quantity, price in
            guard let quantity = numericValue(quantity),
                let price = numericValue(price)
            else {
                return DataValue.missing
            }
            return DataValue.number(quantity * price)
        }
        let months = try factory.values(in: "Shipment_Date").map { value -> DataValue in
            guard case .string(let date) = value, date.count >= 7 else {
                return .missing
            }
            return .string(String(date.prefix(7)))
        }
        let prepared = try factory
            .withColumn(name: "Revenue_USD", values: revenue)
            .withColumn(name: "Shipment_Month", values: months)
        let monthlyRevenue = try prepared
            .groupBy("Shipment_Month")
            .aggregate("Revenue_USD", using: .sum)
        let departmentShipments = try prepared
            .groupBy("Division")
            .aggregate("Quantity_Tons", using: .sum)
        return """
        \(String(localized: "Source rows:")) \(factory.rowCount)
        \(String(localized: "Monthly revenue:"))
        \(try monthlyRevenue.head(5))

        \(String(localized: "Department shipment totals:"))
        \(departmentShipments)
        """
    }
}
