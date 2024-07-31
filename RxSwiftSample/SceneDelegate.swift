//
//  SceneDelegate.swift
//  RxSwiftSample
//
//  Created by NERO on 7/30/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let scene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: scene)
            
            let rootViewController = UINavigationController(rootViewController: ViewController())
            
            self.window?.rootViewController = rootViewController
            self.window?.makeKeyAndVisible()
        }
    }
}
