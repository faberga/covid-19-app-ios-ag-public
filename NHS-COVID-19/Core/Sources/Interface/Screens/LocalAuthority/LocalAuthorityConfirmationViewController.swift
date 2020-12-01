//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol LocalAuthorityConfirmationViewControllerInteracting {
    func confirm(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError>
    func dismiss()
}

private class LocalAuthorityConfirmationContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = LocalAuthorityConfirmationViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting, postcode: String, localAuthority: LocalAuthority) {
        self.interactor = interactor
        
        super.init(
            scrollingViews: [
                UIImageView(.onboardingPostcode)
                    .styleAsDecoration(),
                UILabel().set(text: localize(.local_authority_confirmation_heading(postcode: postcode, localAuthority: localAuthority.name))).styleAsPageHeader(),
                localizeAndSplit(.local_authority_confirmation_description)
                    .map { UILabel().styleAsBody().set(text: String($0)) },
            ],
            primaryButton: (
                title: localize(.local_authority_confirmation_button),
                action: {
                    _ = interactor.confirm(localAuthority: localAuthority)
                    interactor.dismiss()
                }
            )
        )
    }
}

public class LocalAuthorityConfirmationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = LocalAuthorityConfirmationViewControllerInteracting
    
    public init(interactor: Interacting, postcode: String, localAuthority: LocalAuthority, hideBackButton: Bool) {
        super.init(content: LocalAuthorityConfirmationContent(interactor: interactor, postcode: postcode, localAuthority: localAuthority))
        title = localize(.local_authority_confirmation_title)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
        navigationItem.hidesBackButton = hideBackButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
