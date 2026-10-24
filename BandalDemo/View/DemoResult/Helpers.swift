//
//  Helpers.swift
//  BandalDemo
//

import Foundation
import Bandal

enum DemoResult {}

func loadBundledCSV(_ name: String, maximumRows: Int? = nil) throws -> DataFrame {
    guard let url = Bundle.main.url(forResource: name, withExtension: "csv") else {
        throw DataFrameError.invalidCSV("Bundled resource '\(name).csv' was not found.")
    }
    return try DataFrame(contentsOfCSV: url, maximumRows: maximumRows)
}

func numericValue(_ value: DataValue) -> Double? {
    guard case .number(let number) = value else { return nil }
    return number
}

enum DemoValidationError: Error, LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message): "Demo validation failed: \(message)"
        }
    }
}

func validateDemo(_ condition: Bool, _ message: String) throws {
    guard condition else { throw DemoValidationError.failed(message) }
}

@available(*, deprecated, message: "Use dataFrame.groupBy(key).aggregate([Aggregation(...)]) instead")
func aggregateColumns(
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
