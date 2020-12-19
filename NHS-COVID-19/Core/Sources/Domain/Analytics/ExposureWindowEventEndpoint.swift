//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
import UIKit

@available(iOS 13.7, *)
struct ExposureWindowEventEndpoint: HTTPEndpoint {
    
    var latestAppVersion: Version
    var postcode: String
    var hasPositiveTest: Bool
    
    func request(for input: ExposureWindowInfo) throws -> HTTPRequest {
        let payload = ExposureWindowEventPayload(window: input, hasPositiveTest: hasPositiveTest, latestAppliationVersion: latestAppVersion, postcode: postcode)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)
        return .post("/submission/mobile-analytics-events", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
}

struct ExposureWindowEventPayload: Codable {
    struct Event: Codable {
        struct Payload: Codable {
            var testType: TestType?
            var date: Date
            var infectiousness: Infectiousness
            var scanInstances: [ScanInstance]
            var riskScore: Double
            var riskCalculationVersion: Int
        }
        
        struct ScanInstance: Codable {
            var minimumAttenuation: UInt8
            var typicalAttenuation: UInt8
            var secondsSinceLastScan: Int
        }
        
        enum Infectiousness: String, Codable {
            case none
            case standard
            case high
        }
        
        var type: EpidemiologicalEventType
        var version: Int
        var payload: Payload
    }
    
    struct Metadata: Codable {
        var operatingSystemVersion: String
        var latestApplicationVersion: String
        var deviceModel: String
        var postalDistrict: String
    }
    
    var metadata: Metadata
    var events: [Event]
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload {
    init(window: ExposureWindowInfo, hasPositiveTest: Bool, latestAppliationVersion: Version, postcode: String) {
        let eventType = hasPositiveTest ? EpidemiologicalEventType.exposureWindowPostiveTest : EpidemiologicalEventType.exposureWindow
        let event = Event(type: eventType, version: 1, payload: Event.Payload(window: window, eventType: eventType))
        events = [event]
        metadata = Metadata(
            operatingSystemVersion: UIDevice.current.systemVersion,
            latestApplicationVersion: latestAppliationVersion.readableRepresentation,
            deviceModel: UIDevice.current.modelName,
            postalDistrict: postcode
        )
    }
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload.Event.Payload {
    init(window: ExposureWindowInfo, eventType: EpidemiologicalEventType) {
        if eventType == .exposureWindowPostiveTest {
            testType = TestType.unknown
        }
        
        date = window.date.startDate(in: .utc)
        infectiousness = ExposureWindowEventPayload.Event.Infectiousness(window.infectiousness)
        scanInstances = window.scanInstances.map(ExposureWindowEventPayload.Event.ScanInstance.init)
        riskScore = window.riskScore
        riskCalculationVersion = window.riskCalculationVersion
    }
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload.Event.Infectiousness {
    init(_ infectiousness: ExposureWindowInfo.Infectiousness) {
        switch infectiousness {
        case .none:
            self = .none
        case .standard:
            self = .standard
        case .high:
            self = .high
        @unknown default:
            self = .none
        }
    }
}

@available(iOS 13.7, *)
extension ExposureWindowEventPayload.Event.ScanInstance {
    init(_ scanInstance: ExposureWindowInfo.ScanInstance) {
        minimumAttenuation = scanInstance.minimumAttenuation
        secondsSinceLastScan = scanInstance.secondsSinceLastScan
        typicalAttenuation = scanInstance.typicalAttenuation
    }
}
