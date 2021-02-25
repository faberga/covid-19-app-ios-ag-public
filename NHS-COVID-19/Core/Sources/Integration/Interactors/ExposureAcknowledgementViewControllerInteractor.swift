//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

struct ExposureAcknowledgementViewControllerInteractor: ContactCaseAcknowledgementViewController.Interacting {
    private let openURL: (URL) -> Void
    private var _acknowledge: () -> Void
    
    init(openURL: @escaping (URL) -> Void, acknowledge: @escaping () -> Void) {
        self.openURL = openURL
        _acknowledge = acknowledge
    }
    
    func acknowledge() {
        _acknowledge()
    }
    
    func didTapOnlineLink() {
        openURL(ExternalLink.nhs111Online.url)
    }
    
    func exposureFAQsLinkTapped() {
        openURL(ExternalLink.exposureFAQs.url)
    }
    
    func didTapDailyContactTesting() {
        openURL(ExternalLink.dailyContactTestingInformation.url)
    }
}
