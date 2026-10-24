import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let mimii = try PlaygroundSupport.loadCSV("mimii_sample")
        let acousticSummary = try mimii
            .groupBy("label")
            .aggregate([
                Aggregation("rms", using: .mean),
                Aggregation("spectral_centroid", using: .mean),
                Aggregation("label", using: .count),
            ])
        let loudAbnormalSamples = try mimii
            .filterRows { $0["label"] == .number(1) }
            .select("spectral_centroid", "rms", "label")
            .sorted(by: [SortDescriptor("rms", order: .descending)])
            .head(5)

        // Inspect acoustic feature statistics programmatically via describeStructured()
        let description = mimii.describeStructured()
        let rmsStats = description.numeric["rms"]

        print("=== MIMII acoustic anomaly sample ===")
        print("MIMII shape: \(mimii.shape)")
        print("MIMII preview:\n\(try mimii.head(5))")
        print("Acoustic features by label (native multi-aggregation):\n\(acousticSummary)")
        print("Highest RMS abnormal records:\n\(loudAbnormalSamples)")
        if let rms = rmsStats {
            print("RMS overall stats: mean=\(rms.mean ?? 0), std=\(rms.standardDeviation ?? 0), min=\(rms.min ?? 0), max=\(rms.max ?? 0)")
        }
    } catch {
        print("MIMII acoustic analysis failed: \(error.localizedDescription)")
    }
}
