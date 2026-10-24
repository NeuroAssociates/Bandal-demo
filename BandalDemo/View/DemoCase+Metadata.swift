//
//  DemoCase+Metadata.swift
//  BandalDemo
//

import Foundation

extension DemoCase {
    var title: String {
        switch self {
        case .csvOverview: String(localized: "Load and Inspect CSV")
        case .headAndTail: String(localized: "View First and Last Rows")
        case .summary: String(localized: "Numeric Column Summary")
        case .missingValues: String(localized: "Inspect and Fill Missing Values")
        case .derivedColumns: String(localized: "Create Calculated and Categorized Columns")
        case .filtering: String(localized: "Filter Rows by Condition")
        case .joining: String(localized: "Join Country Information")
        case .regionalAggregation: String(localized: "Aggregate by Region and Team")
        case .factoryAnalysis: String(localized: "Analyze Factory Shipments")
        case .numericDataFrame: String(localized: "Create a Numeric DataFrame")
        case .csvOptions: String(localized: "CSV Options and Round-Trip")
        case .jsonAndMarkdown: String(localized: "JSON I/O, RenderOptions, and Markdown Export")
        case .queryAndPredicates: String(localized: "Query Expressions, RowPredicates, and Row Access")
        case .stringsAndDates: String(localized: "String Operations, Date Components, and Vector Math")
        case .tableMaintenance: String(localized: "Deduplicate, Rename, Concatenate, and Sample")
        case .joinStrategies: String(localized: "Join Types, Multi-Key Joins, and Aggregations")
        case .typedValues: String(localized: "Convert Boolean and Date Values")
        case .reshapeAndWindows: String(localized: "Melt, Pivot, Explode, Transpose, and Windows")
        case .studentAnalysis: String(localized: "Student Grades Analysis with Pandas-Style Operations")
        case .cmapssAnalysis: String(localized: "CMAPSS Engine Failure Risk Analysis")
        case .mimiiAnalysis: String(localized: "MIMII Acoustic Anomaly Analysis")
        case .seriesBasics: String(localized: "Work with Series, Vector Math, and Value Counts")
        case .structuredStatistics: String(localized: "Structured Statistics, Quantiles, Info, and Top Rows")
        case .correlationAnalysis: String(localized: "Correlation and Covariance Matrices")
        case .sequenceTransforms: String(localized: "Cumulative, Shift, Clip, and Fill Operations")
        case .runtimeBackend: String(localized: "Numeric Engine, ExecutionPolicy, and MLX Backend")
        }
    }

    var symbol: String {
        switch self {
        case .csvOverview: "doc.text"
        case .headAndTail: "rectangle.stack"
        case .summary: "chart.bar"
        case .missingValues: "checkmark.circle"
        case .derivedColumns: "plus.square.on.square"
        case .filtering: "line.3.horizontal.decrease"
        case .joining: "arrow.triangle.merge"
        case .regionalAggregation: "chart.pie"
        case .factoryAnalysis: "shippingbox"
        case .numericDataFrame: "number"
        case .csvOptions: "doc.badge.gearshape"
        case .jsonAndMarkdown: "curlybraces.square"
        case .queryAndPredicates: "magnifyingglass.circle"
        case .stringsAndDates: "textformat.abc.dottedunderline"
        case .tableMaintenance: "tablecells"
        case .joinStrategies: "arrow.left.arrow.right"
        case .typedValues: "calendar.badge.clock"
        case .reshapeAndWindows: "arrow.trianglehead.2.clockwise.rotate.90"
        case .studentAnalysis: "person.3"
        case .cmapssAnalysis: "engine.combustion"
        case .mimiiAnalysis: "waveform"
        case .seriesBasics: "list.number"
        case .structuredStatistics: "function"
        case .correlationAnalysis: "square.grid.3x3"
        case .sequenceTransforms: "chart.line.uptrend.xyaxis"
        case .runtimeBackend: "cpu"
        }
    }

    var explanation: String {
        switch self {
        case .csvOverview:
            String(localized: "Load a bundled CSV and inspect its preview, missing-value counts, column types, and summary statistics.")
        case .headAndTail:
            String(localized: "Quickly inspect the beginning and end of a dataset with head(_:) and tail(_:).")
        case .summary:
            String(localized: "Use describe() to view numeric means, standard deviations, and quartiles, along with the most common text values.")
        case .missingValues:
            String(localized: "Inspect per-column missing counts, missingSummary(), and missingMask() tables; then compare fillMissing, replacing, dropMissing, and sample statistics.")
        case .derivedColumns:
            String(localized: "Create derived columns using vectorized combining, scaling, ranking, and row-by-row withColumn(name:computing:) closures.")
        case .filtering:
            String(localized: "Pass a condition to filterRows(_:) to select countries with 2025 sales of at least 1,000,000.")
        case .joining:
            String(localized: "Join additional country details with leftJoin(_:on:) and inspect the resulting data frame.")
        case .regionalAggregation:
            String(localized: "Combine groupBy(_:) and aggregate(_:using:) to calculate sales totals by region and country counts by team.")
        case .factoryAnalysis:
            String(localized: "Calculate revenue from a fictional US manufacturer's shipment volumes and USD unit prices, then aggregate by month and division.")
        case .numericDataFrame:
            String(localized: "Create a DataFrame from numeric arrays, then select columns and calculate summary statistics.")
        case .csvOptions:
            String(localized: "Configure the delimiter, header, selected columns, and types; then write and reread a CSV to compare the results.")
        case .jsonAndMarkdown:
            String(localized: "Load and export JSON records or column dictionaries, convert to Swift dictionaries, customize text table rendering with RenderOptions, and export GitHub-flavored Markdown tables.")
        case .queryAndPredicates:
            String(localized: "Filter rows using pandas-style query strings or composable RowPredicate expressions, and access individual rows, slices, and typed cells via DataRow and subscripts.")
        case .stringsAndDates:
            String(localized: "Clean and inspect text columns with string helpers, extract calendar components from Date columns, and apply vectorized arithmetic, abs, ranking, and value mapping.")
        case .tableMaintenance:
            String(localized: "Inspect duplicate masks with duplicatedRows, deduplicate by selected columns, rename columns, concatenate batches, and draw reproducible random samples.")
        case .joinStrategies:
            String(localized: "Compare inner, full, and multi-key joins with custom column suffixes; aggregate with sum, mean, median, std, first, and last; and filter grouped results.")
        case .typedValues:
            String(localized: "Inspect Boolean and date type inference, select columns by type, and explicitly convert string columns.")
        case .reshapeAndWindows:
            String(localized: "Explore melt, pivotTable, exploded list columns, transposed tables, broadcasting group transforms, and row-count or time-interval rolling and expanding windows.")
        case .studentAnalysis:
            String(localized: "Recreate a student grades workflow with column selection, calculated columns, compound filters, multi-key sorting, conditional categories, and class-level aggregation.")
        case .cmapssAnalysis:
            String(localized: "Compare engine sensor statistics by near-failure status using the bundled CMAPSS sample, then sort rows by remaining useful life (RUL).")
        case .mimiiAnalysis:
            String(localized: "Calculate statistics by normal and anomalous groups in the bundled MIMII acoustic sample, then find anomalous rows with high RMS.")
        case .seriesBasics:
            String(localized: "Extract a column as a Series, perform vectorized arithmetic (+, -, *, /), compute quantiles, modes, ranks, and valueCounts, and reduce with every AggregateFunction.")
        case .structuredStatistics:
            String(localized: "Inspect statistics(), custom percentiles with describeStructured, summaryTable(), missingSummary(), uniqueSummary(), dtypes, quantile(_:), largest/smallest, and drop(columns:).")
        case .correlationAnalysis:
            String(localized: "Compute pairwise Pearson correlation and sample covariance matrices for numeric columns in the CMAPSS and MIMII samples.")
        case .sequenceTransforms:
            String(localized: "Apply cumulative sum, product, minimum, and maximum; shift, difference, and percent change; clip and round values; and forward or backward fill gaps.")
        case .runtimeBackend:
            String(localized: "Inspect BandalRuntime, compare ExecutionPolicy (.automatic, .cpu, .gpu, .native) with withExecutionPolicy, bridge columns via MLXVector, and benchmark 40,000 factory rows.")
        }
    }
}
