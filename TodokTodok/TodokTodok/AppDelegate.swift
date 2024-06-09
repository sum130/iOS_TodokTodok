//
//  AppDelegate.swift
//  TodokTodok
//
//  Created by sumin Kong on 2024/05/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //firebase 연결
        FirebaseApp.configure()
        
        //firebase에 저장
        Firestore.firestore().collection("book").document("name").setData(["name": "bookName"])
        
        //storage에 이미지 저장
        let image = UIImage(named: "papa")!
        let imageData = image.jpegData(compressionQuality: 1.0)
        let reference = Storage.storage().reference().child("library").child("papa")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        reference.putData(imageData!, metadata: metaData) { _ in }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

