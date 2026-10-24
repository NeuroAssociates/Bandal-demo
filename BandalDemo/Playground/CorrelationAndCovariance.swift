import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let cmapss = try PlaygroundSupport.loadCSV("cmapss_sample")
        let engine = try cmapss.select("sensor_2", "sensor_4", "sensor_11", "RUL")
        let mimii = try PlaygroundSupport.loadCSV("mimii_sample")

        print("=== Correlation and covariance ===")
        print("CMAPSS correlation:\n\(try engine.correlation())")
        print("CMAPSS covariance:\n\(try engine.covariance())")
        print("MIMII correlation (label is the anomaly flag):\n\(try mimii.correlation())")
    } catch {
        print("Correlation examples failed: \(error.localizedDescription)")
    }
}
