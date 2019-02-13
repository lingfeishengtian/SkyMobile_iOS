//
//  SettingsViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 2/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var SettingsNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
    }
    
    @objc func goBack(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        self.present(vc, animated: true, completion: nil)
    }
}
