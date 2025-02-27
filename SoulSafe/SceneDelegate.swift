//
//  SceneDelegate.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // swiftlint:disable all
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // swiftlint:enable all
        
        // Create main navigation controller
        let navigationController = UINavigationController()
        
        // Create window
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        
        // Create and start app coordinator
        let viewModelFactory = ViewModelFactory(container: DependencyContainer.shared)
        appCoordinator = AppCoordinator(
            navigationController: navigationController,
            viewModelFactory: viewModelFactory
        )
        appCoordinator?.start()
        
        window?.makeKeyAndVisible()
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
    
    // 在這個方法中處理來自 URL 的操作
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // 檢查是否有傳遞的 URLContext
        guard let urlContext = URLContexts.first else {
            return
        }
        // 從 URLContext 中獲取 URL
        let url = urlContext.url
        
        // 拆解 URL
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            if let scheme = components.scheme {
                print("Scheme: \(scheme)")
            }
            if let groupID = components.host {
                print("Host: \(groupID)")
                // 這邊讓 JoinGroupManager 推出去前設立新的 Window，別用 Scene Delegate 的 window
                // 改用 topViewController 找尋目前最上層的 VC 呈現。
                if let topVC = window?.topViewController {
                    let joinGroupHelper = JoinGroupHelper(viewController: topVC)
                    joinGroupHelper.getJoinGroupInfo(groupID)
                }
            }
            // present 丟給某個 VC
            // VC 去拿該群組的資料
            // 顯示群組名稱、確認加入、取消按鈕
            // 點擊後打 API 並 Delegate 通知需要的 VC 刷新 data
            // Dismiss VC
        }
    }
}
