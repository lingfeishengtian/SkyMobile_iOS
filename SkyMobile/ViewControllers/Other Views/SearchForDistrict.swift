//
//  SearchForDistrict.swift
//  SkyMobile
//
//  Created by Hunter Han on 5/8/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation
import WebKit

class DistrictSearcher{
    static var stateSelections:[State] = []
    static var stateSelectionsFinishedInit = false
    static var getStateOptionsJavascript =
"""
function getStates(){
var StatesSeparated = ""
let ElementsOfStateOptions = skyAcademy.window.document.querySelectorAll("option")
for (var state in ElementsOfStateOptions){
let StateName = ElementsOfStateOptions[state].text
let StateValue = ElementsOfStateOptions[state].value

if(StateName != undefined && StateValue != 0){
StatesSeparated += StateName + ":" + StateValue + "@SWIFT_SEPARATED_STATE_THIS_IS_NOT_A_STATE_NAME_ABCFFF133@"
}
}
return StatesSeparated
}
getStates()
"""
    
    //CALL WHEN APPLICATION IS LOADING
    //Hint: $0.querySelector("select").value = 141
    static func initStateSelections(observer: LoginPortalSearcherObserver, picker: UIPickerView){
        let loginPortalSearchWebsite = WKWebView()
        let loginPortalURLRequestPage = URLRequest(url: URL(string: "https://www.skyward.com/parents-and-students/district-login-search")!)
        loginPortalSearchWebsite.load(loginPortalURLRequestPage)
        
        LoginPortalSearcherObserver.webView = loginPortalSearchWebsite
        LoginPortalSearcherObserver.webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        observer.picker = picker
        
        LoginPortalSearcherObserver.webView.addObserver(observer, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
}

class LoginPortalSearcherObserver: NSObject{
    static var webView = WKWebView()
    var picker = UIPickerView()
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            if (LoginPortalSearcherObserver.webView.estimatedProgress == 1) {
                if(LoginPortalSearcherObserver.webView.url?.absoluteString == "https://www.skyward.com/parents-and-students/district-login-search"){
                    LoginPortalSearcherObserver.webView.evaluateJavaScript(DistrictSearcher.getStateOptionsJavascript){ (result, err) in
                        if (err == nil){
                            let resultText = result as! String
                            let separated = resultText.components(separatedBy: "@SWIFT_SEPARATED_STATE_THIS_IS_NOT_A_STATE_NAME_ABCFFF133@")
                            
                            for stateWithValue in separated{
                                let specificStateWithValue = stateWithValue.components(separatedBy: ":")
                                if (specificStateWithValue.count >= 2){
                                    let NewState = State(name: specificStateWithValue[0], value: Int(specificStateWithValue[1]) ?? -1)
                                    DistrictSearcher.stateSelections.append(NewState)
                                }
                            }
                            DistrictSearcher.stateSelectionsFinishedInit = true
                            self.picker.reloadAllComponents()
                        }
                    }
                }
            }
        }
    }
}

struct State{
    var name: String
    var value: Int
}
