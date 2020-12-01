//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct Isolation: Equatable {
    public enum Reason: Equatable {
        case indexCase(hasPositiveTestResult: Bool, isSelfDiagnosed: Bool)
        case contactCase(ContactCaseTrigger)
        case bothCases(hasPositiveTestResult: Bool, isSelfDiagnosed: Bool)
    }
    
    public var fromDay: LocalDay
    public var untilStartOfDay: LocalDay
    public var reason: Reason
}

extension Isolation {
    public var endDate: Date {
        untilStartOfDay.startOfDay
    }
}

extension Isolation {
    
    public var canBookTest: Bool {
        isIndexCase
    }
    
    public var canFillQuestionnaire: Bool {
        !isIndexCase
    }
    
    var interestedInExposureNotifications: Bool {
        switch reason {
        case .bothCases, .contactCase:
            return false
        case .indexCase(let hasPositiveTestResult, _):
            return !hasPositiveTestResult
        }
    }
    
    public var isIndexCase: Bool {
        switch reason {
        case .indexCase, .bothCases:
            return true
        case .contactCase:
            return false
        }
    }
    
    var isContactCase: Bool {
        switch reason {
        case .indexCase:
            return false
        case .contactCase, .bothCases:
            return true
        }
    }
    
    var isContactCaseOnly: Bool {
        switch reason {
        case .indexCase, .bothCases:
            return false
        case .contactCase:
            return true
        }
    }
}
