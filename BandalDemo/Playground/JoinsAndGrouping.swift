import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")
        let countryInfo = try PlaygroundSupport.loadCSV("country_info")
        let enrichedSales = try sales.leftJoin(countryInfo, on: "Country")
        let salesByRegion = try enrichedSales
            .groupBy("Region")
            .aggregate("Sales_2025", using: .sum)
        let countriesByTeam = try enrichedSales
            .groupBy("Team")
            .aggregate("Country", using: .count)

        print("=== Country join and regional aggregation ===")
        print("Sales by region:\n\(salesByRegion)")
        print("Country count by team:\n\(countriesByTeam)")

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
        let multiAggregation = try left.groupBy("region").aggregate([
            Aggregation("sales", using: .sum),
            Aggregation("sales", using: .count),
            Aggregation("sales", using: .mean),
            Aggregation("sales", using: .median),
            Aggregation("sales", using: .standardDeviation),
            Aggregation("sales", using: .first),
            Aggregation("sales", using: .last),
        ])
        let highValueGroups = try multiAggregation.filterRows { row in
            guard let mean = row["sales_mean"].flatMap(PlaygroundSupport.number) else {
                return false
            }
            return mean >= 100
        }
        let transformed = try left.groupBy("region").transform("sales", using: .mean)

        print("\n=== Join strategies, multi-key joins, and group transforms ===")
        print("Inner join:\n\(try left.join(right, on: "id", kind: .inner))")
        print("Right join:\n\(try left.join(right, on: "id", kind: .right))")
        print("Full join:\n\(try left.join(right, on: "id", kind: .full))")
        print("Multi-key join with custom suffixes:\n\(multiKeyJoin)")
        print("Region sum/count/mean/median/std/first/last:\n\(multiAggregation)")
        print("Aggregated groups with mean sales >= 100:\n\(highValueGroups)")
        print("Per-region mean broadcast to each row:\n\(transformed)")
    } catch {
        print("Join and grouping examples failed: \(error.localizedDescription)")
    }
}
