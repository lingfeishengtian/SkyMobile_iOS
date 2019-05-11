//
//  DistrictPickerView.swift
//  SkyMobile
//
//  Created by Hunter Han on 4/24/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import UIKit

class DistrictPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var Parent: ViewController? = nil
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static var DistrictLinks: [District] =
        [District(name: "FBISD", URLLink: URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!, gpaSupportType: GPACalculatorSupport.HundredPoint),
         District(name: "HPISD", URLLink: URL(string: "https://skyward.hpisd.org/scripts/wsisa.dll/WService=wsEAplus/fwemnu01.w")!, gpaSupportType: GPACalculatorSupport.NoSupport)]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DistrictPickerView.DistrictLinks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: DistrictPickerView.DistrictLinks[row].DistrictName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ViewController.LoginDistrict = DistrictPickerView.DistrictLinks[row]
        print("Attempted to change to ", ViewController.LoginDistrict.DistrictLink.absoluteString)
        if let view = Parent{
            view.reloadSkyward()
        }
    }
}

class StatePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DistrictSearcher.stateSelections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: DistrictSearcher.stateSelections[row].name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
