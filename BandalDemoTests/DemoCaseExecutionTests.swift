//
//  DemoCaseExecutionTests.swift
//  BandalDemoTests
//

import Foundation
import Testing
@testable import BandalDemo

@Suite("Demo case execution")
struct DemoCaseExecutionTests {
    @Test("Every demo case produces output without errors", arguments: DemoCase.allCases)
    func executesWithoutError(demo: DemoCase) {
        let result = executeDemo(for: demo)
        #expect(!result.blocks.isEmpty)
        for block in result.blocks {
            if case .text(let title, _) = block {
                #expect(title != String(localized: "Demo execution error:"), "\(demo) failed")
            }
        }
        #expect(!renderResult(for: demo).contains(String(localized: "Demo execution error:")))
    }
}
