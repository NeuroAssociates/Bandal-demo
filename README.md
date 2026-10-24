# BandalDemo

[한국어](README.ko.md) · [Bandal library](https://github.com/NeuroAssociates/Bandal)

**BandalDemo** is a macOS SwiftUI app that showcases [**Bandal**](https://github.com/NeuroAssociates/Bandal), a Swift package for tabular data analysis modeled after Python's [pandas](https://pandas.pydata.org/). Each demo runs real Bandal code against bundled CSV files and shows both the Swift source and the rendered result side by side.

Bandal's numeric engine is accelerated by [MLX Swift](https://github.com/ml-explore/mlx-swift) (included in this repository as `mlx-swift`).

## Features

The sidebar contains 26 demos covering the main areas of the library:

- **CSV & inspection**: CSV overview, `head`/`tail`, summaries, CSV options, table maintenance
- **Missing values & derived columns**: filling, dropping, row-computed columns
- **Querying**: filtering, `RowPredicate`, expression-based `query(...)`, strings and dates
- **Grouping & joins**: regional aggregation, join strategies, `melt`, `pivotTable`, rolling/expanding windows
- **Statistics**: structured `describe`/`info`, correlation and covariance, series basics, typed values
- **Export**: JSON and Markdown output
- **Numeric engine**: MLX-backed runtime and execution policies
- **Real-world style scenarios**: factory shipments, student grades, turbofan engine health (CMAPSS), and machine sound anomalies (MIMII)

Each demo's Swift code lives in `BandalDemo/Playground`, and its result view in `BandalDemo/View/DemoResult`. The UI is localized in English and Korean.

## Requirements

- macOS (the project targets macOS 27.0; Apple silicon recommended for MLX acceleration)
- Xcode with the Metal toolchain installed
- Swift Package dependencies (resolved automatically by Xcode): [Bandal](https://github.com/NeuroAssociates/Bandal), [mlx-swift](https://github.com/ml-explore/mlx-swift), [swift-numerics](https://github.com/apple/swift-numerics)

## Getting Started

1. Clone the repository.
2. Open `BandalDemo.xcodeproj` in Xcode.
3. Select the **BandalDemo** scheme and run (⌘R).

## Bundled Data

All CSV files in `BandalDemo/Data` are either **fictional (synthetic) data** or **publicly available data**. None of them contain real personal, customer, or confidential business information.

| File | Rows | Description | Origin |
| ---- | ---- | ----------- | ------ |
| `factory_data.csv` | 40,000 | Steel-product shipment records | Fictional data (customers, plants, and specifications are made up) |
| `global_sales_raw.csv` | 9 | Sales by country, intentionally messy for cleaning demos | Fictional data |
| `country_info.csv` | 10 | Country, region, and sales team lookup | Fictional data |
| `cmapss_sample.csv` | 1,000 | Turbofan engine sensor readings with remaining useful life (RUL) | Excerpt of the public NASA C-MAPSS dataset, downloaded from [Kaggle](https://www.kaggle.com) |
| `mimii_sample.csv` | 800 | Acoustic features (RMS, spectral centroid, zero-crossing rate) for normal/anomalous machine sounds | Excerpt of the public MIMII dataset, downloaded from [Kaggle](https://www.kaggle.com) |

The CMAPSS and MIMII files are **only a small portion** of the datasets obtained from Kaggle and may have been sampled or reduced to selected columns/features for demonstration. They are not complete or official copies. Those datasets remain the property of their original authors and are subject to their original licenses and terms; please obtain the full data and review the terms from the original sources before using them for any other purpose.

## Credits

- [Ned Park](https://africastart.com) of Neuro Associates

## License

The source code of this project is licensed under the [MIT](LICENSE) license. The bundled third-party datasets (CMAPSS, MIMII) are not covered by this license.
