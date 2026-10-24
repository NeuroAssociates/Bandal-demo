//
//  DemoResultRenderer.swift
//  BandalDemo
//

import Foundation

/// A single block in a demo's execution output, either textual or tabular.
enum DemoResultBlock: Identifiable, Equatable {
    case text(title: String? = nil, content: String)
    case table(title: String? = nil, data: DemoTableData)

    var id: String {
        switch self {
        case .text(let title, let content):
            return "text-\(title ?? "")-\(content.hashValue)"
        case .table(let title, let data):
            let colNames = data.columns.map(\.title).joined(separator: ",")
            return "table-\(title ?? "")-\(colNames)-\(data.rows.count)"
        }
    }
}

/// The structured result of executing a demo case.
struct DemoExecutionResult: Equatable {
    let blocks: [DemoResultBlock]
    let executionTimeMilliseconds: Double

    var totalRowCount: Int {
        blocks.reduce(into: 0) { total, block in
            if case .table(_, let data) = block {
                total += data.rows.count
            }
        }
    }
}

/// Executes a demo case and returns structured blocks of text and tables.
func executeDemo(for demo: DemoCase) -> DemoExecutionResult {
    let startTime = ContinuousClock.now
    let blocks: [DemoResultBlock] = {
        do {
            switch demo {
            case .csvOverview: return try DemoResult.executeCSVOverview()
            case .headAndTail: return try DemoResult.executeHeadAndTail()
            case .summary: return try DemoResult.executeSummary()
            case .missingValues: return try DemoResult.executeMissingValues()
            case .derivedColumns: return try DemoResult.executeDerivedColumns()
            case .filtering: return try DemoResult.executeFiltering()
            case .joining: return try DemoResult.executeJoining()
            case .regionalAggregation: return try DemoResult.executeRegionalAggregation()
            case .factoryAnalysis: return try DemoResult.executeFactoryAnalysis()
            case .numericDataFrame: return try DemoResult.executeNumericDataFrame()
            case .csvOptions: return try DemoResult.executeCSVOptions()
            case .jsonAndMarkdown: return try DemoResult.executeJSONAndMarkdown()
            case .queryAndPredicates: return try DemoResult.executeQueryAndPredicates()
            case .stringsAndDates: return try DemoResult.executeStringsAndDates()
            case .tableMaintenance: return try DemoResult.executeTableMaintenance()
            case .joinStrategies: return try DemoResult.executeJoinStrategies()
            case .typedValues: return try DemoResult.executeTypedValues()
            case .reshapeAndWindows: return try DemoResult.executeReshapeAndWindows()
            case .studentAnalysis: return try DemoResult.executeStudentAnalysis()
            case .cmapssAnalysis: return try DemoResult.executeCMAPSSAnalysis()
            case .mimiiAnalysis: return try DemoResult.executeMIMIIAnalysis()
            case .seriesBasics: return try DemoResult.executeSeriesBasics()
            case .structuredStatistics: return try DemoResult.executeStructuredStatistics()
            case .correlationAnalysis: return try DemoResult.executeCorrelationAnalysis()
            case .sequenceTransforms: return try DemoResult.executeSequenceTransforms()
            case .runtimeBackend: return try DemoResult.executeRuntimeBackend()
            }
        } catch {
            return [
                .text(
                    title: String(localized: "Demo execution error:"),
                    content: error.localizedDescription
                )
            ]
        }
    }()
    let elapsed = startTime.duration(to: .now)
    let components = elapsed.components
    let milliseconds = Double(components.seconds) * 1_000
        + Double(components.attoseconds) / 1_000_000_000_000_000
    return DemoExecutionResult(blocks: blocks, executionTimeMilliseconds: milliseconds)
}

func renderResult(for demo: DemoCase) -> String {
    let startTime = ContinuousClock.now
    let output = {
        do {
            switch demo {
            case .csvOverview: return try DemoResult.renderCSVOverview()
            case .headAndTail: return try DemoResult.renderHeadAndTail()
            case .summary: return try DemoResult.renderSummary()
            case .missingValues: return try DemoResult.renderMissingValues()
            case .derivedColumns: return try DemoResult.renderDerivedColumns()
            case .filtering: return try DemoResult.renderFiltering()
            case .joining: return try DemoResult.renderJoining()
            case .regionalAggregation: return try DemoResult.renderRegionalAggregation()
            case .factoryAnalysis: return try DemoResult.renderFactoryAnalysis()
            case .numericDataFrame: return try DemoResult.renderNumericDataFrame()
            case .csvOptions: return try DemoResult.renderCSVOptions()
            case .jsonAndMarkdown: return try DemoResult.renderJSONAndMarkdown()
            case .queryAndPredicates: return try DemoResult.renderQueryAndPredicates()
            case .stringsAndDates: return try DemoResult.renderStringsAndDates()
            case .tableMaintenance: return try DemoResult.renderTableMaintenance()
            case .joinStrategies: return try DemoResult.renderJoinStrategies()
            case .typedValues: return try DemoResult.renderTypedValues()
            case .reshapeAndWindows: return try DemoResult.renderReshapeAndWindows()
            case .studentAnalysis: return try DemoResult.renderStudentAnalysis()
            case .cmapssAnalysis: return try DemoResult.renderCMAPSSAnalysis()
            case .mimiiAnalysis: return try DemoResult.renderMIMIIAnalysis()
            case .seriesBasics: return try DemoResult.renderSeriesBasics()
            case .structuredStatistics: return try DemoResult.renderStructuredStatistics()
            case .correlationAnalysis: return try DemoResult.renderCorrelationAnalysis()
            case .sequenceTransforms: return try DemoResult.renderSequenceTransforms()
            case .runtimeBackend: return try DemoResult.renderRuntimeBackend()
            }
        } catch {
            return "\(String(localized: "Demo execution error:")) \(error.localizedDescription)"
        }
    }()
    let elapsed = startTime.duration(to: .now)
    let components = elapsed.components
    let milliseconds = Double(components.seconds) * 1_000
        + Double(components.attoseconds) / 1_000_000_000_000_000
    return "\(output)\n\n\(String(localized: "Processing time:")) \(String(format: "%.2f", milliseconds)) ms"
}
