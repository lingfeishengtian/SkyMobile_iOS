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
    @IBOutlet weak var LoginMethodSwitch: UISwitch!
    @IBOutlet var SettingsSections: [UIView]!
    @IBOutlet weak var ShowUpdateEveryTime: UISwitch!
    
    var isFromLockScreen = false
    var AccountsStored: [Account] = []
    var CurrentPreferences = Preferences()
    var TableView = UITableView(frame: CGRect())
    var importantUtils = ImportantUtils()
    
    //ADD ALLOW FOR ONLY SAVE ONE ACCOUNT PREFERENCE
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(title: "Refresh", style: .done, target: self, action: #selector(goBack(_:)))
        
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
        
        CurrentPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
        SetupPreferences()
        
        let Width = self.view.frame.size.width
        for Constraint in WidthsToModify{
            Constraint.constant = Width-11
        }
        for Section in SettingsSections{
            Section.layer.cornerRadius = 5
        }
        
        if isFromLockScreen{
            AuthenticationSwitch.isEnabled = false
            backButton.title = "Back"
        }
    }

    func SetupPreferences(){
        InformationHolder.GlobalPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
        ModernUISwitch.isOn = InformationHolder.GlobalPreferences.ModernUI
        AuthenticationSwitch.isOn = InformationHolder.GlobalPreferences.BiometricEnabled
        LoginMethodSwitch.isOn = InformationHolder.GlobalPreferences.AutoLoginMethodDoesStoreAllAvailableAccounts
        ShowUpdateEveryTime.isOn = InformationHolder.GlobalPreferences.ShowUpdateNotif
    }
    
    @objc func goBack(_ sender: Any){
        if isFromLockScreen{
            let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(vc, animated: true, completion: nil)
        }else{
            if InformationHolder.GlobalPreferences.ModernUI{
                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
                self.present(vc, animated: true, completion: nil)
            }else{
                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
                self.present(vc, animated: true, completion: nil)
            }
        }
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
    
    @IBAction func ShowUpdateSwitchChanged(_ sender: UISwitch) {
        InformationHolder.GlobalPreferences.ShowUpdateNotif = sender.isOn
        SettingsViewController.SavePreferencesIntoLibraryAndApplication(pref: InformationHolder.GlobalPreferences)
    }
    
    @IBAction func AutoLoginStorageSwitchChanged(_ sender: UISwitch) {
        var LoginMethod = ""
        if sender.isOn{
            LoginMethod = "account storage"
        }else{
            LoginMethod = "saved session"
        }
        let alertUserSavePassword = UIAlertController(title: "Hey there!", message: "Are you sure you want to change your login method to " + LoginMethod + "? SkyMobile saves all the accounts stored, so you won't lose your account data.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Save", style: .default){ alert in
            InformationHolder.GlobalPreferences.AutoLoginMethodDoesStoreAllAvailableAccounts = sender.isOn
            SettingsViewController.SavePreferencesIntoLibraryAndApplication(pref: InformationHolder.GlobalPreferences)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel){ alert in
            sender.isOn = !sender.isOn
        }
        alertUserSavePassword.addAction(OKAction)
        alertUserSavePassword.addAction(Cancel)
        self.present(alertUserSavePassword, animated: true, completion: nil)
    }
    
}
