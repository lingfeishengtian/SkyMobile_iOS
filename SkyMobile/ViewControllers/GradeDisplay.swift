//
//  GradeDisplay.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/5/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class GradeDisplay : UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(webView == nil){
            print("ERROR, webview not declared in GradeDisplay Class")
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let javascript1 = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
        self.webView.evaluateJavaScript(javascript1) { (result, error) in
            if error == nil {
                
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getHTMLCode(){
       // while(webView.url?.absoluteString != "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w"){ _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in}}
        view.addSubview(webView)
        let javascript =
            "var outerHTML = document.documentElement.outerHTML.toString()\n" +
        "outerHTML\n"
            self.webView.evaluateJavaScript(javascript) { (result, error) in
            if error == nil {
                    let returnedResults = result as! String
                    let Response = GradeResponder(returnedResults)
                    let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                    let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
                    vc.Courses = Response.Courses
                    vc.webView = self.webView
                print(Response.Courses)
                    self.present(vc, animated: true, completion: nil)
            }
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("### EP:", self.webView.estimatedProgress)
        if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w" {
            getHTMLCode()
        }
    }
}

