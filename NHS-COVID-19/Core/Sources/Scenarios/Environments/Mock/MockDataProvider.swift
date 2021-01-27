//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class MockDataProvider: ObservableObject {
    static let testResults = ["POSITIVE", "NEGATIVE", "VOID"]
    static let testKitType = ["LAB_RESULT", "RAPID_RESULT"]
    
    private let _objectWillChange = PassthroughSubject<Void, Never>()
    
    var objectWillChange: AnyPublisher<Void, Never> {
        _objectWillChange.eraseToAnyPublisher()
    }
    
    @UserDefault("mocks.redPostcodes", defaultValue: "")
    var redPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.amberPostcodes", defaultValue: "")
    var amberPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.yellowPostcodes", defaultValue: "")
    var yellowPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.greenPostcodes", defaultValue: "")
    var greenPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.neutralPostcodes", defaultValue: "")
    var neutralPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.redLocalAuthorities", defaultValue: "")
    var redLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.amberLocalAuthorities", defaultValue: "")
    var amberLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.yellowLocalAuthorities", defaultValue: "")
    var yellowLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.greenLocalAuthorities", defaultValue: "")
    var greenLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.neutralLocalAuthorities", defaultValue: "")
    var neutralLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.riskyVenueIDs", defaultValue: "")
    var riskyVenueIDs: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.orderTestWebsite", defaultValue: "")
    var orderTestWebsite: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testReferenceCode", defaultValue: "d23f - gre4")
    var testReferenceCode: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.minimumOSVersion", defaultValue: "13.5.0")
    var minimumOSVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.minimumAppVersion", defaultValue: "1.0.0")
    var minimumAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.latestAppVersion", defaultValue: "1.0.0")
    var latestAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.recommendedAppVersion", defaultValue: "1.0.0")
    var recommendedAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.recommendedOSVersion", defaultValue: "1.0.0")
    var recommendedOSVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.receivedTestResult", defaultValue: 0)
    var receivedTestResult: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testKitType", defaultValue: 0)
    var testKitType: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.keySubmissionSupported", defaultValue: true)
    var keySubmissionSupported: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testResultEndDateDaysAgo", defaultValue: 0)
    var testResultEndDateDaysAgo: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var testResultEndDateDaysAgoString: String {
        get {
            String(testResultEndDateDaysAgo)
        }
        set {
            if let value = Int(newValue) {
                testResultEndDateDaysAgo = value
            }
        }
    }
    
    @UserDefault("mocks.useFakeENContacts", defaultValue: false)
    var useFakeENContacts: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.numberOfContacts", defaultValue: 0)
    var numberOfContacts: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var numberOfContactsString: String {
        get {
            String(numberOfContacts)
        }
        set {
            if let value = Int(newValue) {
                numberOfContacts = value
            }
        }
    }
    
    @UserDefault("mocks.contactDaysAgo", defaultValue: 1)
    var contactDaysAgo: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var contactDaysAgoString: String {
        get {
            String(contactDaysAgo)
        }
        set {
            if let value = Int(newValue) {
                contactDaysAgo = value
            }
        }
    }
    
}
