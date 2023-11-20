//
//  SceneDelegate.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var tabController: UITabBarController?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //MARK: Setup Logged In UI
        self.tabController = UITabBarController()
        let tabController = self.tabController
        let vc0 = UINavigationController(rootViewController: HomeBuilder.build())
        let vc1 = UINavigationController(rootViewController: PhotosBuilder.build())
        let vc2 = UINavigationController(rootViewController: NotesViewController())
        let vc3 = UINavigationController(rootViewController: ChatViewController())
        tabController?.viewControllers = [vc0, vc1, vc2, vc3]
        tabController?.selectedIndex = 1 // FIXME: - Reset back to zero
        tabController?.tabBar.tintColor = .systemPink
        tabController?.tabBar.unselectedItemTintColor = .black
        vc0.tabBarItem.image = UIImage(systemName: "heart")
        vc1.tabBarItem.image = UIImage(systemName: "photo")
        vc2.tabBarItem.image = UIImage(systemName: "note.text")
        vc3.tabBarItem.image = UIImage(systemName: "message")

        vc0.title = "Home"
        vc1.title = "Photos"
        vc2.title = "Notes"
        vc3.title = "Chat"

        // MARK: - Check For Auth & Navigate
        navigateFromAuth()

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
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
    }


}

extension SceneDelegate {
    func navigateFromAuth() {
        Task {
            do {
                LottieHUD.shared.showWithoutDelay()
                let session = try await SensitiveData.supabase.auth.session
                print(session)
                window?.rootViewController = tabController
                LottieHUD.shared.dismiss()
            } catch {
                window?.rootViewController = LoginViewController()
                LottieHUD.shared.dismiss()
            }
        }
    }
}

