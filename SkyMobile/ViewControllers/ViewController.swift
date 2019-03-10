//
//  ViewController.swift
//  GradeChecker
//
//  Created by Hunter Han on 9/28/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SystemConfiguration

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var BetaInfoDisplayer: UILabel!
    @IBOutlet weak var SavedAccountsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var OldSaveAccount: UITableView!
    
    @IBOutlet weak var ModernUsernameTextField: UITextField!
    @IBOutlet weak var ModernPasswordTextField: UITextField!
    @IBOutlet var ModernView: UIView!
    @IBOutlet weak var ModernLoginButton: UIButton!
    @IBOutlet weak var ModernTableView: UITableView!
    
    var UserName = "000000"
    var Password = "000000"
    let importantUtils = ImportantUtils()
    var didRun = false
    var webView = WKWebView()
    var webViewtemp = WKWebView()
    var AccountsStored: [Account] = []
    var SavedAccountsTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        InformationHolder.GlobalPreferences = SettingsViewController.LoadPreferencesFromSavedLibrary()
        let Prefs = InformationHolder.GlobalPreferences
        if Prefs.ModernUI{
            self.view = ModernView
        }
        if InformationHolder.GlobalPreferences.ModernUI{
            SavedAccountsTableView = ModernTableView
        }else{
            SavedAccountsTableView = OldSaveAccount
        }
        ModernUsernameTextField.borderStyle = .roundedRect
        ModernUsernameTextField.textColor = UIColor.white
        ModernPasswordTextField.borderStyle = .roundedRect
        ModernPasswordTextField.textColor = UIColor.white
        
        ModernLoginButton.layer.cornerRadius = 5.0
        ModernLoginButton.layer.borderWidth = 1.0
        ModernLoginButton.layer.borderColor = UIColor.black.cgColor
        SavedAccountsTableView.separatorColor = UIColor.clear
        
        if isConnectedToNetwork() {
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
            
            if ImportantUtils.isKeyPresentInUserDefaults(key: "AccountStorageService"){
                if let data = UserDefaults.standard.data(forKey: "AccountStorageService"){
                    AccountsStored = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Account]
                }
            }else{
                let encoded = NSKeyedArchiver.archivedData(withRootObject: AccountsStored)
                UserDefaults.standard.set(encoded, forKey: "AccountStorageService")
            }
            
            SavedAccountsTableView.dataSource = self
            SavedAccountsTableView.delegate = self
//            let newContentSize = CGSize(width: self.view.frame.size.width, height: 50 * CGFloat(AccountsStored.count))
//            let defaultSize = self.view.frame.size.height/4.4
//            SavedAccountsTableView.frame.size = newContentSize
//            if newContentSize.height > defaultSize{
//                SavedAccountsTableViewHeight.constant = defaultSize
//            }else{
//                SavedAccountsTableViewHeight.constant = newContentSize.height
//            }
        }else{
            let alerttingLogout = UIAlertController(title: "Oh No!", message: "SkyMobile needs internet to run, it currently doesn't cache user grades, so this app will be unavailable until you connect to internet. Thanks!", preferredStyle: .alert)
            UIApplication.topViewController()!.present(alerttingLogout, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let isBeta = (appVersion?.lowercased().contains("beta"))! || (appVersion?.lowercased().contains("vb"))!
        
        if isBeta {
            let betaAlert = UIAlertController(title: "Hey there!", message: "We noticed you are on a beta version of SkyMobile, " + appVersion! + " to be exact. You are running iOS " + UIDevice.current.systemVersion + ". You will need these pieces of info to send to the developer if you detect any bugs. If there is a release that is out and you are a regular user, please switch to that version. (FYI: This message only appears on betas!)" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            betaAlert.addAction(okAction)
            self.present(betaAlert, animated: true, completion: nil)
            if !InformationHolder.GlobalPreferences.ModernUI{
            BetaInfoDisplayer.text?.append(appVersion! + " on iOS " + UIDevice.current.systemVersion + " using an " + UIDevice.current.modelName)
            }
        }else{
            if !InformationHolder.GlobalPreferences.ModernUI{
            BetaInfoDisplayer.isHidden = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !InformationHolder.GlobalPreferences.ModernUI{
            UsernameField.underlined()
            PasswordField.underlined()
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let tempURL = navigationAction.request.url
            var components = URLComponents()
            components.scheme = tempURL?.scheme
            components.host = tempURL?.host
            components.path = (tempURL?.path)!
                webViewtemp = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: configuration)
                webViewtemp.uiDelegate = self
                webViewtemp.navigationDelegate = self
                webViewtemp.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                self.view.addSubview(webViewtemp)
                didRun = true
                return webViewtemp
        }
        return nil
    }
    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        //importantUtils.DestroyLoadingView(views: self.view)
//        print("call")
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//
//        let alerttingLogout = UIAlertController(title: "Oh No!", message: "A network error occured! Please retry.", preferredStyle: .alert)
//        let OK = UIAlertAction(title: "Ok", style: .default, handler: { _ in
//            UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
//        })
//        alerttingLogout.addAction(OK)
//        InformationHolder.WebsiteStatus = WebsitePage.Login
//        UIApplication.topViewController()!.present(alerttingLogout, animated: true, completion: nil)
//    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !didRun{
//            if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w" || self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w"{
//                if importantUtils.isKeyPresentInUserDefaults(key: "Userstore"){
//                    SubmitBtn.isEnabled = false
//                    let userstandard = UserDefaults.standard
//                    let Values: [String: String] = userstandard.object(forKey: "Userstore") as! [String : String]
//                    if Values.count >= 1{
//                        UserName = Values.first?.key ?? "000000"
//                        Password = Values.first?.value ?? "000000"
//                        importantUtils.resetDefaults()
//                        print(UserName + " " + Password)
//                        AttemptLogin()
//                    }
//                }else{
                    importantUtils.DestroyLoadingView(views: self.view)
               }
//            }
//        }
//        print("Loaded")
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
        if !InformationHolder.GlobalPreferences.ModernUI{
            if let u = UsernameField.text, let p = PasswordField.text{
                if !u.isEmpty && !p.isEmpty{
                    UserName = u
                    Password = p
                }else{
                    importantUtils.DisplayErrorMessage(message: "One or more fields are empty!")
                    changeColorOfButton(color: UIColor.red)
                    enableButton(bool: true)
                    return
                }
            }else{
                importantUtils.DisplayErrorMessage(message: "Problem loading the text fields, the app is probably broken. Please contact the developer!")
                return
            }
        }else{
            if let u = ModernUsernameTextField.text, let p = ModernPasswordTextField.text{
                if !u.isEmpty && !p.isEmpty{
                    UserName = u
                    Password = p
                }else{
                    importantUtils.DisplayErrorMessage(message: "One or more fields are empty!")
                    changeColorOfButton(color: UIColor.red)
                    enableButton(bool: true)
                    return
                }
            }else{
                importantUtils.DisplayErrorMessage(message: "Problem loading the text fields, the app is probably broken. Please contact the developer!")
                return
            }
        }
        AttemptLogin()
    }
    
    func AttemptLogin() {
        importantUtils.CreateLoadingView(view: self.view, message: "Logging in...")
        let javascript = "login.value = \"\(UserName)\"; password.value = \"\(Password)\"; bLogin.click();"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
        
        let javascrip1t = """
                        function check(){
                        if(msgBodyCol.textContent == "Invalid login or password."){
                        msgBtn1.click()
                        return "fail"
                        } else if(dMessage.attributes["style"].textContent.includes("visibility: visible")) {
                        msgBtn1.click()
                        return "clicked"
                        }else if(document.querySelector(".ui-widget").textContent.includes("Please wait")){
                        return "Loading"
                        }
                        }
                        check()
                        """
        var finished = false;
        //while !finished{
        var times = 0
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){timer in
                if finished == true{
                    timer.invalidate()
                }
                if times >= 40 {
                    timer.invalidate()
                    self.importantUtils.DestroyLoadingView(views: self.view)
                    self.importantUtils.DisplayErrorMessage(message: "Failed to Login, please retry!")
                }
                times+=1
                print(times)
                self.webView.evaluateJavaScript(javascrip1t) { (result, error) in
                    if error != nil{
                        self.importantUtils.DestroyLoadingView(views: self.view)
                        let Invalid = UIAlertController(title: "Uh-Oh", message: "A network error occurred. The network probably changed.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        Invalid.addAction(ok)
                        self.present(Invalid, animated: true, completion: nil)
                        self.SubmitBtn.isEnabled = true
                        self.changeColorOfButton(color: UIColor.red)
                        finished = true
                        timer.invalidate()
                    }
                    if let out = result as? String{
                        print("LOOPING: OUTPUT: " + out)
                        if (out.contains("fail")){
                            self.importantUtils.DestroyLoadingView(views: self.view)
                            let Invalid = UIAlertController(title: "Uh-Oh", message: "Invalid login or password!", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            Invalid.addAction(ok)
                            self.present(Invalid, animated: true, completion: nil)
                            self.enableButton(bool: true)
                            self.changeColorOfButton(color: UIColor.red)
                            finished = true
                            timer.invalidate()
                        }
                        if (out).contains("clicked"){
                            finished = true
                            timer.invalidate()
                        }
                }
        
        }
    }
        //perform(#selector(ShowError), with: nil, afterDelay: 40)
    }
    
    func changeColorOfButton(color: UIColor){
        if !InformationHolder.GlobalPreferences.ModernUI{
            SubmitBtn.setTitleColor(color, for: .normal)
        }else{
            ModernLoginButton.setTitleColor(color, for: .normal)
            if color == UIColor.red{
                ModernLoginButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    func enableButton(bool: Bool){
        if !InformationHolder.GlobalPreferences.ModernUI{
            SubmitBtn.isEnabled = bool
        }else{
            ModernLoginButton.isEnabled = bool
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
                let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
                InformationHolder.Courses = self.importantUtils.ParseHTMLAndRetrieveGrades(html: returnedResults)
                InformationHolder.SkywardWebsite = self.webView
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
    
    @objc func EditAccountName(sender: AnyObject){
        if sender.reuseIdentifier != "ERRORCANNOTFIND"{
            let btn = sender as! UITableViewCell
            var index = 0
            let GetTextInput = UIAlertController(title: "Edit Display Name", message: "What would you like to display?", preferredStyle: .alert)
            GetTextInput.addTextField(configurationHandler: {(textField) -> Void in
                for view in (btn.subviews){
                    if view is UILabel{
                        textField.text = (view as! UILabel).text
                        index = view.tag
                    }
                }
            })
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let Input = GetTextInput.textFields![0].text{
                self.AccountsStored[index].NickName = Input
                    self.importantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
                    self.SavedAccountsTableView.reloadData()
                }
            })
            GetTextInput.addAction(CancelAction)
            GetTextInput.addAction(OKAction)
            self.present(GetTextInput, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete"){ (row, index) in
            let Areyousure = UIAlertController(title: "Wait a minute!", message: "You're trying to delete this account from your saved accounts list. Are you sure?", preferredStyle: .alert)
            let YesAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                self.AccountsStored.remove(at: index.row/2)
                self.importantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
                self.SavedAccountsTableView.reloadData()
            })
            let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            Areyousure.addAction(Cancel)
            Areyousure.addAction(YesAction)
            self.present(Areyousure, animated: true, completion: nil)
        }

        let editAction = UITableViewRowAction(style: .normal, title: "Edit"){(row, index) in
            self.EditAccountName(sender: self.SavedAccountsTableView.cellForRow(at: indexPath) ?? UITableViewCell(style: .default, reuseIdentifier: "ERRORCANNOTFIND"))
        }
        editAction.backgroundColor = UIColor(red: 46/255, green: 117/255, blue: 232/255, alpha: 1)
        
        return [deleteAction, editAction]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AccountsStored.count == 0{
            tableView.isHidden = true
        }else{
            return AccountsStored.count * 2 - 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0{
            return CGFloat(50)
        }else{
            return 5
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.SavedAccountsTableView.frame.width, height: 50))
        
        if indexPath.row % 2 == 0{
            cell.selectionStyle = .none
            let text = UILabel()
            text.text = AccountsStored[indexPath.row/2].NickName
            text.textColor = UIColor.white
            text.isHidden = false
            text.frame = CGRect(x: 10, y: 0, width: 300, height: 50)
            text.tag = indexPath.row/2
            cell.addSubview(text)
            cell.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
            cell.layer.cornerRadius = 5
        }else{
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            let AccountSelected = AccountsStored[indexPath.row/2]
            self.UserName = AccountSelected.Username
            self.Password = AccountSelected.Password
            self.AttemptLogin()
        }else{
            return
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
            return UITableViewCell.EditingStyle.none
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
                if webViewtemp.url!.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfhome01.w" && !runOnce{
                    let javascript1 = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
                    self.webViewtemp.evaluateJavaScript(javascript1){ obj, err in
                        if err == nil{
                            self.webView = self.webViewtemp
                            self.runOnce = true
                            InformationHolder.WebsiteStatus = WebsitePage.Home
                        }
                    }
                }
                if self.webView.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfgradebook001.w" {
                    importantUtils.DestroyLoadingView(views: self.view)
                    importantUtils.CreateLoadingView(view: self.view, message: "Getting your grades...")
                    InformationHolder.WebsiteStatus = WebsitePage.Gradebook
                    var isAccountPresentInStorage = false
                    for Account in AccountsStored{
                        if Account.Username == self.UserName{
                            isAccountPresentInStorage = true
                            break
                        }
                    }
                    if !isAccountPresentInStorage{
                    let alertUserSavePassword = UIAlertController(title: "Hey there!", message: "We've detected that you are a new user! Would you like to save your credentials?", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "Save", style: .default){ alert in
                        let tmpAccount = Account(nick: self.UserName, user: self.UserName, pass: self.Password)
                        self.AccountsStored.append(tmpAccount)
                        self.importantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
                        self.getHTMLCode()
                    }
                        let Cancel = UIAlertAction(title: "Cancel", style: .cancel){ alert in
                            self.getHTMLCode()
                        }
                    alertUserSavePassword.addAction(OKAction)
                    alertUserSavePassword.addAction(Cancel)
                        self.present(alertUserSavePassword, animated: true, completion: nil)
                    }else{
                    getHTMLCode()
                    }
                }
                if InformationHolder.SkywardWebsite.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/qloggedout001.w" && !(UIApplication.topViewController() is ViewController) {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    
                    let alerttingLogout = UIAlertController(title: "Oh No!", message: "Looks like you have been automatically logged out!", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                    })
                    alerttingLogout.addAction(OK)
                    InformationHolder.WebsiteStatus = WebsitePage.Login
                    UIApplication.topViewController()!.present(alerttingLogout, animated: true, completion: nil)
                }
                if InformationHolder.SkywardWebsite.url?.absoluteString == "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/sfacademichistory001.w"{
                    let CurrentTop = UIApplication.topViewController()
                    if CurrentTop is GPACalculatorViewController{
                        print("TESTGOING")
                        InformationHolder.WebsiteStatus = WebsitePage.AcademicHistory
                        let GPACalc = CurrentTop as! GPACalculatorViewController
                        InformationHolder.SkywardWebsite.evaluateJavaScript(LegacyGradeSweeperAPI.JavaScriptToScrapeGrades){(result, error) in
                            if(error == nil){
                                print("GOING")
                                GPACalc.RetrieveGradeInformation(grades: LegacyGradeSweeperAPI.ScrapeLegacyGrades(configuredString: result as! String))
                            }
                        }
                    }
                }
        }
        }
}
}

//class AccountListsTableView: UITableViewController {
//    var AccountList: [Account] = []
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return AccountList.count
//    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(50)
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: 50))
//
//        cell.selectionStyle = .none
//        let text = UILabel()
//        text.text = AccountList[indexPath.row].NickName
//        text.frame = CGRect(x: 0, y: 0, width: 400, height: 40)
//        cell.addSubview(text)
//        cell.backgroundColor = UIColor.clear
//        return cell
//    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let AccountSelected = AccountList[indexPath.row]
//        LoginScreen.UserName = AccountSelected.Username
//        LoginScreen.Password = AccountSelected.Password
//        LoginScreen.AttemptLogin()
//    }
//}

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

