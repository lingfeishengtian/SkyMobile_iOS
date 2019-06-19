//
//  PreferenceBundle.swift
//  SkyMobile
//
//  Created by Hunter Han on 6/11/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

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
