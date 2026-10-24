import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        print("============================================================")
        print("📊 Factory Data Benchmark Pipeline (Swift Bandal)")
        print("============================================================")

        let clock = ContinuousClock()
        let pipelineStart = clock.now
        
        @Sendable func toMilliseconds(_ duration: Duration) -> Double {
            let (seconds, attoseconds) = duration.components
            return Double(seconds) * 1000.0 + Double(attoseconds) / 1_000_000_000_000_000.0
        }

        // -------------------------------------------------------------
        // Step 1: Load CSV (Full 40,000 rows)
        // -------------------------------------------------------------
        var factory: DataFrame!
        let t1 = clock.measure {
            factory = try! PlaygroundSupport.loadCSV("factory_data")
        }
        print(String(format: "Step 1 [CSV Load]           : %8.2f ms (Shape: %@)", toMilliseconds(t1), factory.shape))

        // -------------------------------------------------------------
        // Step 2: Cleansing missing values and outliers
        // - Quantity_Tons > 0
        // - Unit_Price_USD_per_Ton > 0
        // - Thickness_mm < 900 (Exclude 999.9 sensor missing values)
        // - Quality_Status is not missing and non-empty
        // -------------------------------------------------------------
        var cleaned: DataFrame!
        let t2 = clock.measure {
            cleaned = try! factory.filterRows { row in
                guard let tons = row["Quantity_Tons"]?.numberValue, tons > 0,
                      let price = row["Unit_Price_USD_per_Ton"]?.numberValue, price > 0,
                      let thick = row["Thickness_mm"]?.numberValue, thick < 900,
                      case .string(let status) = row["Quality_Status"], !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else {
                    return false
                }
                return true
            }
        }
        print(String(format: "Step 2 [Data Cleansing]     : %8.2f ms (Remaining rows: %d)", toMilliseconds(t2), cleaned.rowCount))

        // -------------------------------------------------------------
        // Step 3: Derived columns & vectorized operations
        // - Revenue_USD = Quantity_Tons * Unit_Price_USD_per_Ton
        // - Shipment_Month = YYYY-MM
        // -------------------------------------------------------------
        var prepared: DataFrame!
        let t3 = clock.measure {
            let withRevenue = try! cleaned.combining("Quantity_Tons", "Unit_Price_USD_per_Ton", using: .multiply, as: "Revenue_USD")
            let dates = try! withRevenue.values(in: "Shipment_Date")
            let months = dates.map { value -> DataValue in
                guard case .string(let str) = value, str.count >= 7 else { return .missing }
                return .string(String(str.prefix(7)))
            }
            prepared = try! withRevenue.withColumn(name: "Shipment_Month", values: months)
        }
        print(String(format: "Step 3 [Vector Math & Derive]: %8.2f ms", toMilliseconds(t3)))

        // -------------------------------------------------------------
        // Step 4: Multi-column sorting
        // - Shipment_Date ASC, Revenue_USD DESC
        // -------------------------------------------------------------
        var sorted: DataFrame!
        let t4 = clock.measure {
            sorted = try! prepared.sorted(by: [
                SortDescriptor("Shipment_Date", order: .ascending),
                SortDescriptor("Revenue_USD", order: .descending)
            ])
        }
        print(String(format: "Step 4 [Multi-Column Sort]  : %8.2f ms", toMilliseconds(t4)))

        // -------------------------------------------------------------
        // Step 5: Rolling window mean (window = 50)
        // -------------------------------------------------------------
        var rollingDF: DataFrame!
        let t5 = clock.measure {
            rollingDF = try! sorted.rolling("Quantity_Tons", window: 50, using: .mean)
        }
        print(String(format: "Step 5 [50-Row Rolling Mean]: %8.2f ms", toMilliseconds(t5)))

        // -------------------------------------------------------------
        // Step 6: Multi-key GroupBy & multi-aggregation
        // - GroupBy: Division, Market_Type
        // - Aggregations: Revenue_USD (sum, mean), Quantity_Tons (sum, count)
        // -------------------------------------------------------------
        var grouped: DataFrame!
        let t6 = clock.measure {
            grouped = try! rollingDF
                .groupBy("Division", "Market_Type")
                .aggregate([
                    Aggregation("Revenue_USD", using: .sum),
                    Aggregation("Revenue_USD", using: .mean),
                    Aggregation("Quantity_Tons", using: .sum),
                    Aggregation("Quantity_Tons", using: .count)
                ])
        }
        print(String(format: "Step 6 [Multi-Key GroupBy]  : %8.2f ms", toMilliseconds(t6)))

        // -------------------------------------------------------------
        // Step 7: Numeric summary statistics
        // -------------------------------------------------------------
        var stats: DataFrameStatistics!
        let t7 = clock.measure {
            let numericOnly = try! rollingDF.select("Quantity_Tons", "Unit_Price_USD_per_Ton", "Revenue_USD")
            stats = numericOnly.statistics()
        }
        print(String(format: "Step 7 [Numeric Statistics] : %8.2f ms", toMilliseconds(t7)))

        let totalDuration = clock.now - pipelineStart
        print("------------------------------------------------------------")
        print(String(format: "⏱️ Total Pipeline Execution Time: %8.2f ms", toMilliseconds(totalDuration)))
        print("============================================================")

        print("\nPreview of Grouped Aggregation:")
        print(try grouped.head(6))
    } catch {
        print("Benchmark failed: \(error.localizedDescription)")
    }
}
