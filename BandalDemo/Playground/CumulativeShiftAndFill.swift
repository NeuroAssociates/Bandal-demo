import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let prices = try DataFrame(columns: [
            (name: "day", values: (1...6).map { DataValue.number(Double($0)) }),
            (name: "close", values: [
                .number(100), .number(102.456), .number(99), .missing, .number(105), .number(110.5),
            ]),
            (name: "volume", values: [10, 20, 15, 30, 25, 5].map(DataValue.number)),
            (name: "factor", values: [1.1, 1.2, 0.9, 1.05, 1.0, 1.3].map(DataValue.number)),
        ])

        print("=== Cumulative operations ===")
        for function in CumulativeFunction.allCases {
            print("\(function):\n\(try prices.cumulative("volume", using: function))")
        }
        print("Product of factors:\n\(try prices.cumulative("factor", using: .product))")

        print("\n=== Shift, difference, and percent change ===")
        print("shifted by 1:\n\(try prices.shifted("close"))")
        print("shifted by -1:\n\(try prices.shifted("close", by: -1))")
        print("difference (periods 2):\n\(try prices.difference("close", periods: 2))")
        print("percentChange:\n\(try prices.percentChange("close"))")

        print("\n=== Clip and round ===")
        print("clipped 100...105:\n\(try prices.clipped("close", lower: 100, upper: 105))")
        print("rounded to 1 decimal:\n\(try prices.rounded("close", decimals: 1))")

        print("\n=== Directional fill ===")
        print("forwardFilled:\n\(try prices.forwardFilled())")
        print("backwardFilled:\n\(try prices.backwardFilled())")
    } catch {
        print("Sequence transform examples failed: \(error.localizedDescription)")
    }
}
