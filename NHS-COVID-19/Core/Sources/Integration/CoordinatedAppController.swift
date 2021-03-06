//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Interface
import Localization
import UIKit

public class CoordinatedAppController: AppController {
    
    private let coordinator: ApplicationCoordinator
    
    private var cancellable: [AnyCancellable] = []
    
    public var rootViewController: UIViewController = RootViewController()
    
    public let showBookATest = CurrentValueSubject<Bool, Never>(false)
    public let showContactTracingHub = CurrentValueSubject<Bool, Never>(false)
    public let showLocalInfoScreen = CurrentValueSubject<Bool, Never>(false)
    
    private var content: UIViewController? {
        didSet {
            #warning("Use WrappingViewController")
            // This avoid code duplication in `content.didSet`
            oldValue?.dismiss(animated: true, completion: nil)
            oldValue?.remove()
            if let content = content {
                rootViewController.addFilling(content)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
    
    fileprivate init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        coordinator.$state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }.store(in: &cancellable)
        
        coordinator.country.sink {
            Localization.country = $0
        }.store(in: &cancellable)
        
        coordinator.localeConfiguration.sink { config in
            UIView.appearance().applySemanticContentAttribute(configuration: config)
            
            UIApplication.shared.accessibilityLanguage = currentLocaleIdentifier(
                localeConfiguration: config
            )
            
            // The root view controller will be refreshed by this so do UIVIew stuff before this line.
            config.becomeCurrent()
        }.store(in: &cancellable)
        
        setupUI()
    }
    
    public func performBackgroundTask(task: BackgroundTask) {
        coordinator.performBackgroundTask(task: task)
    }
    
    public func handleUserNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        if let action = UserNotificationAction(rawValue: response.actionIdentifier) {
            coordinator.handleUserNotificationAction(action, completion: completionHandler)
        } else {
            if response.notification.request.identifier == UserNotificationType.exposureNotificationReminder.identifier {
                showContactTracingHub.send(true)
            } else if response.notification.request.identifier == UserNotificationType.localMessage(title: "", body: "").identifier {
                showLocalInfoScreen.send(true)
                Metrics.signpost(.didAccessLocalInfoScreenViaNotification)
            }
            
            completionHandler()
        }
    }
    
    private func update(for state: ApplicationState) {
        content = makeContent(for: state)
    }
    
    private func setupUI() {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = UIColor(.lightSurface)
        appearance.barTintColor = UIColor(.navigationBar)
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(.lightSurface)]
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
    }
    
}

extension CoordinatedAppController {
    
    /// Convenience initialiser; primarily to be used internally with modified services
    public convenience init(services: ApplicationServices, enabledFeatures: [Feature]) {
        let coordinator = ApplicationCoordinator(services: services, enabledFeatures: enabledFeatures)
        self.init(coordinator: coordinator)
    }
    
    /// Convenience initialiser used by the main app
    /// - Parameters:
    ///   - environment: Defaults to standard production environment.
    ///   - enabledFeatures: Defaults to all features.
    public convenience init(environment: Environment = .standard(), enabledFeatures: [Feature] = Feature.productionEnabledFeatures) {
        let services = ApplicationServices(standardServicesFor: environment)
        self.init(services: services, enabledFeatures: enabledFeatures)
    }
    
}
