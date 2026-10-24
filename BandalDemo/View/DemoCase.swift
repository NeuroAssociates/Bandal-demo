//
//  DemoCase.swift
//  BandalDemo
//

import Foundation

enum DemoCase: String, CaseIterable, Identifiable {
    case csvOverview
    case headAndTail
    case summary
    case missingValues
    case derivedColumns
    case filtering
    case joining
    case regionalAggregation
    case factoryAnalysis
    case numericDataFrame
    case csvOptions
    case jsonAndMarkdown
    case queryAndPredicates
    case stringsAndDates
    case tableMaintenance
    case joinStrategies
    case typedValues
    case reshapeAndWindows
    case studentAnalysis
    case cmapssAnalysis
    case mimiiAnalysis
    case seriesBasics
    case structuredStatistics
    case correlationAnalysis
    case sequenceTransforms
    case runtimeBackend

    var id: Self { self }
}
