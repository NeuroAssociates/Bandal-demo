import Foundation
import Playgrounds
import Bandal

#Playground {
    do {
        let sales = try PlaygroundSupport.loadCSV("global_sales_raw")
        let countryInfo = try PlaygroundSupport.loadCSV("country_info")
        let factory = try PlaygroundSupport.loadCSV("factory_data", maximumRows: 5_000)

        print("=== CSV loading and inspection ===")
        print("Global sales shape: \(sales.shape)")
        print("Sales columns: \(sales.columnNames)")
        print("Global sales preview:\n\(try sales.head(5))")
        print("Global sales info:\n\(sales.info())")

        // Use the new structured API to access statistics as Swift objects.
        let description = sales.describeStructured()
        print("Global sales descriptive statistics (structured):")
        for columnName in description.columnOrder {
            if let stats = description.numeric[columnName] {
                print("""
                \(columnName): count=\(stats.count), mean=\(stats.mean?.description ?? "NaN"), \
                std=\(stats.standardDeviation?.description ?? "NaN"), \
                min=\(stats.min?.description ?? "NaN"), max=\(stats.max?.description ?? "NaN"), \
                median=\(stats.median?.description ?? "NaN"), q1=\(stats.q1?.description ?? "NaN"), \
                q3=\(stats.q3?.description ?? "NaN")
                """)
            } else if let summary = description.nonNumeric[columnName] {
                print("""
                \(columnName) (non-numeric): count=\(summary.count), unique=\(summary.unique), \
                top=\(summary.top?.description ?? "NaN"), freq=\(summary.freq)
                """)
            }
        }

        // Programmatic statistics for numeric columns
        let stats = sales.statistics()
        print("Numeric columns with computed statistics: \(stats.columns.keys.sorted())")

        print("Global sales descriptive statistics (text):\n\(description.describe())")
        print("Last 2 sales rows:\n\(try sales.tail(2))")
        print("Country lookup shape: \(countryInfo.shape)")
        print("Factory data sample shape (first 5,000 rows): \(factory.shape)")
    } catch {
        print("CSV inspection failed: \(error.localizedDescription)")
    }
}
