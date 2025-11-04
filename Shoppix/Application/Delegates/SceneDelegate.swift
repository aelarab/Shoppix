//
//  SceneDelegate.swift
//  Shoppix
//
//  Created by adham ragap on 03/11/2025.
//

import UIKit
import FirebaseCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if FirebaseApp.app() == nil {
                    FirebaseApp.configure()
                }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
           let navController: UINavigationController
        if let _ = UserDefaults.standard.string(forKey: "userId") {
                 let tabBarVC = HomeTabBarViewController()
                   window.rootViewController = tabBarVC
            } else {
                let firstVC = LandSceenViewController(nibName: "LandSceenViewController", bundle: nil)
                navController = UINavigationController(rootViewController: firstVC)
                window.rootViewController = navController
            }
             
               window.makeKeyAndVisible()
        self.window = window
      
    }

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

