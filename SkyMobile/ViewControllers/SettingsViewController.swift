//
//  SettingsViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 2/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var SettingsNavigationItem: UINavigationItem!
    @IBOutlet weak var SettingsTableView: UITableView!
    
    var AccountsStored: [Account] = []
    var CurrentPreferences = Preferences()
    
    //ADD ALLOW FOR ONLY SAVE ONE ACCOUNT PREFERENCE
    override func viewDidLoad() {
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.SettingsNavigationItem.leftBarButtonItem = backButton
        SettingsNavigationItem.hidesBackButton = false
        SettingsTableView.delegate = self
        SettingsTableView.dataSource = self
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
    
    func SavePreferencesIntoLibraryAndApplication(){
        InformationHolder.GlobalPreferences = CurrentPreferences
        let ArchivedPrefs = NSKeyedArchiver.archivedData(withRootObject: CurrentPreferences)
        UserDefaults.standard.set(ArchivedPrefs, forKey: "Preferences")
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsTableViewCell
        
    }
    
    
}

class SettingsTableViewCell: UITableViewCell{
    private var Status: SettingsTableViewAvailableStatuses = SettingsTableViewAvailableStatuses.NormalSettingView
    var SettingName = UILabel(frame: CGRect.null)
    var isEnabled = UISwitch(frame: CGRect.null)
    
    func Setup(settingName: String = " Placeholder ", isSettingEnabled: Bool = false) {
        SettingName.text = settingName
        SettingName.center = CGPoint(x: 10, y: self.frame.size.height/2)
        SettingName.frame = CGRect(x: 10, y: SettingName.frame.minY, width: self.frame.size.width - 30, height: self.frame.size.height)
        SettingName.isHidden = false
        SettingName.isEnabled = true
        
        isEnabled.center = CGPoint(x: 10, y: self.frame.size.height/2)
        isEnabled.frame = CGRect(x: SettingName.frame.maxX + 10, y: SettingName.frame.minY, width: self.frame.size.width - 40, height: self.frame.size.height)
        isEnabled.isHidden = false
        isEnabled.isEnabled = true
        isEnabled.isOn = isSettingEnabled
    }
       
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
