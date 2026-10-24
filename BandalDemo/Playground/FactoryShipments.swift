import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let factory = try PlaygroundSupport.loadCSV("factory_data", maximumRows: 5_000)
        let quantities = try factory.values(in: "Quantity_Tons")
        let unitPrices = try factory.values(in: "Unit_Price_USD_per_Ton")
        let revenue = zip(quantities, unitPrices).map { quantity, price in
            guard let quantity = PlaygroundSupport.number(quantity),
                let price = PlaygroundSupport.number(price)
            else {
                return DataValue.missing
            }
            return DataValue.number(quantity * price)
        }
        let shipmentDates = try factory.values(in: "Shipment_Date")
        let shipmentMonths = shipmentDates.map { value -> DataValue in
            guard case .string(let date) = value, date.count >= 7 else {
                return .missing
            }
            return .string(String(date.prefix(7)))
        }
        let preparedFactory = try factory
            .withColumn(name: "Revenue_USD", values: revenue)
            .withColumn(name: "Shipment_Month", values: shipmentMonths)
        // Multi-aggregation: monthly revenue sum, mean, and shipment volume in one pass
        let monthlyMetrics = try preparedFactory
            .groupBy("Shipment_Month")
            .aggregate([
                Aggregation("Revenue_USD", using: .sum),
                Aggregation("Revenue_USD", using: .mean),
                Aggregation("Quantity_Tons", using: .sum),
            ])
        // Multi-key grouping: division + shipment month
        let divisionMonthly = try preparedFactory
            .groupBy("Division", "Shipment_Month")
            .aggregate([
                Aggregation("Revenue_USD", using: .sum),
                Aggregation("Quantity_Tons", using: .sum),
            ])
        let shipmentsByDivision = try preparedFactory
            .groupBy("Division")
            .aggregate("Quantity_Tons", using: .sum)

        print("=== Fictional US factory shipment analysis ===")
        print("Source rows: \(factory.rowCount)")
        print("Monthly metrics (first 5 groups):\n\(try monthlyMetrics.head(5))")
        print("Division + Month multi-key grouping (first 5 groups):\n\(try divisionMonthly.head(5))")
        print("Shipment volume by division:\n\(shipmentsByDivision)")
    } catch {
        print("Factory shipment analysis failed: \(error.localizedDescription)")
    }
}
