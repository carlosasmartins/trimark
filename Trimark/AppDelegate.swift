//
//  AppDelegate.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var appCoordinator: AppCoordinator = .init()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let homeViewController = Home.make()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        appCoordinator.replaceRootViewController(navigationController)
        
        return true
    }
}
