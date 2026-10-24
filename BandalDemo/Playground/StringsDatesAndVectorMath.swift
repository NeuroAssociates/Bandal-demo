import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
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
            .combining("price", "cost", using: .subtract, as: "net_margin")
            .combining("price", "cost", using: .subtract, as: "abs_margin")
            .abs("abs_margin")
            .scaling("price", by: 1.1, using: .multiply, as: "price_with_tax")
            .rounded("price_with_tax", decimals: 2)
            .ranked("price", ascending: false, as: "price_rank")
            .mapped("price") { value in
                guard let number = value.numberValue else { return .missing }
                return .string(number >= 100 ? "Premium" : "Standard")
            }
            .withColumn(name: "profitable") { row in
                .boolean((row["net_margin"]?.numberValue ?? 0) > 0)
            }

        print("=== String column operations ===")
        print(stringProcessed)

        print("\n=== DateComponent extraction ===")
        print(dateProcessed)

        print("\n=== Vectorized column math, abs, ranked, mapped, and row-computed withColumn ===")
        print(mathProcessed)
    } catch {
        print("Strings, dates, and vector math playground failed: \(error.localizedDescription)")
    }
}
