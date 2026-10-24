import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let cmapss = try PlaygroundSupport.loadCSV("cmapss_sample")

        let statistics = cmapss.statistics()
        let customDesc = cmapss.describeStructured(percentiles: [0.1, 0.5, 0.9], include: [.number])
        let summaryTable = cmapss.summaryTable()
        let missingSummary = cmapss.missingSummary()
        let uniqueSummary = cmapss.uniqueSummary()
        let dtypes = cmapss.dtypes

        print("=== Structured statistics & custom percentiles ===")
        print("rows=\(statistics.rowCount), columns=\(statistics.columnCount)")
        print("summaryTable summaries=\(summaryTable.summaries.count), totalMissing=\(missingSummary.totalMissing)")
        print("dtypes[\"RUL\"]=\(String(describing: dtypes["RUL"]))")
        for name in cmapss.columnNames {
            guard let stats = statistics.columns[name] else { continue }
            let p90 = customDesc.numeric[name]?.percentiles["90%"]
            print("""
            \(name): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
            std=\(stats.standardDeviation?.description ?? "NaN"), \
            q1=\(stats.q1?.description ?? "NaN"), median=\(stats.median?.description ?? "NaN"), \
            q3=\(stats.q3?.description ?? "NaN"), p90=\(p90?.description ?? "NaN"), \
            unique=\(uniqueSummary[name] ?? 0)
            """)
        }

        let info = cmapss.infoSummary()
        print("\n=== Structured info (estimatedMemoryBytes = \(info.estimatedMemoryBytes)) ===")
        print(info)
        for column in info.columns {
            print("\(column.name): \(column.nonMissingCount) non-missing, type \(column.type)")
        }

        print("\n=== reduced, quantile, valueCounts, largest, smallest, drop ===")
        print("Column maxima:\n\(try cmapss.reduced(using: .max))")
        print("Column means:\n\(try cmapss.reduced(using: .mean))")
        print("Column 90th quantile:\n\(try cmapss.quantile(0.9))")
        print("failure_soon valueCounts:\n\(try cmapss.valueCounts(of: "failure_soon"))")
        print("Top 3 sensor_2:\n\(try cmapss.largest(3, by: "sensor_2"))")
        print("Lowest 3 RUL:\n\(try cmapss.smallest(3, by: "RUL"))")
        print("Without sensors:\n\(try cmapss.drop(columns: ["sensor_3", "sensor_7", "sensor_11", "sensor_15"]).head(3))")
    } catch {
        print("Structured statistics examples failed: \(error.localizedDescription)")
    }
}
