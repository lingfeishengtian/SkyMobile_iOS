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
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if InformationHolder.SkywardWebsite.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfacademichistory001.w"{
            let JS = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
            InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
        }
    }
}
