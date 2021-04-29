//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class VirologyTestingStateStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var virologyTestingStateStore: VirologyTestingStateStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        virologyTestingStateStore = VirologyTestingStateStore(store: encryptedStore)
    }
    
    func testCanLoadVirologyTestingInfo() throws {
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.positive
        let endDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "unacknowledgedTestResults":[
                {
                    "result":"\#(result.rawValue)",
                    "endDate":610531200,
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "requiresConfirmatoryTest":false
                }
            ]
        }
        """# .data(using: .utf8)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        let firstTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(firstTokens.pollingToken.value, pollingToken)
        XCTAssertEqual(firstTokens.diagnosisKeySubmissionToken.value, submissionToken)
        
        let testResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        let diagnosisSubmissionToken = try XCTUnwrap(testResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(testResult.endDate, endDate)
        XCTAssertEqual(testResult.testResult, result)
        XCTAssertEqual(diagnosisSubmissionToken.value, submissionToken)
    }
    
    func testCanLoadOldVirologyTestingInfo() throws {
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.positive
        let endDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":610531200,
                "diagnosisKeySubmissionToken":"\#(submissionToken)",
                "requiresConfirmatoryTest":false
            }
        }
        """# .data(using: .utf8)
        
        let virologyTestingStateStore = VirologyTestingStateStore(store: encryptedStore)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        let firstTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(firstTokens.pollingToken.value, pollingToken)
        XCTAssertEqual(firstTokens.diagnosisKeySubmissionToken.value, submissionToken)
        
        let testResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        let diagnosisSubmissionToken = try XCTUnwrap(testResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(testResult.endDate, endDate)
        XCTAssertEqual(testResult.testResult, result)
        XCTAssertEqual(diagnosisSubmissionToken.value, submissionToken)
    }
    
    func testCanSaveVirologyTestingInfo() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(
            pollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        let firstTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(firstTokens.pollingToken, pollingToken)
        XCTAssertEqual(firstTokens.diagnosisKeySubmissionToken, submissionToken)
    }
    
    func testCanSavePositiveTestResult() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .positive)
        XCTAssertEqual(savedResult.endDate, date)
        XCTAssertEqual(savedResult.testKitType, .labResult)
        XCTAssertEqual(savedSubmissionToken, submissionToken)
    }
    
    func testCanSaveNegativeTestResult() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .negative)
        XCTAssertEqual(savedResult.endDate, date)
        XCTAssertEqual(savedResult.testKitType, .labResult)
        XCTAssertEqual(savedSubmissionToken, submissionToken)
    }
    
    func testCanSaveVoidTestResult() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .void,
            testKitType: .labResult,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .void)
        XCTAssertEqual(savedResult.endDate, date)
        XCTAssertEqual(savedResult.testKitType, .labResult)
        XCTAssertEqual(savedSubmissionToken, submissionToken)
    }
    
    func testSaveMultipleResultsGetCorrectOrder() throws {
        let voidTestResult = VirologyTestResult(
            testResult: .void,
            testKitType: .labResult,
            endDate: Date()
        )
        let voidSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        virologyTestingStateStore.saveResult(
            virologyTestResult: voidTestResult,
            diagnosisKeySubmissionToken: voidSubmissionToken,
            requiresConfirmatoryTest: false
        )
        
        let positiveTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        let positiveSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        virologyTestingStateStore.saveResult(
            virologyTestResult: positiveTestResult,
            diagnosisKeySubmissionToken: positiveSubmissionToken,
            requiresConfirmatoryTest: false
        )
        
        let negativeTestResult = VirologyTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date()
        )
        let negativeSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        virologyTestingStateStore.saveResult(
            virologyTestResult: negativeTestResult,
            diagnosisKeySubmissionToken: negativeSubmissionToken,
            requiresConfirmatoryTest: false
        )
        
        let firstResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(firstResult.testResult, TestResult(positiveTestResult.testResult))
        XCTAssertEqual(firstResult.endDate, positiveTestResult.endDate)
        XCTAssertEqual(firstResult.testKitType, .labResult)
        XCTAssertEqual(firstResult.diagnosisKeySubmissionToken, positiveSubmissionToken)
        
        virologyTestingStateStore.remove(testResult: firstResult)
        
        let secondResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(secondResult.testResult, TestResult(negativeTestResult.testResult))
        XCTAssertEqual(secondResult.endDate, negativeTestResult.endDate)
        XCTAssertEqual(secondResult.testKitType, .labResult)
        XCTAssertEqual(secondResult.diagnosisKeySubmissionToken, negativeSubmissionToken)
        
        virologyTestingStateStore.remove(testResult: secondResult)
        
        let thirdResult = try XCTUnwrap(virologyTestingStateStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(thirdResult.testResult, TestResult(voidTestResult.testResult))
        XCTAssertEqual(thirdResult.endDate, voidTestResult.endDate)
        XCTAssertEqual(thirdResult.testKitType, .labResult)
        XCTAssertEqual(thirdResult.diagnosisKeySubmissionToken, voidSubmissionToken)
    }
    
    func testRelevantResultIsPublished() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let publishedResult = try virologyTestingStateStore.$virologyTestResult.await().get()
        
        XCTAssertEqual(publishedResult?.testResult, .positive)
        XCTAssertEqual(publishedResult?.testKitType, .labResult)
        XCTAssertEqual(publishedResult?.endDate, date)
        XCTAssertEqual(publishedResult?.diagnosisKeySubmissionToken, submissionToken)
    }
    
    func testNextRelevantResultIsPublishedOnDeleteOfTheFormer() throws {
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let nextTestResult = VirologyTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date()
        )
        virologyTestingStateStore.saveResult(
            virologyTestResult: nextTestResult,
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false
        )
        
        let publishedResult = try virologyTestingStateStore.$virologyTestResult.await().get()
        
        XCTAssertEqual(publishedResult?.testResult, .positive)
        XCTAssertEqual(publishedResult?.testKitType, .labResult)
        XCTAssertEqual(publishedResult?.endDate, virologyTestResult.endDate)
        XCTAssertEqual(publishedResult?.diagnosisKeySubmissionToken, submissionToken)
        
        virologyTestingStateStore.remove(testResult: publishedResult!)
        
        let nextPublishedResult = try virologyTestingStateStore.$virologyTestResult.await().get()
        
        XCTAssertEqual(nextPublishedResult?.testResult, .negative)
        XCTAssertEqual(nextPublishedResult?.testKitType, .labResult)
        XCTAssertEqual(nextPublishedResult?.endDate, nextTestResult.endDate)
        XCTAssertNil(nextPublishedResult?.diagnosisKeySubmissionToken)
        
    }
    
    func testCanDeleteVirologyTestingTokens() throws {
        let removePollingToken = PollingToken(value: .random())
        let removeSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let keepPollingToken = PollingToken(value: .random())
        let keepSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: removePollingToken, diagnosisKeySubmissionToken: removeSubmissionToken)
        virologyTestingStateStore.saveTest(pollingToken: keepPollingToken, diagnosisKeySubmissionToken: keepSubmissionToken)
        
        let tokens = VirologyTestTokens(
            pollingToken: removePollingToken,
            diagnosisKeySubmissionToken: removeSubmissionToken
        )
        virologyTestingStateStore.removeTestTokens(tokens)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(1, virologyTestTokens.count)
        let savedTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(savedTokens.diagnosisKeySubmissionToken, keepSubmissionToken)
        XCTAssertEqual(savedTokens.pollingToken, keepPollingToken)
    }
    
    func testCanDeleteLastVirologyTestingTokens() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let tokens = VirologyTestTokens(
            pollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        virologyTestingStateStore.removeTestTokens(tokens)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(0, virologyTestTokens.count)
    }
    
    func testCanDeleteVirologyTestResult() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        
        let result = VirologyStateTestResult(
            testResult: TestResult(virologyTestResult.testResult),
            testKitType: TestKitType(virologyTestResult.testKitType),
            endDate: virologyTestResult.endDate,
            diagnosisKeySubmissionToken: submissionToken,
            requiresConfirmatoryTest: false
        )
        virologyTestingStateStore.remove(testResult: result)
        
        XCTAssertNil(virologyTestingStateStore.virologyTestResult)
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(1, virologyTestTokens.count)
    }
    
    func testCanDeleteVirologyTestingInfo() throws {
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.positive
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":610531200,
                "diagnosisKeySubmissionToken":"\#(submissionToken)"
            }
        }
        """# .data(using: .utf8)
        
        virologyTestingStateStore.delete()
        XCTAssertNil(virologyTestingStateStore.virologyTestTokens)
    }
}
