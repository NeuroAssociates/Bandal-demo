import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let cmapss = try PlaygroundSupport.loadCSV("cmapss_sample")
        let failureSummary = try cmapss
            .groupBy("failure_soon")
            .aggregate([
                Aggregation("RUL", using: .count),
                Aggregation("RUL", using: .mean),
                Aggregation("sensor_2", using: .mean),
                Aggregation("sensor_4", using: .mean),
            ])
        let nearFailure = try cmapss
            .filterRows { row in
                guard let rul = row["RUL"].flatMap(PlaygroundSupport.number) else {
                    return false
                }
                return rul <= 30
            }
            .select("RUL", "sensor_2", "sensor_3", "failure_soon")
            .sorted(by: [SortDescriptor("RUL")])
            .head(5)

        // Rolling sensor average to smooth noisy engine readings (MLX-accelerated)
        let smoothedSensors = try cmapss
            .rolling("sensor_2", window: 5, using: .mean)
            .select("RUL", "sensor_2", "sensor_2_mean_rolling_5", "failure_soon")
            .head(5)

        print("=== CMAPSS engine health sample ===")
        print("CMAPSS shape: \(cmapss.shape)")
        print("CMAPSS preview:\n\(try cmapss.head(5))")
        print("Failure risk summary (native multi-aggregation):\n\(failureSummary)")
        print("Shortest RUL records:\n\(nearFailure)")
        print("Smoothed sensor_2 (rolling mean window=5):\n\(smoothedSensors)")
    } catch {
        print("CMAPSS analysis failed: \(error.localizedDescription)")
    }
}
