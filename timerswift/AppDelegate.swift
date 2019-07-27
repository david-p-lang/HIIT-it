//
//  AppDelegate.swift
//  timerswift
//
//  Created by David Lang on 1/26/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        let initialViewController = WorkoutItemViewController(nibName: nil, bundle: nil)
        navigationController.viewControllers = [initialViewController]
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        return true
    }



}

