import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let temperatures = try DataFrame(columns: [
            "temperature": [18.0, 21.5, 19.0],
            "humidity": [0.45, 0.50, 0.48],
        ])
        let selectedTemperatures = try temperatures.select("temperature")

        print("=== Numeric DataFrame ===")
        print("Selected temperatures:\n\(selectedTemperatures)")

        let description = selectedTemperatures.describeStructured()
        print("Temperature statistics (structured):")
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                print("""
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN"), \
                median=\(stats.median?.description ?? "NaN"), q1=\(stats.q1?.description ?? "NaN"), \
                q3=\(stats.q3?.description ?? "NaN")
                """)
            }
        }
        print("Temperature statistics (text):\n\(description.describe())")

        let typed = try DataFrame(columns: [
            (name: "enabled", values: [.string("true"), .string("false"), .missing]),
            (name: "amount", values: [.string("$1,200"), .string("3.5"), .missing]),
            (name: "date", values: [
                .string("2024/01/02"), .string("2024/01/03"), .missing,
            ]),
        ])
            .castColumn("enabled", to: .boolean)
            .castColumn("amount", to: .number)
            .castColumn("date", to: .date, dateFormat: "yyyy/MM/dd")

        let booleanColumns = try typed.select(columnsOfType: .boolean)

        print("\n=== Explicit type conversion and type-based selection ===")
        print("Converted Boolean, number, and date columns:\n\(typed)")
        print("Selected Boolean columns:\n\(booleanColumns)")

        let quarterly = try DataFrame(columns: [
            (name: "region", values: ["West", "West", "East", "East"].map(DataValue.string)),
            (name: "team", values: ["A", "B", "A", "B"].map(DataValue.string)),
            (name: "q1", values: [10, 20, 30, 40].map(DataValue.number)),
            (name: "q2", values: [15, 25, 35, 45].map(DataValue.number)),
        ])
        let longSales = try quarterly.melt(idColumns: ["region", "team"])
        let pivotedSales = try longSales.pivotTable(
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
        let transposed = try quarterly.select("q1", "q2")
            .transposed(indexColumnName: "quarter", rowPrefix: "team_")

        let rollingSales = try quarterly.rolling("q1", window: 2, using: .mean)
        let expandingSales = try quarterly.expanding("q1", using: .sum)

        let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
        let timeSeries = try DataFrame(columns: [
            (name: "timestamp", values: [0.0, 1800.0, 3600.0, 9000.0].map {
                .date(baseDate.addingTimeInterval($0))
            }),
            (name: "load", values: [40.0, 60.0, 80.0, 50.0].map(DataValue.number)),
        ])
        let timeRolling = try timeSeries.rolling("load", on: "timestamp", interval: 3600, using: .mean)

        print("\n=== Reshaping, explode, transpose, and window statistics ===")
        print("Long-form quarterly sales:\n\(longSales)")
        print("Pivoted quarterly sales:\n\(pivotedSales)")
        print("Exploded skills:\n\(exploded)")
        print("Transposed quarterly:\n\(transposed)")
        print("Two-row rolling mean:\n\(rollingSales)")
        print("Time-based 1-hour rolling mean:\n\(timeRolling)")
        print("Expanding cumulative sum:\n\(expandingSales)")
    } catch {
        print("Typed values and reshaping examples failed: \(error.localizedDescription)")
    }
}
