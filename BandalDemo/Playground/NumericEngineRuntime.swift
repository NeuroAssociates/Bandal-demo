import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let factory = try PlaygroundSupport.loadCSV("factory_data")
        let numeric = try factory.select("Quantity_Tons", "Unit_Price_USD_per_Ton")

        print("=== Numeric engine & ExecutionPolicy ===")
        print("MLX available: \(BandalRuntime.isMLXAvailable)")
        print("Default execution policy: \(BandalRuntime.executionPolicy.rawValue)")
        print("Execution backend: \(BandalRuntime.executionBackend)")
        print("Rows: \(factory.rowCount)")

        let clock = ContinuousClock()
        for policy in [ExecutionPolicy.automatic, .cpu, .gpu, .native] {
            try BandalRuntime.withExecutionPolicy(policy) {
                let elapsed = try clock.measure {
                    _ = try numeric.series("Quantity_Tons").mean()
                }
                print("Policy \(policy.rawValue) (\(BandalRuntime.executionBackend)) mean() took \(elapsed)")
            }
        }

        let vector = try numeric.head(5).toMLXVector("Quantity_Tons")
        let rebuilt = try DataFrame(mlxColumns: [(name: "Quantity_Tons", vector: vector)])
        print("MLXVector count=\(vector.count), hasMLXArray=\(vector.makeMLXArray() != nil)")
        print("Reconstructed DataFrame from MLXVector:\n\(rebuilt)")

        var statistics: DataFrameStatistics?
        let statisticsTime = clock.measure { statistics = numeric.statistics() }
        print("statistics() took \(statisticsTime)")
        print("Quantity_Tons mean: \(statistics?.columns["Quantity_Tons"]?.mean?.description ?? "NaN")")

        let rolling = try numeric.rolling("Quantity_Tons", window: 30, using: .mean)
        print("30-row rolling mean tail:\n\(try rolling.tail(3))")

        let byDivision = try factory.groupBy("Division").aggregate([
            Aggregation("Quantity_Tons", using: .sum),
            Aggregation("Unit_Price_USD_per_Ton", using: .mean),
        ])
        print("Grouped by division:\n\(byDivision)")
    } catch {
        print("Runtime backend examples failed: \(error.localizedDescription)")
    }
}
