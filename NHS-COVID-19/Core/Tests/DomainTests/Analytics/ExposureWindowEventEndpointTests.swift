//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowEventEndpointTests: XCTestCase {
    private let endpointExposureWindow = ExposureWindowEventEndpoint(
        latestAppVersion: Version(major: 3, minor: 12),
        postcode: "LL44",
        hasPositiveTest: false
    )
    
    private let endpointExposureWindowPositiveTest = ExposureWindowEventEndpoint(
        latestAppVersion: Version(major: 3, minor: 12),
        postcode: "LL44",
        hasPositiveTest: true
    )
    
    func testEncodingExposureWindow() throws {
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "\(endpointExposureWindow.hasPositiveTest ? EpidemiologicalEventType.exposureWindowPostiveTest : EpidemiologicalEventType.exposureWindow)",
              "version": 1
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        
        let actual = try endpointExposureWindow.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingExposureWindowPositveTest() throws {
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "testType": "\(TestType.unknown)",
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "\(endpointExposureWindowPositiveTest.hasPositiveTest ? EpidemiologicalEventType.exposureWindowPostiveTest : EpidemiologicalEventType.exposureWindow)",
              "version": 1
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        let actual = try endpointExposureWindowPositiveTest.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
}
