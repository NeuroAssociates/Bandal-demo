import Foundation
import Bandal

enum PlaygroundSupport {
    static func loadCSV(_ name: String, maximumRows: Int? = nil) throws -> DataFrame {
        try DataFrame(
            contentsOfCSV: csvURL(name),
            maximumRows: maximumRows
        )
    }

    static func csvURL(_ name: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: name, withExtension: "csv") else {
            throw DataFrameError.invalidCSV("Bundled resource '\(name).csv' was not found.")
        }
        return url
    }

    static func number(_ value: DataValue) -> Double? {
        guard case .number(let value) = value else { return nil }
        return value
    }

    static func validate(_ condition: Bool, _ message: String) throws {
        guard condition else {
            throw PlaygroundValidationError.failed(message)
        }
    }

    @available(*, deprecated, message: "Use dataFrame.groupBy(key).aggregate([Aggregation(...)]) instead")
    static func aggregateColumns(
        _ dataFrame: DataFrame,
        by key: String,
        _ aggregations: [(column: String, function: AggregateFunction)]
    ) throws -> DataFrame {
        guard !aggregations.isEmpty else {
            throw DataFrameError.emptyColumns
        }
        return try dataFrame
            .groupBy(key)
            .aggregate(aggregations.map { Aggregation($0.column, using: $0.function) })
    }
}

private enum PlaygroundValidationError: Error, LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message): "Playground validation failed: \(message)"
        }
    }
}
