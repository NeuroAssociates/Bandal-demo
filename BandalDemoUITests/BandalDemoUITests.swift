//
//  BandalDemoUITests.swift
//  BandalDemoUITests
//

import XCTest

@MainActor
final class BandalDemoUITests: XCTestCase {
    private let outputTimeout: TimeInterval = 10

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testInitialDemoDisplaysRenderedOutput() throws {
        let app = XCUIApplication()
        app.launch()

        let initialDemo = app.descendants(matching: .any)["selectedDemo-csvOverview"]
        XCTAssertTrue(initialDemo.waitForExistence(timeout: outputTimeout))

        let output = app.staticTexts["demoOutput"]
        XCTAssertTrue(output.waitForExistence(timeout: outputTimeout))
        waitForOutputToLoad(in: output)
    }

    func testSelectingDemoUpdatesSelectionAndOutput() throws {
        let app = XCUIApplication()
        app.launch()

        let missingValuesDemo = app.descendants(matching: .any)["demo-missingValues"]
        XCTAssertTrue(missingValuesDemo.waitForExistence(timeout: outputTimeout))
        missingValuesDemo.click()

        let selectedDemo = app.descendants(matching: .any)["selectedDemo-missingValues"]
        XCTAssertTrue(selectedDemo.waitForExistence(timeout: outputTimeout))

        let output = app.staticTexts["demoOutput"]
        XCTAssertTrue(output.waitForExistence(timeout: outputTimeout))
        waitForOutputToLoad(in: output)
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    private func waitForOutputToLoad(in output: XCUIElement) {
        let outputHasLoaded = NSPredicate(
            format: "value != nil AND value != %@ AND value != %@",
            "",
            "Preparing output…"
        )
        let expectation = expectation(for: outputHasLoaded, evaluatedWith: output)
        wait(for: [expectation], timeout: outputTimeout)
    }
}
