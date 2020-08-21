//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension InformationBox {
    public enum Content {
        case title(String)
        case heading(String)
        case body(String)
        case view(UIView)
    }
    
    public static func information(color: Style.InformationColor = .darkBlue, _ views: [UIView]) -> InformationBox {
        InformationBox(
            views: views,
            style: .information(color),
            backgroundColor: .clear
        )
    }
    
    public static var information: (
        purple: ([Content]) -> InformationBox,
        orange: ([Content]) -> InformationBox,
        lightBlue: ([Content]) -> InformationBox,
        turquoise: ([Content]) -> InformationBox,
        darkBlue: ([Content]) -> InformationBox
    ) {
        (
            { .information(color: .purple, $0) },
            { .information(color: .orange, $0) },
            { .information(color: .lightBlue, $0) },
            { .information(color: .turquoise, $0) },
            { .information(color: .darkBlue, $0) }
        )
        
    }
    
    public static func information(_ text: String) -> InformationBox {
        .information([UILabel().styleAsBody().set(text: text)])
    }
    
    public static func information(title: String, body: [String]) -> InformationBox {
        .information([.heading(title)] + body.map { .body($0) })
    }
    
    public static func information(_ content: Content...) -> InformationBox {
        .information(content)
    }
    
    public static func information(color: Style.InformationColor = .darkBlue, _ content: [Content]) -> InformationBox {
        .information(color: color, content.map { content -> UIView in
            switch content {
            case .title(let text):
                return UILabel().styleAsTertiaryTitle().set(text: text)
            case .heading(let text):
                return UILabel().styleAsHeading().set(text: text)
            case .body(let text):
                return UILabel().styleAsBody().set(text: text)
            case .view(let view):
                return view
            }
        })
    }
}