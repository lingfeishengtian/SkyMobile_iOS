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
    @IBOutlet weak var TableContainerView: UIView!
    
    var AccountsStored: [Account] = []
    var CurrentPreferences = Preferences()
    var TableView = UITableView(frame: CGRect())
    
    //ADD ALLOW FOR ONLY SAVE ONE ACCOUNT PREFERENCE
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
        
        CurrentPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
    }

    func SetUpAccounts(){
        if let data = UserDefaults.standard.data(forKey: "AccountStorageService"){
            AccountsStored = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Account]
        }
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
}

class TableSettingsViewController: UITableViewController{
    @IBOutlet weak var ModernUISwitch: UISwitch!
    
    @IBAction func ModernUISwitchChanged(_ sender: Any) {
        let New = SettingsViewController.LoadPreferencesFromSavedLibrary()
        New.ModernUI = ModernUISwitch.isOn
        SettingsViewController.SavePreferencesIntoLibraryAndApplication(pref: New)
    }
    
    override func viewDidLoad() {
        ModernUISwitch.isOn = InformationHolder.GlobalPreferences.ModernUI
    }
}
