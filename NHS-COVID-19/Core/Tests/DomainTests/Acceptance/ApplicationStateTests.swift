//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

class ApplicationStateTests: AcceptanceTestCase {
    
    // MARK: - Exposure Notification Activation state
    
    func testEnteringErrorStateIfActivationFails() throws {
        guard case .starting = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        exposureNotificationManager.activationCompletionHandler?(TestError(""))
        
        guard case .failedToStart = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfOnARestrictedDevice() throws {
        try completeExposureNotificationActivation(authorizationStatus: .restricted)
        
        guard case .failedToStart = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfAuthorizationDenied() throws {
        try completeExposureNotificationActivation(authorizationStatus: .notAuthorized)
        
        guard case .canNotRunExposureNotification(.authorizationDenied(let openSettings), _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        openSettings()
        
        XCTAssertEqual(application.openedURL?.absoluteString, application.instanceOpenSettingsURLString)
    }
    
    func testEnteringOnboardingStateAfterSuccessfulActivation() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, let openUrl) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let url = URL(string: "https://example.com")!
        openUrl(url)
        
        XCTAssertEqual(application.openedURL, url)
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfBluetoothDisabled() throws {
        try completeRunningWithBluetoothDisabled()
        
        guard case .canNotRunExposureNotification(.bluetoothDisabled, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringOnboardingStateAfterExposureNotificationDisabled() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .disabled)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testDeniedUserNotificationsState() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .denied)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testUserCanAuthorizeUserNotifications() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    // MARK: - User Notifications Authorization Status
    
    func testABackgroundTaskIsScheduledWhenRunningExposureNotification() throws {
        try completeRunning()
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        XCTAssertNotNil($instance.processingTaskRequestManager.request)
    }
    
    func testNegativeTestResultInIndexCaseGoesToNeededForNegativeResultNoIsolation() throws {
        let now = LocalDay.today
        
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.negative
        
        let endDay = now.advanced(by: -2)
        
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
                "endDate":\#(endDay.startOfDay.timeIntervalSinceReferenceDate),
                "diagnosisKeySubmissionToken":"\#(submissionToken)",
                "requiresConfirmatoryTest":false
            }
        }
        """# .data(using: .utf8)
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResultNotIsolating = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
    
    func testNegativeTestResultInBothCasesGoesToNeededForNegativeResult() throws {
        #warning("Need to make sure we eventually inject date everywhere")
        let now = LocalDay.today
        let contactExposureDay = now.advanced(by: -5)
        let contactIsolationStart = now.advanced(by: -4)
        let onsetDay = now.advanced(by: -2)
        
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.negative
        
        encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {
                "hasAcknowledgedEndOfIsolation": false,
                "hasAcknowledgedStartOfIsolation": true,
                "contactCaseInfo" : {
                    "exposureDay" : {
                        "day" : \#(contactExposureDay.gregorianDay.dateComponents.day!),
                        "month" : \#(contactExposureDay.gregorianDay.dateComponents.month!),
                        "year" : \#(contactExposureDay.gregorianDay.dateComponents.year!)
                    },
                    "isolationFromStartOfDay":{
                        "day" : \#(contactIsolationStart.gregorianDay.dateComponents.day!),
                        "month" : \#(contactIsolationStart.gregorianDay.dateComponents.month!),
                        "year" : \#(contactIsolationStart.gregorianDay.dateComponents.year!)
                    }
                },
                "indexCaseInfo" : {
                    "selfDiagnosisDay" : {
                        "day" : \#(now.gregorianDay.dateComponents.day!),
                        "month" : \#(now.gregorianDay.dateComponents.month!),
                        "year" : \#(now.gregorianDay.dateComponents.year!)
                    },
                    "onsetDay" : {
                        "day" : \#(onsetDay.gregorianDay.dateComponents.day!),
                        "month" : \#(onsetDay.gregorianDay.dateComponents.month!),
                        "year" : \#(onsetDay.gregorianDay.dateComponents.year!)
                    }
                }
            }
        }
        """# .data(using: .utf8)
        
        let endDay = now.advanced(by: 5)
        
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
                "endDate":\#(endDay.startOfDay.timeIntervalSinceReferenceDate),
                "diagnosisKeySubmissionToken":"\#(submissionToken)",
                "requiresConfirmatoryTest":false
            }
        }
        """# .data(using: .utf8)
        
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResultContinueToIsolate = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
}
