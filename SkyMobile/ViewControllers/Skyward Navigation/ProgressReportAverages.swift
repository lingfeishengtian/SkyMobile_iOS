//
//  FinalGradeDisplay.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/6/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import GoogleMobileAds

class ProgressReportAverages: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate{
    
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var pickTerm: UIPickerView!
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var NavBarItems: UINavigationItem!
    @IBOutlet var MainGradientView: GradientView!
    @IBOutlet weak var moreMenuItemsStackView: UIStackView!
    @IBOutlet weak var AdBanner: GADBannerView!
    @IBOutlet weak var switchChild: UIButton!
    
    let importantUtils = ImportantUtils()
    var TableShouldSub = 0
    
    var indexOfOptions = 0;
    var isFirstRun = true
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        //TestInject()
        self.view.addSubview(InformationHolder.SkywardWebsite)
        
        ViewController.LoginSession = true
        AdBanner.adUnitID = "ca-app-pub-8149085154540848/1241734917"
        AdBanner.rootViewController = self
        AdBanner.delegate = self
        AdBanner.load(GADRequest())
        
        if !InformationHolder.isParentAccount{
            switchChild.isHidden = true
        }
        if PreferenceLoader.findPref(prefID: "modernUI"){
            MainGradientView.firstColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
            MainGradientView.secondColor = MainGradientView.firstColor
            MainGradientView.secondColor = MainGradientView.firstColor
            TableShouldSub = 10
        }
        InformationHolder.isElementary = IsElementaryAccount(Courses: InformationHolder.Courses)
        let ShouldBeDisplay = GuessShouldDisplayScreen(Courses: InformationHolder.Courses)
        indexOfOptions = InformationHolder.AvailableTerms.firstIndex(of: ShouldBeDisplay)!
        
        //InformationHolder.SkywardWebsite.frame = CGRect(x: 0, y: 0, width: 400, height: 200)
        table.frame.origin = CGPoint(x: pickTerm.frame.minX, y: pickTerm.frame.maxY)
        InformationHolder.SkywardWebsite.frame = CGRect(x: 0, y: 250, width: 0, height: 0)
        view.addSubview(InformationHolder.SkywardWebsite)
        
        table.reloadData()
        table.delegate = self
        table.dataSource = self
        table.bounces = false
        table.backgroundColor = .clear
        pickTerm.delegate = self
        pickTerm.dataSource = self

        if !PreferenceLoader.findPref(prefID: "modernUI"){
            let NewButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ShowMoreMenuItems(_:)))
            NavBarItems.setRightBarButton(NewButton, animated: true)
            LogoutButton.isHidden = true
            NavBarItems.setLeftBarButton(UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(Logout(_:))), animated: true)
        }
        
        LogoutButton.layer.cornerRadius = 5
        LogoutButton.layer.borderWidth = 1
        LogoutButton.layer.borderColor = UIColor.black.cgColor
        RefreshTable()
        pickTerm.selectRow(indexOfOptions, inComponent: 0, animated: true)
    }
    
    @IBAction func switchChild(_ sender: Any) {
        ImportantUtils.popupPreferredChildMenu(viewToPresentOn: self, webview: InformationHolder.SkywardWebsite)
        importantUtils.CreateLoadingView(view: self.view, message: "Switching accounts...")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        RefreshTable()
    }
    
    @IBAction func ResetToDefault(_ sender: Any) {
        InformationHolder.Courses = InformationHolder.CoursesBackup
        InformationHolder.isModified = false
        table.reloadData()
    }
    
    func TestInject(){
        for _ in 1...99{
            InformationHolder.Courses.append(Course(period: "1111", classDesc: "TEST", teacher: "MR TESTER"))
    }
    }
    
    func RefreshTable(){
        let TableContentHeight = table.contentSize.height
        let TableCalculatedHeight = self.view.frame.size.height - 50 - table.frame.minY - AdBanner.frame.height
        let WidthOfFrame = self.view.frame.width
        if TableContentHeight > TableCalculatedHeight{
            table.isScrollEnabled = true
            table.frame = CGRect(x: CGFloat(TableShouldSub/2), y: table.frame.minY, width: (WidthOfFrame) - CGFloat(TableShouldSub), height: TableCalculatedHeight)
            //TableViewHeightConstraint.constant = TableCalculatedHeight
        }else{
            table.isScrollEnabled = false
            table.frame = CGRect(x: CGFloat(TableShouldSub/2), y: table.frame.minY, width: (WidthOfFrame) - CGFloat(TableShouldSub), height: TableContentHeight)
            //TableViewHeightConstraint.constant = TableContentHeight
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return InformationHolder.AvailableTerms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if PreferenceLoader.findPref(prefID: "modernUI"){
            return NSAttributedString(string: InformationHolder.AvailableTerms[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        return NSAttributedString(string: InformationHolder.AvailableTerms[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            indexOfOptions = row
            table.reloadData()
            RefreshTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return InformationHolder.Courses.count * 2;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        //Find cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GradeTableViewCell
        
        if indexPath.row % 2 == 0{
            //Add cell text
            cell.lblPeriod.text = String(InformationHolder.Courses[indexPath.row/2].Period)
            cell.lblClassDesc.text = String(InformationHolder.Courses[indexPath.row/2].Class)
            //cell.lblGrade.frame.origin = CGPoint(x: self.view.frame.maxX-50, y: cell.lblGrade.frame.minY)
            for ClassDescConstraint in cell.lblClassDesc.constraints{
                if ClassDescConstraint.identifier == "ClassDescWidth"{
                    ClassDescConstraint.constant = cell.frame.size.width - (cell.lblGrade.frame.size.width + cell.lblPeriod.frame.size.width + 15)
                }
            }
            
            let grade = InformationHolder.Courses[indexPath.row/2].termGrades[InformationHolder.AvailableTerms[indexOfOptions]] ?? "-1000"
            if(grade == "-1000"){
                cell.lblGrade.text = " "
                cell.backgroundColor = UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0)
            }else{
                cell.lblGrade.text = (grade)
                if let gradeAsNum = Double(grade){
                    cell.backgroundColor = importantUtils.DetermineColor(from: gradeAsNum)
                }else{
                    cell.backgroundColor = UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0)
                }
            }
            
            //cell.lblClassDesc.sizeToFit()
            //Add cell color!!!!
            cell.alpha = CGFloat(0.7)
            cell.lblGrade.textAlignment = .right
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if InformationHolder.isModified{
                cell.backgroundColor = UIColor.black
                cell.lblPeriod.textColor = UIColor.white
                cell.lblGrade.textColor = UIColor.white
                cell.lblClassDesc.textColor = UIColor.white
            }else{
                cell.lblPeriod.textColor = UIColor.black
                cell.lblGrade.textColor = UIColor.black
                cell.lblClassDesc.textColor = UIColor.black
            }
            
            if PreferenceLoader.findPref(prefID: "modernUI"){
                cell.layer.cornerRadius = 5
            }
        }else{
            cell.isHidden = true
            cell.backgroundColor = .clear
        }
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0{
            return 44
        }else{
            if PreferenceLoader.findPref(prefID: "modernUI"){
                return 3
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if InformationHolder.isModified{
            self.importantUtils.DisplayErrorMessage(message: "You modified one class, please reset classes to default to access class.")
        }else{
            if Int(InformationHolder.Courses[indexPath.row/2].termGrades[InformationHolder.AvailableTerms[indexOfOptions]] ?? "NA") != nil{
                GetAssignments(indexOfCourse: indexPath.row/2, indexOfOptions: indexOfOptions)
            }else{
                importantUtils.DisplayErrorMessage(message: "You dont have any grades in this class this term!")
            }
        }
    }
    
    fileprivate func helperClickAssignmentValue(indexOfClass: Int, indexOfOptions: Int){
        let compiledJS = #"document.querySelectorAll("div[id^=\"grid_stuGradesGrid\"]")[\#(InformationHolder.indexOfStudentGrid)].querySelectorAll("tr.odd:not([group-child]),tr.even:not([group-child])")[\#(String(indexOfClass))].querySelector("a[data-lit=\"\#(InformationHolder.AvailableTerms[indexOfOptions])\"]").click();"#
        InformationHolder.SkywardWebsite.evaluateJavaScript(compiledJS, completionHandler: nil)
    }
    
    func GetAssignments(indexOfCourse indexOfClass: Int, indexOfOptions:Int){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
        vc.Class = InformationHolder.Courses[indexOfClass].Class
        vc.Term = InformationHolder.AvailableTerms[indexOfOptions]
        vc.index = indexOfClass
        InformationHolder.SkywardWebsite = InformationHolder.SkywardWebsite
        InformationHolder.Courses = InformationHolder.Courses
        vc.Grade = String(InformationHolder.Courses[indexOfClass].termGrades[InformationHolder.AvailableTerms[indexOfOptions]]!)
        
        helperClickAssignmentValue(indexOfClass: indexOfClass, indexOfOptions: indexOfOptions)
        let javaScript = """
                        function checkForCorrectClass(){
                        if(document.querySelector("table[id^=grid_stuGradeInfoGrid]").querySelector("a").text == "\(InformationHolder.Courses[indexOfClass].Class)" && sf_DialogTitle_gradeInfoDialog.textContent.indexOf("\(InformationHolder.AvailableTerms[indexOfOptions])") != -1){
                        return "Valid"
                        }
                        }
                        checkForCorrectClass()
                        """
        importantUtils.CreateLoadingView(view: self.view, message: "Trying to get grades...")
        var Attempts = 0
        var displayOnce = false
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true){ timer in
        DispatchQueue.main.async {
            InformationHolder.SkywardWebsite.evaluateJavaScript(javaScript){ (result, error) in
                Attempts += 1
                
                if Attempts % 4 == 0 { self.helperClickAssignmentValue(indexOfClass: indexOfClass, indexOfOptions: indexOfOptions) }
                if Attempts >= 20 && !displayOnce{
                    self.importantUtils.DestroyLoadingView(views: self.view)
                    let errorAlert = UIAlertController(title: "Uh Oh", message: "Your class grades couldn't be retrieved, maybe you dont have any grades in there?", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {_ in
                        displayOnce = true
                    })
                    errorAlert.addAction(ok)
                    self.present(errorAlert, animated: true, completion: nil)
                    timer.invalidate()
                }
                if let fin = result as? String{
                    if fin == "Valid" && UIApplication.topViewController() is ProgressReportAverages{
                        self.present(vc, animated: true, completion: nil)
                        timer.invalidate()
                    }
                }
            }
        }
        }
    }
    
    func IsElementaryAccount(Courses: [Course]) -> Bool{
        for course in InformationHolder.Courses{
            for (term, grade) in course.termGrades{
                if(grade != "-1000" && (term.contains("PR"))){
                    return false
                }
            }
        }
        return true
    }
    
    func GuessShouldDisplayScreen(Courses: [Course]) -> String{
        var CurrentGuess = InformationHolder.AvailableTerms.first ?? ""
        for term in InformationHolder.AvailableTerms{
            for course in InformationHolder.Courses{
                if Int(course.termGrades[term] ?? "NA") != nil && term != "S1" && term != "S2"{
                    CurrentGuess = term
                }
            }
        }
        print("GUESS: ",CurrentGuess, ". Is this correct?")
        return CurrentGuess
    }
    @IBAction func goToGPACalculator(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : GPACalculatorViewController = mainStoryboard.instantiateViewController(withIdentifier: "GPACalculator") as! GPACalculatorViewController
        vc.isElemAccount = self.IsElementaryAccount(Courses: InformationHolder.Courses)
        self.present(vc, animated: true, completion: nil)
    }
    
    //TODO: Add ScrollView for all pages
    //TODO: Create the settings
    @IBAction func goToSettings(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : PreferenceController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! PreferenceController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func Logout(_ sender: Any) {
        var Message = "Are you sure you want to logout?"
        if !PreferenceLoader.findPref(prefID: "loginStorage"){
            Message.append(" This will remove your last session.")
        }
        
        let alertController = UIAlertController(title: "Logout",
                                                message: Message,
                                                preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(
        title: "No", style: UIAlertAction.Style.cancel) { (action) in
            // ...
        }
        let confirmedAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive){ (action) in
            if !PreferenceLoader.findPref(prefID: "loginStorage"){
                UserDefaults.standard.removeObject(forKey: "JedepomachdiniaopindieniLemachesie")
            }
            let mainStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.didRun = false
            self.importantUtils.resetDefaults()
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(confirmedAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func ShowMoreMenuItems(_ sender: Any) {
        if PreferenceLoader.findPref(prefID: "modernUI"){
            goToSettings(sender)
        }else{
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.transitionCurlDown] ,animations: {
                for view in self.moreMenuItemsStackView.arrangedSubviews{
                    let btn = view as? UIButton
                    btn?.backgroundColor = .clear
                    if PreferenceLoader.findPref(prefID: "modernUI"){
                        btn?.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
                        btn?.setTitleColor(UIColor.white, for: .normal)
                    }
                    btn?.layer.cornerRadius = 5
                    btn?.layer.borderWidth = 1
                    btn?.layer.borderColor = UIColor.black.cgColor
                    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                      view.isHidden = !view.isHidden
                    })
                }
                self.moreMenuItemsStackView.layoutIfNeeded()
            })
        RefreshTable()
        }
    }
}

class GradeTableViewCell: UITableViewCell{
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblClassDesc: UILabel!
}
