//
//  AppDelegate.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/10/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ShortcutItemPicked: String? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        ViewController.SetAccountsAs3DTouch()
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        ShortcutItemPicked = shortcutItem.type
        
        if let ShortcutOption = ShortcutItemPicked{
            for account in ImportantUtils.GetAccountValuesFromStorage(){
                if ShortcutOption == account.NickName{
                    let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                    let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    vc.UserName = account.Username
                    vc.Password = account.Password
                    vc.ShouldLoginWhenFinishedLoadingSite = true
                    
                    UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                    break
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        ViewController.SetAccountsAs3DTouch()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

