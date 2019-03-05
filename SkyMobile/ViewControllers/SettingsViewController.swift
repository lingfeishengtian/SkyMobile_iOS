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
    @IBOutlet weak var SettingsTableView: UITableView!
    
    var AccountsStored: [Account] = []
    var CurrentPreferences = Preferences()
    
    //ADD ALLOW FOR ONLY SAVE ONE ACCOUNT PREFERENCE
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
    }
    
    func SetUpAccounts(){
        if let data = UserDefaults.standard.data(forKey: "AccountStorageService"){
            AccountsStored = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Account]
        }
    }
    
    @objc func goBack(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        self.present(vc, animated: true, completion: nil)
    }
    
    static func LoadPreferencesFromSavedLibrary() -> Preferences{
        if let data = UserDefaults.standard.data(forKey: "Preferences"){
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! Preferences
        }
        return Preferences()
    }
    
    func SavePreferencesIntoLibraryAndApplication(){
        InformationHolder.GlobalPreferences = CurrentPreferences
        let ArchivedPrefs = NSKeyedArchiver.archivedData(withRootObject: CurrentPreferences)
        UserDefaults.standard.set(ArchivedPrefs, forKey: "Preferences")
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
}

class SettingsTableViewCell: UITableViewCell{
    private var Status: SettingsTableViewAvailableStatuses = SettingsTableViewAvailableStatuses.NormalSettingView
    
    func ChangeStatus(statusToUpdateTo status: SettingsTableViewAvailableStatuses) -> (Bool){
        if status == Status{
            return false
        }else{
            switch status{
            case .NormalSettingView:
                print("Switching to Normal")
            case .EmptySettingsView:
                print("Switching to Empty")
            case .TextSettingsView:
                print("Switching to User input text")
            }
        }
        return true
    }
}

enum SettingsTableViewAvailableStatuses{
    case NormalSettingView
    case EmptySettingsView
    case TextSettingsView
}
