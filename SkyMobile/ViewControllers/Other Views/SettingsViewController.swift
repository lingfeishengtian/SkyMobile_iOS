//
//  SettingsViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 2/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class PreferenceController: UIViewController{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var isFromLockScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromLockScreen{
            navBar.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(goBackToHome(sender:)))
        }else{
            navBar.leftBarButtonItem = UIBarButtonItem.init(title: "Refresh", style: .done, target: self, action: #selector(goBackToHome(sender:)))
        }
        loadPrefsIntoUI()
    }
    
    @objc func goBackToHome(sender: Any){
        if isFromLockScreen{
            let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(vc, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            if PreferenceLoader.findPref(prefID: "modernUI"){
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
                self.present(vc, animated: true, completion: nil)
            }else{
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func loadPrefsIntoUI(){
        let frame = self.view.frame
        for ind in 0...InformationHolder.GlobalPreferences.count-1{
            let pref = InformationHolder.GlobalPreferences[ind]
            let viewHeight = 60
            let view = PreferenceBundle(frame: CGRect(x: 10, y: ind * viewHeight + 10 * (ind + 1), width: Int(frame.width - 20), height: viewHeight), pref: pref, shouldBeAbleToEdit: pref.editableOnLockscreen || !isFromLockScreen)

            scrollView.addSubview(view)
        }
    }
}


