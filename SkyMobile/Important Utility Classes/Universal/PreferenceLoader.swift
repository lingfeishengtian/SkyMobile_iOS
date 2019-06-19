//
//  PreferenceLoader.swift
//  SkyMobile
//
//  Created by Hunter Han on 6/11/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation

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
