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
        if self.tabBar.items![0] == item{
            if InformationHolder.SkywardWebsite.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfacademichistory001.w"{
                let JS = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
                InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
            }
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        var tabFrame = self.tabBar.frame
//        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
//        tabFrame.size.height = 45
//        tabFrame.origin.y = self.view.frame.size.height - 45
//        self.tabBar.frame = tabFrame
//    }
}
