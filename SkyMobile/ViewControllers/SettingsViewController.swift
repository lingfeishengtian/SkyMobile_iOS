//
//  SettingsViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 2/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var SettingsNavigationItem: UINavigationItem!
    @IBOutlet var WidthsToModify: [NSLayoutConstraint]!
    @IBOutlet weak var ModernUISwitch: UISwitch!
    @IBOutlet weak var AuthenticationSwitch: UISwitch!
    @IBOutlet var SettingsSections: [UIView]!
    
    var AccountsStored: [Account] = []
    var CurrentPreferences = Preferences()
    var TableView = UITableView(frame: CGRect())
    
    //ADD ALLOW FOR ONLY SAVE ONE ACCOUNT PREFERENCE
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
        
        CurrentPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
        SetupPreferences()
        
        let Width = self.view.frame.size.width
        for Constraint in WidthsToModify{
            Constraint.constant = Width-10
        }
        for Section in SettingsSections{
            Section.layer.cornerRadius = 5
        }
    }

    func SetupPreferences(){
        InformationHolder.GlobalPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
        ModernUISwitch.isOn = InformationHolder.GlobalPreferences.ModernUI
        AuthenticationSwitch.isOn = InformationHolder.GlobalPreferences.BiometricEnabled
    }
    
    @objc func goBack(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
        self.present(vc, animated: true, completion: nil)
    }
    
    static func LoadPreferencesFromSavedLibrary() -> Preferences{
        if let data = UserDefaults.standard.data(forKey: "Preferences"){
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! Preferences
        }
        return Preferences()
    }
    
    static func SavePreferencesIntoLibraryAndApplication(pref: Preferences){
        InformationHolder.GlobalPreferences = pref
        let ArchivedPrefs = NSKeyedArchiver.archivedData(withRootObject: pref)
        UserDefaults.standard.set(ArchivedPrefs, forKey: "Preferences")
    }
    
    @IBAction func ModernUISwitchChanged(_ sender: UISwitch) {
        InformationHolder.GlobalPreferences.ModernUI = sender.isOn
        SettingsViewController.SavePreferencesIntoLibraryAndApplication(pref: InformationHolder.GlobalPreferences)
    }
    
    @IBAction func BiometricAuthenticationSwitchChanged(_ sender: UISwitch) {
        InformationHolder.GlobalPreferences.BiometricEnabled = sender.isOn
        SettingsViewController.SavePreferencesIntoLibraryAndApplication(pref: InformationHolder.GlobalPreferences)
    }
    
}
