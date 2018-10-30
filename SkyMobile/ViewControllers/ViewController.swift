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
    
    var UserName = "000000"
    var Password = "000000"
    let importantUtils = ImportantUtils()
    var didRun = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        importantUtils.CreateLoadingView(view: self.view)
        webView.navigationDelegate = self
        let url = URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!
        let request = URLRequest(url: url)
        webView.frame = CGRect(x: 0, y: 500, width: 0, height: 0)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
        
        webView.load(request)
        view.addSubview(webView)
        
        webView.allowsBackForwardNavigationGestures = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func readyToSwitchViews(withWebView tempView: WKWebView = WKWebView()) {
        if(!checkURL(url: webView.url!)){
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
            let values: [String: String] = [UserName: Password]
            UserDefaults.standard.set(values, forKey: "Userstore")
            //switchScreen(withWebView: tempView)
        }
    }
    
    
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
                webViewtemp.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                self.view.addSubview(webViewtemp)
                didRun = true
                return webViewtemp
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !didRun{
            if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w" || self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w"{
                if importantUtils.isKeyPresentInUserDefaults(key: "Userstore"){
                    SubmitBtn.isEnabled = false
                    let userstandard = UserDefaults.standard
                    let Values: [String: String] = userstandard.object(forKey: "Userstore") as! [String : String]
                    if Values.count >= 1{
                        UserName = Values.first?.key ?? "000000"
                        Password = Values.first?.value ?? "000000"
                        importantUtils.resetDefaults()
                        print(UserName + " " + Password)
                        AttemptLogin()
                    }
                }else{
                    importantUtils.DestroyLoadingView(view: self.view)
                }
            }
        }
        print("Loaded")
    }
    
    @objc func ShowError() {
        let alertController = UIAlertController(title: "Uh-Oh",
                                                message: "Invalid Credentials or internet failure.",
                                                preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(
        title: "OK", style: UIAlertAction.Style.destructive) { (action) in
            self.importantUtils.DestroyLoadingView(view: self.view)
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
        self.changeColorOfButton(color: .black)
        self.enableButton(bool: true)
    }
    
    @IBAction func SubmitForm(_ sender: Any) {
        enableButton(bool: false)
        changeColorOfButton(color: .gray)
        importantUtils.CreateLoadingView(view: self.view)
        UserName = UsernameField.text ?? "000000"
        Password = PasswordField.text ?? "000000"
        AttemptLogin()
    }
    
    func AttemptLogin() {
        let javascript = "login.value = \"\(UserName)\"; password.value = \"\(Password)\"; bLogin.click();"
        webView.evaluateJavaScript(javascript) { (result, error) in
            if error == nil {
            }
        }
        
        let javascrip1t = """
                        if(dMessage.attributes["style"].textContent.includes("visibility: visible"))
                        {
                        msgBtn1.click()
                        }
                        """
        for _ in 1...20{
            delay(1.0){
                self.webView.evaluateJavaScript(javascrip1t) { (result, error) in
                    if error == nil {
                    }
                }
            }
        }
        perform(#selector(ShowError), with: nil, afterDelay: 25)
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func tryToGetHTML(webView: WKWebView, completion: @escaping (_ titleString: String?) -> Void){
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString();", completionHandler: { (outerHTML, error ) in
            if error == nil{
                completion(outerHTML as? String)
            }else{
                completion("Error in JavaScript")
            }
        })
    }
    
    func tryToClickMsgBtn1(webView: WKWebView, completion: @escaping (_ titleString: String?) -> Void){
        let javascrip1t = """
                        if(dMessage.attributes["style"].textContent.includes("visibility: visible"))
                        {
                        msgBtn1.click()
                        }
                        """
        webView.evaluateJavaScript(javascrip1t, completionHandler: { (outerHTML, error ) in
            if error == nil{
                completion(outerHTML as? String)
            }else{
                completion("Error in JavaScript")
            }
        })
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
    func getHTMLCode(){
        // while(webView.url?.absoluteString != "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w"){ _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in}}
        view.addSubview(webView)
        let javascript =
            "var outerHTML = document.documentElement.outerHTML.toString()\n" +
        "outerHTML\n"
        self.webView.evaluateJavaScript(javascript) { (result, error) in
            if error == nil {
                let returnedResults = result as! String
                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
                vc.Courses = self.importantUtils.parseHTMLToGetGrades(htmlCodeToParse: returnedResults)
                vc.webView = self.webView
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    var runOnce = false
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webViewtemp.url!)
            
        }

        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // When page load finishes. Should work on each page reload.
            if (self.webViewtemp.estimatedProgress == 1) {
                print("### EP:", self.webView.estimatedProgress)
                print("ACCESS")
//                if self.webViewtemp.url?.absoluteString != nil {
//                    print("TestURL: " + (self.webViewtemp.url?.absoluteString)!)
//                    self.readyToSwitchViews(withWebView: self.webViewtemp)
//                    self.runOnce = true
//                }
                if let web = webViewtemp.url {
                if checkURL(url: web) {
                    let javascript1 = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
                    self.webViewtemp.evaluateJavaScript(javascript1) { (result, error) in
                        if error == nil {
                            self.webView = self.webViewtemp
                            self.readyToSwitchViews()
                        }
                    }
                }
                }
                if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w" {
                    print("Attempt to login passed!")
                    getHTMLCode()
                }
        }
        }
}
}
