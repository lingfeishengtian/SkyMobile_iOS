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
    
    @IBOutlet weak var BetaInfoDisplayer: UILabel!
    var UserName = "000000"
    var Password = "000000"
    let importantUtils = ImportantUtils()
    var didRun = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        importantUtils.CreateLoadingView(view: self.view, message: "Loading Skyward FBISD")
        webView.navigationDelegate = self
        let url = URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!
        let request = URLRequest(url: url)
        webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        //webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
        
        webView.load(request)
        view.addSubview(webView)
        
        webView.allowsBackForwardNavigationGestures = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        BetaInfoDisplayer.text?.append(appVersion! + " on " + UIDevice.current.systemVersion + " using an " + UIDevice.current.modelName)
    }
    
    override func viewDidLayoutSubviews() {
        UsernameField.underlined()
        PasswordField.underlined()
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
                webViewtemp = WKWebView(frame: CGRect(x: 0, y: 400, width: 0, height: 0), configuration: configuration)
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
                    importantUtils.DestroyLoadingView(views: self.view)
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
            self.importantUtils.DestroyLoadingView(views: self.view)
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
        self.changeColorOfButton(color: .black)
        self.enableButton(bool: true)
    }
    
    @IBAction func SubmitForm(_ sender: Any) {
        enableButton(bool: false)
        changeColorOfButton(color: .gray)
        importantUtils.CreateLoadingView(view: self.view, message: "Logging in...")
        UserName = UsernameField.text ?? "000000"
        Password = PasswordField.text ?? "000000"
        AttemptLogin()
    }
    
    func AttemptLogin() {
        let javascript = "login.value = \"\(UserName)\"; password.value = \"\(Password)\"; bLogin.click();"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
        
        let javascrip1t = """
                        if(dMessage.attributes["style"].textContent.includes("visibility: visible"))
                        {
                        msgBtn1.click()
                        console.log("clicked")
                        }else{
                        console.log("no BTN")
                        }
                        """
        var finished = false;
        //while !finished{
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){timer in
                if finished == true{
                    timer.invalidate()
                }
                self.webView.evaluateJavaScript(javascrip1t) { (result, error) in
//                    if error != nil{
//                        let alertController = UIAlertController(title: "Uh-Oh",
//                                                                message: "Skyward in maintenence.",
//                                                                preferredStyle: UIAlertController.Style.alert)
//                        self.present(alertController, animated: true, completion: nil)
//                    }
                    if let out = result as? String{
                        print("LOOPING: OUTPUT: " + out)
                        if (out) == "clicked"{
                            finished = true
                        }
                }
        
        }
    }
        //perform(#selector(ShowError), with: nil, afterDelay: 40)
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
        //view.addSubview(webView)
        let javascript =
            "document.querySelector(\"div[id^=\\\"grid_stuGradesGrid\\\"]\").innerHTML"
        self.webView.evaluateJavaScript(javascript) { (result, error) in
            if error == nil {
                let returnedResults = result as! String
                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
                vc.Courses = self.importantUtils.parseHTMLToGetGrades(htmlCodeToParse: returnedResults)
                vc.webView = self.webView
                self.present(vc, animated: true, completion: nil)
            }else{
                self.importantUtils.DestroyLoadingView(views: self.view)
                let ErrorWhilstLoadingHTML = UIAlertController(title: "Uh-Oh",
                                                               message: "An error has occured and your grades couldn't be loaded into memory, please report to developer. error " + error.debugDescription,
                                                               preferredStyle: .alert)
                
                self.present(ErrorWhilstLoadingHTML, animated: true, completion: nil)
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
                if checkURL(url: web)  && !runOnce{
                    let javascript1 = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
                        self.webViewtemp.evaluateJavaScript(javascript1){ obj, err in
                            if err == nil{
                                self.webView = self.webViewtemp
                                self.readyToSwitchViews()
                                self.runOnce = true
                            }
                        }
                    }
                }
                if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w" {
                    importantUtils.DestroyLoadingView(views: self.view)
                    importantUtils.CreateLoadingView(view: self.view, message: "Getting your grades...")
                    getHTMLCode()
                }
        }
        }
}
}

extension UITextField {
    
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
