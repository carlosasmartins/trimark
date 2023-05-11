//
//  AppCoordinator.swift
//  Trimark
//
//  Created by Carlos Martins on 08/05/2023.
//

import UIKit

class AppCoordinator {
    var mainWindow: UIWindow
    
    init(
        window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    ) {
        self.mainWindow = window
        
        mainWindow.makeKeyAndVisible()
    }
    
    func replaceRootViewController(
        _ viewController: UIViewController
    ) {
        mainWindow.rootViewController = viewController
    }
}
