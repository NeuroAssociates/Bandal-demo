import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let factory = try PlaygroundSupport.loadCSV("factory_data")
        let division = try factory.series("Division")
        let scores = Series(
            name: "score",
            values: [.number(88), .number(92), .missing, .number(92), .number(75)]
        )
        let bonus = Series(name: "bonus", numbers: [2, 3, 5, 1, 5])
        let curved = try ((scores + bonus) * 1.05).rounded(decimals: 2)
        let rankedScores = try scores.ranked(ascending: false)

        print("=== Series basics & vectorized math ===")
        print("Score series:\n\(scores)")
        print("count=\(scores.count), missingCount=\(scores.missingCount), dtype=\(scores.dtype)")
        print("numbers=\(scores.numbers)")
        print("unique=\(scores.unique()), uniqueCount=\(scores.uniqueCount())")
        print("quantile(0.5)=\(String(describing: scores.quantile(0.5))), mode=\(scores.mode())")
        print("isin([88, 92])=\(scores.isin([88, 92])), between(80, 90)=\(scores.between(lower: 80, upper: 90))")
        print("ranked(ascending: false)=\(rankedScores.values)")
        print("curved ((scores + bonus) * 1.05)=\(curved.values)")
        print("Series describe():\n\(scores.describe())")
        print("Score value counts:\n\(try scores.valueCounts())")
        print("Division value counts:\n\(try division.valueCounts())")
        print("Quality status counts (subscript):\n\(try factory["Quality_Status"]?.valueCounts() as Any)")
        print("Unknown column via subscript: \(String(describing: factory["Unknown"]))")

        let quantity = try factory.series("Quantity_Tons")
        for function in AggregateFunction.allCases {
            print("Quantity_Tons \(function) = \(quantity.reduced(using: function))")
        }
    } catch {
        print("Series examples failed: \(error.localizedDescription)")
    }
}
