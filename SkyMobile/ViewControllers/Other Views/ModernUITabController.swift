//
//  ModernUITabController.swift
//  SkyMobile
//
//  Created by Hunter Han on 3/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class ModernUITabController: UITabBarController{
    let importantUtils = ImportantUtils()
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if InformationHolder.SkywardWebsite.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfacademichistory001.w"{
            let JS = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
            InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
        }
        if (self.tabBar.items)![1] == item{
        if ViewController.LoginDistrict.GPACalculatorSupportType == GPACalculatorSupport.NoSupport || InformationHolder.isElementary{
            let message = "SkyMobile doesn't support GPA Calculator for this account yet."
            let CannotFindValidValue = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.selectedIndex = 0
            })
            CannotFindValidValue.addAction(OKOption)
            UIApplication.topViewController()?.show(CannotFindValidValue, sender: nil)
        }
        }
    }
}

class CreditsSection : UIViewController{
    
    @IBAction func goBack(_ sender: Any) {
        if ViewController.LoginSession{
            let storyboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            var vc: UIViewController
            if PreferenceLoader.findPref(prefID: "modernUI"){
                vc = storyboard.instantiateViewController(withIdentifier: "ModernUITableSelection")
            }else{
                vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
            }
            self.present(vc, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
