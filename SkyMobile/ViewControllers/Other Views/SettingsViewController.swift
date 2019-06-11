//
//  SettingsViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 2/12/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class PreferenceLoader{
    static func loadPreferencesFromJSON() -> [Preference]{
        let currentVersion = PreferenceLoader.getCurrentVersionPrefs()
        if ImportantUtils.isKeyPresentInUserDefaults(key: "settingsPrefs"){
            if let data = UserDefaults.standard.data(forKey: "settingsPrefs"){
                let storedPrefs = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Preference]
                if PreferenceLoader.doPrefsContainDiscrepencies(pref1: storedPrefs, pref2: currentVersion){
                    return mergePrefs(stored: storedPrefs, pref2: currentVersion)
                }else{
                    return storedPrefs
                }
            }
        }else{
            return currentVersion
        }
        return []
    }
    
    static func doPrefsContainDiscrepencies(pref1: [Preference], pref2:[Preference]) -> Bool{
        if pref1.count != pref2.count{
            return true
        }
        
        for pref in pref1{
            for compPref in pref2{
                if compPref.id == pref.id && (compPref.title != pref.title || compPref.desc != pref.desc || compPref.editableOnLockscreen != pref.editableOnLockscreen){
                    return true
                }
            }
        }
        
        return false
    }
    
    static func mergePrefs(stored: [Preference], pref2: [Preference]) -> [Preference]{
        var finPref: [Preference] = stored
        for pref in pref2{
            var found = false
            for compPref in finPref{
                if compPref.id == pref.id{
                    compPref.title = pref.title
                    compPref.desc = pref.desc
                    compPref.editableOnLockscreen = pref.editableOnLockscreen
                    found = true
                }
            }
            if !found{
                finPref.append(pref)
            }
        }
        
        return finPref
    }
    
    static func getCurrentVersionPrefs() -> [Preference]{
        if let path = Bundle.main.path(forResource: "preferences", ofType: "json"){
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONDecoder().decode(PreferenceParent.self, from: data)
                return jsonResult.preferences
            }catch let error{
                print(error)
            }
        }
        return []
    }
    
    static func writePreferencesToPrefs(arr: [Preference]){
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: arr)
        UserDefaults.standard.set(encodedData, forKey: "settingsPrefs")
    }
    
    static func findPref(prefID: String) -> Bool{
        for pref in InformationHolder.GlobalPreferences{
            if pref.id == prefID{
                return pref.defaultBool
            }
        }
        return false
    }
    
    static func findPrefIndex(prefID: String) -> Int{
        for ind in 0...InformationHolder.GlobalPreferences.count{
            if InformationHolder.GlobalPreferences[ind].id == prefID{
                return ind
            }
        }
        return -1
    }
}

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

class PreferenceBundle: UIView{
    let preferenceStored: Preference
    
    init(frame: CGRect, pref: Preference, shouldBeAbleToEdit editable: Bool = true) {
        preferenceStored = pref
        super.init(frame: frame)
        let viewHeight = Int(self.frame.height)
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = 10.0
        self.isHidden = false
        let onOff = UISwitch(frame: CGRect(x: Int(self.frame.width - 60), y: viewHeight/2 - 15, width: 25, height: viewHeight))
        onOff.isOn = preferenceStored.defaultBool
        let title = UILabel(frame: CGRect(x: 10, y: 0, width: Int(self.frame.width), height: viewHeight))
        title.textColor = UIColor.white
        title.backgroundColor = UIColor.clear
        title.text = preferenceStored.title
        title.font = UIFont.systemFont(ofSize: 20)
        onOff.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        if !editable{
            onOff.isEnabled = false
        }
        self.addSubview(title)
        self.addSubview(onOff)
    }
    
    required init?(coder aDecoder: NSCoder) {
        preferenceStored = Preference(iid: "Test", ititle: "test", idesc: "no", iBoolL: false)
        super.init(coder: aDecoder)
        print("This function should not be used...")
    }
    
    @objc func switchChanged(sender: Any){
        preferenceStored.defaultBool = !preferenceStored.defaultBool
        PreferenceLoader.writePreferencesToPrefs(arr: InformationHolder.GlobalPreferences)
    }
}
