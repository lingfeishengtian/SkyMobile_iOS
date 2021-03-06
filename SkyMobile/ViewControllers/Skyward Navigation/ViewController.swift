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
import LocalAuthentication
import GoogleMobileAds
import Kanna

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var BetaInfoDisplayer: UILabel!
    @IBOutlet weak var OldSaveAccount: UITableView!
    @IBOutlet weak var ModernUsernameTextField: UITextField!
    @IBOutlet weak var ModernPasswordTextField: UITextField!
    @IBOutlet var ModernView: UIView!
    @IBOutlet weak var ModernLoginButton: UIButton!
    @IBOutlet weak var ModernTableView: UITableView!
    @IBOutlet weak var DistrictChooserBackview: UIView!
    @IBOutlet weak var CloseDistrictChooser: UIButton!
    @IBOutlet weak var StatePicker: UIPickerView!
    @IBOutlet weak var DistrictName: UITextField!
    @IBOutlet weak var LoginTitle: UINavigationItem!
    @IBOutlet weak var toolBarSettings: UIButton!
    @IBOutlet weak var toolbarDistrictSearcher: UIButton!
    @IBOutlet weak var toolbarTopConstraint: NSLayoutConstraint!
    
    var UserName = ""
    var Password = ""
    let importantUtils = ImportantUtils()
    var didRun = false
    var webView = WKWebView()
    var AccountsStored: [Account] = []
    var SavedAccountsTableView = UITableView()
    var AccountFromPreviousSession = Account(nick: "", user: "", pass: "")
    var ShouldLoginWhenFinishedLoadingSite = false
    let DistrictData = DistrictPickerView()
    let StateDelegate = StatePickerView()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    let stateObserver = LoginPortalSearcherObserver()
    
    static var LoginSession = false
    static var LoginDistrict = ImportantUtils.GetDistrictsFromStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        if appVersion?.hasPrefix("2") ?? false && !ImportantUtils.isKeyPresentInUserDefaults(key: "updatedToNewPreferenceLoader"){
            let CannotFindValidValue = UIAlertController(title: "Thanks for updating!", message: "SkyMobile has a redesigned settings menu which we call \"PreferenceLoader\". This increases the speed of loading settings and gives you a better experience! Unfortunately, all of your older preferences have been lost, you can go to SkyMobile settings and recustomize the settings.", preferredStyle: .alert)
            let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            CannotFindValidValue.addAction(OKOption)
            UIApplication.topViewController()?.show(CannotFindValidValue, sender: nil)
            UserDefaults.standard.set(true, forKey: "updatedToNewPreferenceLoader")
        }
        
        ViewController.LoginSession = false
        if PreferenceLoader.findPref(prefID: "modernUI"){
            self.view = ModernView
            SavedAccountsTableView = ModernTableView
        }else{
            SavedAccountsTableView = OldSaveAccount
        }
        
        if PreferenceLoader.findPref(prefID: "loginStorage"){
            ModernTableView.isHidden = false
        }else{
            ModernTableView.isHidden = true
        }
        
        var origImage = UIImage(named: "SettingsIcon");
        var tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        toolBarSettings.setImage(tintedImage, for: .normal)
        toolBarSettings.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        origImage = UIImage(named: "TabBar_Search_2x")
        tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        toolbarDistrictSearcher.setImage(tintedImage, for: .normal)
        toolbarDistrictSearcher.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        
        ModernUsernameTextField.borderStyle = .roundedRect
        ModernUsernameTextField.textColor = UIColor.white
        ModernPasswordTextField.borderStyle = .roundedRect
        ModernPasswordTextField.textColor = UIColor.white
        
        ModernLoginButton.layer.cornerRadius = 5.0
        ModernLoginButton.layer.borderWidth = 1.0
        ModernLoginButton.layer.borderColor = UIColor.black.cgColor
        SavedAccountsTableView.separatorColor = UIColor.clear
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        DistrictChooserBackview.layer.cornerRadius = 10.0
        view.addSubview(blurEffectView)
        blurEffectView.alpha = 0
        StatePicker.delegate = StateDelegate
        
        if PreferenceLoader.findPref(prefID: "useToolbar"){
            LoginTitle.rightBarButtonItems = []
        }else{
            toolbarTopConstraint.constant = 20
            toolBarSettings.isHidden = true
            toolbarDistrictSearcher.isHidden = true
        }
        
        if ImportantUtils.isConnectedToNetwork() {
            LoginTitle.title = ViewController.LoginDistrict.DistrictName
            DistrictSearcher.initStateSelections(observer: stateObserver, picker: StatePicker)
            webView.navigationDelegate = self
            webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            view.addSubview(webView)
            
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
            
        
            DistrictData.Parent = self
            SavedAccountsTableView.dataSource = self
            SavedAccountsTableView.delegate = self
        }
    }
    
    func isNew() -> Bool {
        if ImportantUtils.isKeyPresentInUserDefaults(key: "NeueUserV"){
            return false
        }else{
            UserDefaults.standard.set(false, forKey: "NeueUserV")
            return true
        }
    }
    
    @IBAction func SubmitDistrictSearchForm(_ sender: Any) {
        importantUtils.CreateLoadingView(view: self.view, message: "Searching...")
        let UserText = DistrictName.text?.lowercased()
        if (UserText!.count) >= 3 {
            //skyAcademy.window.document.querySelector("#loginResults")
            let javascript = """
            skyAcademy.window.document.querySelector("#txtSearch").value = "\(UserText ?? "")"
            skyAcademy.window.document.querySelector("#ddlStates").value = \(DistrictSearcher.stateSelections[StatePicker.selectedRow(inComponent: 0)].value)
            skyAcademy.window.document.querySelector("#btnSearch").click()
            skyAcademy.window.document.querySelector("#lblDistrict").textContent
            """
            var Attempts = 0
            Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0), repeats: true){ timer in
                LoginPortalSearcherObserver.webView.evaluateJavaScript(javascript){ (result, err) in
                    Attempts += 1
                    if Attempts >= 30{
                        self.importantUtils.DestroyLoadingView(views: self.view)
                        self.importantUtils.DisplayErrorMessage(message: "Internet error...")
                        timer.invalidate()
                    }
                    if err == nil{
                        if (result as! String).contains(UserText!){
                            self.EvaluateOptions()
                            timer.invalidate()
                        }
                    }else{
                        print(err!)
                    }
                }
            }
        }else{
            importantUtils.DisplayErrorMessage(message: "Text has to be at least 3 characters")
        }
    }
    
    func EvaluateOptions(){
        var DistrictArray: [District] = []
        LoginPortalSearcherObserver.webView.evaluateJavaScript("skyAcademy.window.document.querySelector(\"#loginResults > div.login-flex-container.rowCount\").innerHTML"){ (result, err) in
            if err == nil{
                let html = result as! String
                
                if let document = try? HTML(html: html, encoding: .utf8){
                    let TableElements = document.css("table")
                    var Current = ""
                    
                    for elem in TableElements{
                        if elem.css("tr").count > 1{
                            Current = elem.css("tbody > tr > td > div").first?.text ?? "Not a district"
                        }else{
                            if elem.text?.contains("Family Access LoginParents & StudentsGo") ?? false{
                                let link = elem.css("td > a").first?["href"]
                                var Support = GPACalculatorSupport.NoSupport
                                if Current == "FORT BEND ISD"{
                                    Support = GPACalculatorSupport.HundredPoint
                                }
                                let newDistrict = District(name: Current, URLLink: URL(string: link!)!, gpaSupportType: Support)
                                DistrictArray.append(newDistrict)
                            }
                        }
                    }
                }
                let ChooseDistrict = UIAlertController(title: "Choose your district!", message: "We found these districts from your search query, choose one!", preferredStyle: .alert)
                for district in DistrictArray{
                    let action = UIAlertAction(title: district.DistrictName, style: .default, handler: { action in
                        ViewController.LoginDistrict = district
                        self.reloadSkyward()
                        self.LoginTitle.title = district.DistrictName
                        ImportantUtils.SaveDistrictToStorage(district: district)
                    })
                    ChooseDistrict.addAction(action)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {alert in
                    self.importantUtils.DestroyLoadingView(views: self.view)
                })
                ChooseDistrict.addAction(cancel)
                self.present(ChooseDistrict, animated: true, completion: nil)
            }else{
                self.importantUtils.DestroyLoadingView(views: self.view)
                self.importantUtils.DisplayErrorMessage(message: "No districts were found! If your district contains a number, try searching by that number.")
            }
        }
    }
    
    func DeveloperOnlyInjectAccountsForTestingONLY(){
        var accounts = ImportantUtils.GetAccountValuesFromStorage()
        print("Developer only account inject preparing to inject 10 accounts for testing.")
        for i in 0...4{
            accounts.append(Account(nick: "MockAccount\(i)", user: "999999", pass: "999999"))
        }
        ImportantUtils.SaveAccountValuesToStorage(accounts: accounts)
    }
    
    func DeveloperOnlyAttemptToRemoveAllInjectedAccounts(){
        var accounts = ImportantUtils.GetAccountValuesFromStorage()
        print("Developer only account inject preparing to remove Mock Accounts.")
        
        for i in stride(from: accounts.count-1, to: 0, by: -1){
            if accounts[i].NickName.contains("MockAccount"){
                accounts.remove(at: i)
            }
        }
        
        ImportantUtils.SaveAccountValuesToStorage(accounts: accounts)
    }
    
    static func SetAccountsAs3DTouch(){
        var accounts: [Account] = ImportantUtils.GetAccountValuesFromStorage()
        
        var NumOfAccountsToSet = accounts.count
        if accounts.count > 4{
            NumOfAccountsToSet = 5
        }
        
        var ShortcutItems: [UIApplicationShortcutItem] = []
        for accountInd in 0..<NumOfAccountsToSet{
            let account = accounts[accountInd]
            let ShortcutItem = UIApplicationShortcutItem(type: account.NickName, localizedTitle: account.NickName, localizedSubtitle: "Login to \(account.NickName)'s account.", icon: UIApplicationShortcutIcon(type:.search), userInfo: nil)
            ShortcutItems.append(ShortcutItem)
        }
        UIApplication.shared.shortcutItems = ShortcutItems
    }
    
    @IBAction func DistrictMenuPopup(_ sender: Any) {
        if DistrictSearcher.stateSelectionsFinishedInit{
            if (self.blurEffectView.alpha == 0){
                self.blurEffectView.fadeIn()
                self.DistrictChooserBackview.fadeIn()
                self.CloseDistrictChooser.fadeIn()
            }else{
                self.blurEffectView.fadeOut()
                self.DistrictChooserBackview.fadeOut()
                self.CloseDistrictChooser.fadeOut()
            }
            view.bringSubviewToFront(DistrictChooserBackview)
            view.bringSubviewToFront(CloseDistrictChooser)
        }else{
            importantUtils.DisplayErrorMessage(message: "Sorry, we are still loading the district searcher!")
        }
    }
    
    func CreateOrDestroyBlur(){
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
    
    func reloadSkyward(){
        let url = ViewController.LoginDistrict.DistrictLink
        let request = URLRequest(url: url)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        webView.load(request)
        InformationHolder.SkywardWebsite.load(request)
    }
    
    func BiometricAuthentication(){
        if PreferenceLoader.findPref(prefID: "loginAuth"){
            let BiometricAuthenticationContext = LAContext()
            let BiometricAuthenticationPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
            
            var ErrorsThatOccur: NSError?
            
            if BiometricAuthenticationContext.canEvaluatePolicy(BiometricAuthenticationPolicy, error: &ErrorsThatOccur){
                BiometricAuthenticationContext.evaluatePolicy(BiometricAuthenticationPolicy, localizedReason: "Authentication required to login.") { (Status, Errors) in
                    
                    DispatchQueue.main.async(execute: {
                        if let _ = Errors{
                            self.importantUtils.DisplayErrorMessage(message: "Verification failed, try again.")
                        }else{
                            if Status{
                                self.AttemptFinalInitBeforeLogin()
                            }else{
                                self.importantUtils.DisplayErrorMessage(message: "Verification failed, try again.")
                            }
                        }
                    })
                }
            }else{
                importantUtils.DestroyLoadingView(views: self.view)
                importantUtils.DisplayErrorMessage(message: "Biometrics haven't been set in settings. SkyMobile will now automatically disable biometrics.")
                InformationHolder.GlobalPreferences[PreferenceLoader.findPrefIndex(prefID: "loginAuth")].defaultBool = false
                PreferenceLoader.writePreferencesToPrefs(arr: InformationHolder.GlobalPreferences)
                let url = ViewController.LoginDistrict.DistrictLink
                let request = URLRequest(url: url)
                self.webView.load(request)
                runOnce = false
            }
        }else{
            AttemptFinalInitBeforeLogin()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ImportantUtils.isConnectedToNetwork(){
            importantUtils.CreateLoadingView(view: self.view, message: "Loading...")
            reloadSkyward()
            self.view.addSubview(LoginPortalSearcherObserver.webView)
            
            DispatchQueue.main.async {
                _ = try? LatestVersionChecker.isUpdateAvailable { (update, error) in
                    if let error = error {
                        print(error)
                    } else if let update = update {
                        let info = Bundle.main.infoDictionary
                        let currentVersion = info?["CFBundleShortVersionString"] as? String
                        if update != currentVersion{
                            if !ImportantUtils.isKeyPresentInUserDefaults(key: "NotifyAboutVersion\(update)") || PreferenceLoader.findPref(prefID: "showUpdate"){
                                let alerttingLogout = UIAlertController(title: "Update Available!", message: "There's an update available, go to the app store to download it!", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                                alerttingLogout.addAction(action)
                                self.present(alerttingLogout, animated: true, completion: nil)
                                
                                UserDefaults.standard.set(true, forKey: "NotifyAboutVersion\(update)")
                            }
                        }
                    }
                }
            }
            if ImportantUtils.isKeyPresentInUserDefaults(key: "ShowNewAppNotif"){
                if let data = UserDefaults.standard.string(forKey: "ShowNewAppNotif"){
                    if data != "NOMOREPLZ" {
                        showDownDiag()
                    }
                }
            }else{
                showDownDiag()
            }
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false){ timer in
                print("Idle for too long, assuming infinite looped. Exiting all loops")
                if self.importantUtils.GetLoadingViewText(views: self.view) == "Loading Skyward..."{
                    self.importantUtils.DestroyLoadingView(views: self.view)
                }
            }
            
            print("Timer asynchronaly loading")
        }else{
            self.importantUtils.DestroyLoadingView(views: self.view)
            let alerttingLogout = UIAlertController(title: "Oh No!", message: "SkyMobile needs internet to run, it currently doesn't cache user grades, so this app will be unavailable until you connect to internet. Thanks!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.goBackToLauncher(self)
            })
            alerttingLogout.addAction(okAction)
            self.present(alerttingLogout, animated: true, completion: nil)
        }
    }
    
    func showDownDiag(){
        UserDefaults.standard.set("PLZ UPDATE", forKey: "ShowNewAppNotif")
        let alertController = UIAlertController(title: "Hey There!",
                                                                       message: "There's a new SkyMobile out called SkyMobile gradebook on the app store. It's completely redesigned and fixes many bugs. SkyMobile Grade Viewer will no longer be updated.",
                                                                       preferredStyle: UIAlertController.Style.alert)
                               let confirmAction = UIAlertAction(
                               title: "OK", style: UIAlertAction.Style.destructive) { (action) in
                                  let url = URL(string: "https://apps.apple.com/app/id1477786177")
                                UIApplication.shared.openURL(url!)
                               }
                               let dontshowagain = UIAlertAction(
                               title: "Don't show me again", style: UIAlertAction.Style.destructive) { (action) in
                               UserDefaults.standard.set("NOMOREPLZ", forKey: "ShowNewAppNotif")
                               }
                               alertController.addAction(dontshowagain)
                               alertController.addAction(confirmAction)
                               self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        if !PreferenceLoader.findPref(prefID: "modernUI"){
            UsernameField.underlined()
            PasswordField.underlined()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: configuration)
        self.view.addSubview(self.webView)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        return self.webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.webView.url?.absoluteString == ViewController.LoginDistrict.DistrictLink.absoluteString{
            importantUtils.DestroyLoadingView(views: self.view)
            if !didRun{
                if !PreferenceLoader.findPref(prefID: "loginStorage"){
                    if ImportantUtils.isKeyPresentInUserDefaults(key: "JedepomachdiniaopindieniLemachesie"){
                        if let data = UserDefaults.standard.data(forKey: "JedepomachdiniaopindieniLemachesie"){
                            AccountFromPreviousSession = NSKeyedUnarchiver.unarchiveObject(with: data) as! Account
                            UserName = AccountFromPreviousSession.Username
                            Password = AccountFromPreviousSession.Password
                            didRun = true
                            AttemptLogin()
                        }
                    }
                }else if ShouldLoginWhenFinishedLoadingSite{
                    ShouldLoginWhenFinishedLoadingSite = false
                    AttemptLogin()
                    didRun = true
                }
            }
        }
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
        if !PreferenceLoader.findPref(prefID: "modernUI"){
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
        importantUtils.DestroyLoadingView(views: self.view)
        importantUtils.CreateLoadingView(view: self.view, message: "Logging in...")
        let javascript = "login.value = \"\(UserName)\"; password.value = \"\(Password)\"; bLogin.click();"
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
        
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
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(javascrip1t) { (result, error) in
                    if error != nil{
                        if PreferenceLoader.findPref(prefID: "loginStorage"){
                            self.importantUtils.DestroyLoadingView(views: self.view)
                            let Invalid = UIAlertController(title: "Uh-Oh", message: "A network error occurred. The network probably changed.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            Invalid.addAction(ok)
                            self.present(Invalid, animated: true, completion: nil)
                            self.enableButton(bool: true)
                            self.changeColorOfButton(color: UIColor.red)
                            finished = true
                            let url = ViewController.LoginDistrict.DistrictLink
                            let request = URLRequest(url: url)
                            self.webView.load(request)
                            timer.invalidate()
                        }
                    }else{
                        if let out = result as? String{
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
            }
        }
        //perform(#selector(ShowError), with: nil, afterDelay: 40)
    }
    
    func changeColorOfButton(color: UIColor){
        if !PreferenceLoader.findPref(prefID: "modernUI"){
            SubmitBtn.setTitleColor(color, for: .normal)
        }else{
            ModernLoginButton.setTitleColor(color, for: .normal)
            if color == UIColor.red{
                ModernLoginButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    func enableButton(bool: Bool){
        if !PreferenceLoader.findPref(prefID: "modernUI"){
            SubmitBtn.isEnabled = bool
        }else{
            ModernLoginButton.isEnabled = bool
        }
    }
    var AccountSelectedFromParentalAccount = ""
    var Expecting = false
    
    func checkForMultipleStudentGradeGrids(){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(#"document.querySelectorAll("div[id^=\"grid_stuGradesGrid\"]").length"#) { (result, error) in
                if error == nil{
                    let intResult = result as! Int
                    if intResult > 1{
                        self.webView.evaluateJavaScript(#"""
                            finText = ""
                            gradeList = document.querySelectorAll("div[id^=\"grid_stuGradesGrid\"]")
                            for (var ind = 0; ind < gradeList.length; ind++){
                            finText += gradeList[ind].querySelector("div.sfTag").textContent.split("    ")[0]
                            if (ind != gradeList.length-1){ finText += "\n"}
                            }
                            finText
                        """#) { (result, error) in
                            if error == nil{
                                let resultString = result as! String
                                let splitString = resultString.components(separatedBy: "\n")
                                let alertForMultipleGradesDetected = UIAlertController(title: "More than one school!", message: "You're taking school at multiple places! Select the grades you want to see...", preferredStyle: .alert)
                                for res in splitString{
                                    let action = UIAlertAction(title: res, style: .default, handler: { alert in
                                        InformationHolder.indexOfStudentGrid = splitString.firstIndex(of: res) ?? 0
                                        self.getHTMLCode()
                                    })
                                    alertForMultipleGradesDetected.addAction(action)
                                }
                                UIApplication.topViewController()?.present(alertForMultipleGradesDetected, animated: true, completion: nil)
                            }
                        }
                    }else{
                        self.getHTMLCode()
                    }
                }else{
                    self.getHTMLCode()
                }
            }
        }
    }
    
    func useFakeAccount(accountName: String, courses: [Course], name: String){
        InformationHolder.Courses = courses
        InformationHolder.AvailableTerms = [name]
        if PreferenceLoader.findPref(prefID: "modernUI"){
            let mainStoryBoard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
            UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
            UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func getHTMLCode(){
        let javascript =
        #"""
            function PrintTerms(){
             var FinalString = ""
             if (typeof sf_StudentList !== "undefined"){
            FinalString = FinalString + sf_StudentList.innerHTML
             }else{
             FinalString = FinalString + "@SWIFT_VALUE_DOES_NOT_EXIST"
             }
            FinalString = FinalString + "\n\n\n@SWIFT_DETERMINE_IF_STUDENT_LIST_EXIST\n\n\n"
                if (document.querySelectorAll("div[id^=\"grid_stuGradesGrid\"]")[\#(InformationHolder.indexOfStudentGrid)] != null){
            let gridList = document.querySelectorAll("div[id^=\"grid_stuGradesGrid\"]")[\#(InformationHolder.indexOfStudentGrid)]
            FinalString = FinalString + gridList.innerHTML + "@SWIFT_HTML&TERMS_SEPARATION@"
            let elems = gridList.querySelector("table[id*=\"grid_stuGradesGrid\"]").querySelectorAll("th")
            for(var i = 0; i < elems.length; i++){
                FinalString = FinalString + elems[i].textContent + "@SWIFT_TERM_SEPARATOR@"
            }
            }
            return FinalString
            }
            PrintTerms()
            """#
        ViewController.SetAccountsAs3DTouch()
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(javascript) { (result, error) in
                if error == nil {
                    let split = (result as! String).components(separatedBy: "@SWIFT_DETERMINE_IF_STUDENT_LIST_EXIST")
                    let returnedResults = split.last!
                    let ListedStudentValues = split.first!
                    let SplitString = returnedResults.components(separatedBy: "@SWIFT_HTML&TERMS_SEPARATION@")
                    let html = SplitString.first!
                    let terms = SplitString.last!
                    var OptionsAllowed:[String] = []
                    
                    if ListedStudentValues.contains("@SWIFT_VALUE_DOES_NOT_EXIST"){
                        InformationHolder.isParentAccount = false
                    }
                    if(UIApplication.topViewController() is ProgressReportAverages){
                        self.Expecting = true
                    }
                    if !ListedStudentValues.contains("@SWIFT_VALUE_DOES_NOT_EXIST") && !self.Expecting{
                        InformationHolder.childrenAccounts = ImportantUtils.AttemptToParseHTMLAndGetAvailableAccounts(html: ListedStudentValues)
                        ImportantUtils.popupPreferredChildMenu(viewToPresentOn: UIApplication.topViewController()!, webview: self.webView)
                        InformationHolder.isParentAccount = true
                    }else{
                        self.AccountSelectedFromParentalAccount = ""
                        self.Expecting = false
                        InformationHolder.Courses = self.importantUtils.ParseHTMLAndRetrieveGrades(html: html, allTheTermsSeperatedByN: terms, GradesOptionsOut: &OptionsAllowed)
                        if InformationHolder.Courses.count == 0{
                            self.importantUtils.DestroyLoadingView(views: self.view)
                            self.importantUtils.DisplayErrorMessage(message: "No classes were found.")
                        }else{
                            InformationHolder.SkywardWebsite = self.webView
                            InformationHolder.CoursesBackup = InformationHolder.Courses
                            self.AccountFromPreviousSession = Account(nick: "", user: self.UserName, pass: self.Password)
                            let encoded = NSKeyedArchiver.archivedData(withRootObject: self.AccountFromPreviousSession)
                            UserDefaults.standard.set(encoded, forKey: "JedepomachdiniaopindieniLemachesie")
                            if PreferenceLoader.findPref(prefID: "modernUI"){
                                let mainStoryBoard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
                                InformationHolder.AvailableTerms = OptionsAllowed
                                UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                            }else{
                                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                                let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
                                InformationHolder.AvailableTerms = OptionsAllowed
                                UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }else{
                    self.importantUtils.DestroyLoadingView(views: self.view)
                    let ErrorWhilstLoadingHTML = UIAlertController(title: "Uh-Oh",
                                                                   message: "An error has occured and your grades couldn't be loaded into memory, please report to developer. error " + error.debugDescription,
                                                                   preferredStyle: .alert)
                    
                    UIApplication.topViewController()?.present(ErrorWhilstLoadingHTML, animated: true, completion: nil)
                }
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
                    ImportantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
                    self.SavedAccountsTableView.reloadData()
                }
            })
            GetTextInput.addAction(CancelAction)
            GetTextInput.addAction(OKAction)
            self.present(GetTextInput, animated: true, completion: nil)
        }
    }
    
    @IBAction func SettingsViewTouched(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : PreferenceController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! PreferenceController
        vc.isFromLockScreen = true
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete"){ (row, index) in
            let Areyousure = UIAlertController(title: "Wait a minute!", message: "You're trying to delete this account from your saved accounts list. Are you sure?", preferredStyle: .alert)
            let YesAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                self.AccountsStored.remove(at: index.row/2)
                ImportantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
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
        
        if indexPath.row % 2 == 0{
            return [deleteAction, editAction]
        }else{
            return []
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AccountsStored.count == 0{
            tableView.isHidden = true
        }else{
            return AccountsStored.count * 2
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
            ViewController.SetAccountsAs3DTouch()
            if !PreferenceLoader.findPref(prefID: "modernUI"){
                text.textColor = UIColor.black
                cell.backgroundColor = UIColor.clear
            }
        }else{
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            self.importantUtils.CreateLoadingView(view: self.view, message: "Reloading SkyMobile")
            let AccountSelected = AccountsStored[indexPath.row/2]
            self.UserName = AccountSelected.Username
            self.Password = AccountSelected.Password
            self.runOnce = false
            ViewController.LoginDistrict = AccountSelected.district
            
            var fakeCourses: [Course] = [
                Course(period: "1", classDesc: "Sexiness", teacher: "DAVID"),
                Course(period: "2", classDesc: "Smartness", teacher: "DAVID"),
                Course(period: "3", classDesc: "Hotness", teacher: "DAVID"),
                Course(period: "4", classDesc: "Cuteness", teacher: "DAVID"),
                Course(period: "5", classDesc: "Funnyness", teacher: "DAVID"),
                Course(period: "6", classDesc: "Charmingness", teacher: "DAVID")
            ]
            
            var name = ""
            switch AccountSelected.NickName{
            case "SDD":
                name = "David"
            case "TTHAN":
                name = "爸爸"
            case "LimeiHuang":
                name = "妈妈"
            case "ALMASTERDADDY":
                name = "ALBON"
            default:
                break
            }
            
            let fakeTerms = [name : "99999"]
            
            for ind in 0...fakeCourses.count-1{
                fakeCourses[ind].termGrades = fakeTerms
            }
            
            if PreferenceLoader.findPref(prefID: "easterEggs"){
                if AccountSelected.NickName == "TTHAN"{
                    fakeCourses[0].Class = "帅"
                    fakeCourses[1].Class = "聪明"
                    fakeCourses[2].Class = "好心"
                    fakeCourses[3].Class = "爱心"
                    fakeCourses[4].Class = "文明行为"
                    fakeCourses.remove(at: 5)
                    useFakeAccount(accountName: AccountSelected.NickName, courses: fakeCourses, name: name)
                }else if AccountSelected.NickName == "LimeiHuang"{
                    fakeCourses[0].Class = "美"
                    fakeCourses[1].Class = "聪明"
                    fakeCourses[2].Class = "好心"
                    fakeCourses[3].Class = "爱心"
                    fakeCourses[4].Class = "文明行为"
                    fakeCourses[5].Class = "强壮"
                    useFakeAccount(accountName: AccountSelected.NickName, courses: fakeCourses, name: name)
                }else if AccountSelected.NickName == "SDD"{
                    useFakeAccount(accountName: AccountSelected.NickName, courses: fakeCourses, name: name)
                }else if AccountSelected.NickName == "ALMASTERDADDY"{
                    fakeCourses.append(Course(period: "7", classDesc: "Unbelievably Hot", teacher: "ALMASTER"))
                    fakeCourses[6].termGrades = [name : "Infinite"]
                    useFakeAccount(accountName: AccountSelected.NickName, courses: fakeCourses, name: name)
                }else{
                    self.ShouldLoginWhenFinishedLoadingSite = true
                    self.reloadSkyward()
                }
            }else{
                self.ShouldLoginWhenFinishedLoadingSite = true
                self.reloadSkyward()
            }
        }else{
            return
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return UITableViewCell.EditingStyle.none
    }
    var runOnce = false
    
    fileprivate func AttemptFinalInitBeforeLogin() {
        importantUtils.DestroyLoadingView(views: self.view)
        importantUtils.CreateLoadingView(view: self.view, message: "Getting your grades...")
        
        if PreferenceLoader.findPref(prefID: "loginStorage"){
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
                    tmpAccount.district = ViewController.LoginDistrict
                    self.AccountsStored.append(tmpAccount)
                    ImportantUtils.SaveAccountValuesToStorage(accounts: self.AccountsStored)
                    self.checkForMultipleStudentGradeGrids()
                }
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel){ alert in
                    self.checkForMultipleStudentGradeGrids()
                }
                alertUserSavePassword.addAction(OKAction)
                alertUserSavePassword.addAction(Cancel)
                self.present(alertUserSavePassword, animated: true, completion: nil)
            }else{
                checkForMultipleStudentGradeGrids()
            }
        }else{
            checkForMultipleStudentGradeGrids()
        }
    }
    
    @IBAction func goBackToLauncher(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Launcher", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Launcher") as! LaunchingScreen
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(vc, animated: false, completion: nil)
    }
    
    /*
     
     Important note to take note of.
     
     iOS 11 WebView observe value sometimes cannot unwrap webview values
     
     */
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webView.url!)
        }
        
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // When page load finishes. Should work on each page reload.
            if (self.webView.estimatedProgress == 1) {
                print("### EP:", self.webView.estimatedProgress, " URL: ", self.webView.url?.absoluteString ?? "No URL?")
                
                if self.webView.url?.absoluteString.contains(ViewController.LoginDistrict.DistrictLink.absoluteString) ?? false && self.ShouldLoginWhenFinishedLoadingSite{
                    AttemptLogin()
                    self.ShouldLoginWhenFinishedLoadingSite = false
                }
                
                    if self.webView.url?.absoluteString.contains("sfhome01.w") ?? false && !self.runOnce{
                        let javascript1 = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
                        DispatchQueue.main.async {
                        self.webView.evaluateJavaScript(javascript1){ obj, err in
                            if err == nil{
                                self.importantUtils.DestroyLoadingView(views: self.view)
                                self.importantUtils.CreateLoadingView(view: self.view, message: "Loading Gradebook")
                                self.runOnce = true
                            }else{
                                self.importantUtils.DestroyLoadingView(views: self.view)
                                self.importantUtils.DisplayErrorMessage(message: "Your grading period has ended.")
                            }
                        }
                    }
                }
                if self.webView.url?.absoluteString.contains("sfgradebook001.w") ?? false{
                    if (UIApplication.topViewController() is ViewController){
                        if self.AccountSelectedFromParentalAccount == ""{
                            BiometricAuthentication()
                        }else{
                            checkForMultipleStudentGradeGrids()
                        }
                    }else{
                        checkForMultipleStudentGradeGrids()
                    }
                }
                if InformationHolder.SkywardWebsite.url?.absoluteString.contains("qloggedout001.w") ?? false && !(UIApplication.topViewController() is ViewController) {
                    let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
                    let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    
                    let alerttingLogout = UIAlertController(title: "Oh No!", message: "Looks like you have been automatically logged out!", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                    })
                    alerttingLogout.addAction(OK)
                    UIApplication.topViewController()!.present(alerttingLogout, animated: true, completion: nil)
                }
                if InformationHolder.SkywardWebsite.url?.absoluteString.contains("sfacademichistory001.w") ?? false{
                    let CurrentTop = UIApplication.topViewController()
                    if CurrentTop is GPACalculatorViewController{
                        let GPACalc = CurrentTop as! GPACalculatorViewController
                        DispatchQueue.main.async {
                            InformationHolder.SkywardWebsite.evaluateJavaScript(LegacyGradeSweeperAPI.JavaScriptToScrapeGrades){(result, error) in
                                if(error == nil){
                                    GPACalc.RetrieveGradeInformation(grades: LegacyGradeSweeperAPI.ScrapeLegacyGrades(configuredString: result as! String))
                                }
                            }
                        }
                    }
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

extension UIView {
    
    func fadeIn(duration: TimeInterval = 0.5,
                delay: TimeInterval = 0.0,
                completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.5,
                 delay: TimeInterval = 0.0,
                 completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        self.alpha = 0.0
        }, completion: completion)
    }
}
