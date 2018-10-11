//
//  ViewController.swift
//  GradeChecker
//
//  Created by Hunter Han on 9/28/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView = WKWebView()
    var webViewtemp = WKWebView()
    
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var ProgressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!
        let request = URLRequest(url: url)
        webView.frame = CGRect(x: 0, y: 250, width: 0, height: 0)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
    
        webView.load(request)
        view.addSubview(webView)

        webView.allowsBackForwardNavigationGestures = true
        
        print(webView.url!.absoluteString)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func readyToSwitchViews(withWebView tempView: WKWebView) {
        if(!checkURL(url: tempView.url!)){
            let alertController = UIAlertController(title: "Uh-Oh",
                                                    message: "Invalid Credentials",
                                                    preferredStyle: UIAlertController.Style.alert)
            let confirmAction = UIAlertAction(
            title: "OK", style: UIAlertAction.Style.destructive) { (action) in
                // ...
            }
            alertController.addAction(confirmAction)
            present(alertController, animated: true, completion: nil)
        }else{
            switchScreen(withWebView: tempView)
        }
    }
//    // this handles target=_blank links by opening them in the same view
//    func webView(_ webView: WKWebView,
//                 createWebViewWith configuration: WKWebViewConfiguration,
//                 for navigationAction: WKNavigationAction,
//                 windowFeatures: WKWindowFeatures) -> WKWebView? {
//        print("REQUESTINGL:   " + (navigationAction.request.url?.absoluteString)!)
//        if navigationAction.targetFrame == nil {
//            webView.load(navigationAction.request)
//        }
//        return nil
//    }
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let tempURL = navigationAction.request.url
            var components = URLComponents()
            components.scheme = tempURL?.scheme
            components.host = tempURL?.host
            components.path = (tempURL?.path)!
                webViewtemp = WKWebView(frame: CGRect(x: 0, y: 250, width: 0, height: 0), configuration: configuration)
                webViewtemp.uiDelegate = self
                webViewtemp.navigationDelegate = self
                webViewtemp.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
                webViewtemp.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                self.view.addSubview(webViewtemp)
            
                return webViewtemp
        }
        return nil
    }
    
    @IBAction func SubmitForm(_ sender: Any) {
        let OGColor = SubmitBtn.currentTitleColor
        enableButton(bool: false)
        changeColorOfButton(color: .gray)
        startStopLoading(start: true)
        let javascript = "login.value = \"\(UsernameField.text ?? "000000")\"; password.value = \"\(PasswordField.text ?? "000000")\"; bLogin.click();"
        webView.evaluateJavaScript(javascript) { (result, error) in
            if error == nil {
            }
        }
         _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
        let javascrip1t = "msgBtn1.click()"
        self.webView.evaluateJavaScript(javascrip1t) { (result, error) in
            if error == nil {
            }
        }
        }
        _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer) in
            self.changeColorOfButton(color: OGColor)
            self.enableButton(bool: true)
            self.startStopLoading(start: false)
        }
    }
    func startStopLoading(start: Bool){
        if(start){
        ProgressIndicator.startAnimating()
        }else{
            ProgressIndicator.stopAnimating()
        }
        lblLoading.isHidden = !start
    }
    func changeColorOfButton(color: UIColor){
        SubmitBtn.setTitleColor(color, for: .normal)
    }
    func enableButton(bool: Bool){
        SubmitBtn.isEnabled = bool
    }
    func checkURL(url: URL) -> Bool{
        print("CHECK: " + url.absoluteString)
        if url.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfhome01.w"{
            return true;
        }else{
            return false;
        }
    }
    func switchScreen(withWebView webViewa: WKWebView) {
        let mainStoryboard = UIStoryboard(name: "GradeDisplay", bundle: Bundle.main)
        let vc : GradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "GradeDisplay") as! GradeDisplay
        vc.webView = webViewa;
        self.present(vc, animated: true, completion: nil)
    
    }

    var runOnce = false
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webViewtemp.url!)
            
        }

        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // When page load finishes. Should work on each page reload.
            if (self.webViewtemp.estimatedProgress == 1) {
                
                _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
                print("### EP:", self.webView.estimatedProgress)
                    if self.webViewtemp.url?.absoluteString != nil && !self.runOnce {
                        print("TestURL: " + (self.webViewtemp.url?.absoluteString)!)
                        self.readyToSwitchViews(withWebView: self.webViewtemp)
                        self.runOnce = true
                }
            }
        }
        }
}
}
