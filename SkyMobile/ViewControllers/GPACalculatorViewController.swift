//
//  GPACalculatorViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/19/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import WebKit

class GPACalculatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var Courses = InformationHolder.Courses
    var LegacyGrades: [LegacyGrade] = []
    var importantUtils = ImportantUtils()
    var progress = 0
    //Status 0 is simple and 1 is advanced
    var Status = 0
    var isElemAccount = false
    
    @IBOutlet weak var S1Average: UILabel!
    @IBOutlet weak var S2Average: UILabel!
    @IBOutlet weak var FinalGPA: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var GPACalculatorTitle: UILabel!
    @IBOutlet weak var tableViewHighConstraint: NSLayoutConstraint!
    @IBOutlet weak var AdvancedEnabler: UIButton!
    @IBOutlet weak var ModifyIfCourseCounts: UIButton!
    @IBOutlet weak var ResetAllCourseLevels: UIButton!
    @IBOutlet weak var InstructionsButton: UIButton!
    @IBOutlet weak var S2IndicatorLbl: UILabel!
    @IBOutlet weak var S1IndicatorLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InformationHolder.SkywardWebsite.frame = CGRect(x: 0, y: 0, width:0, height: 0)
        self.view.addSubview(InformationHolder.SkywardWebsite)
        //tableView.frame.origin = CGPoint(x: 0, y: FinalGPA.frame.maxY + 10)
        //tableView.frame.size = CGSize(width: self.view.frame.width, height: 100)
        
        GPACalculatorTitle.sizeToFit()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        AdvancedEnabler.backgroundColor = UIColor.clear
        AdvancedEnabler.layer.cornerRadius = 5
        AdvancedEnabler.layer.borderWidth = 1
        AdvancedEnabler.layer.borderColor = UIColor.black.cgColor
        SetFinalAverageValues()
        if isElemAccount {
            AdvancedEnabler.isHidden = true
        }
    }
    
    func ScrollToBottom(){
        if Status == 0{
            tableView.scrollToRow(at: IndexPath(row: Courses.count-1, section: 0), at: .bottom, animated: false)
        }else{
            tableView.scrollToRow(at: IndexPath(row: LegacyGrades[LegacyGrades.count-1].Courses.count-1, section: LegacyGrades.count-1), at: .bottom, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(Status == 0){
            return 1
        }else{
            return LegacyGrades.count
        }
    }
    
    @objc func attemptToDeselectAllInSection(_ sender: Any){
        _ = (sender as! UIButton).superview
                let SectionNumber = (sender as! UIButton).tag
                for RowNum in 0...tableView.numberOfRows(inSection: SectionNumber)-1{
                    let row = LegacyGrades[SectionNumber].Courses[RowNum]
                    UserDefaults.standard.set("N/A", forKey: row.Class + "Level")
                }
        tableView.reloadData()
        SetFinalAverageValues()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(Status == 1){
            let NewGrade = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
            let GradeLabel = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: NewGrade.frame.maxY/2), size: CGSize(width: self.view.frame.size.width/4 * 3, height: NewGrade.frame.size.height)))
            let DeselectButton = UIButton(type: .roundedRect)
            GradeLabel.center = CGPoint(x: NewGrade.frame.maxX/2, y: NewGrade.frame.maxY/2)
            GradeLabel.text = LegacyGrades[section].Grade
            DeselectButton.frame = CGRect(x: Int(NewGrade.frame.maxX - 100), y: Int(GradeLabel.frame.minY), width: 100, height: 50)
            
            DeselectButton.addTarget(self, action: #selector(GPACalculatorViewController.attemptToDeselectAllInSection(_:)), for: .touchUpInside)
            GradeLabel.tag = 298
            DeselectButton.tag = section
            DeselectButton.center = CGPoint(x: NewGrade.frame.maxX - 50, y: NewGrade.frame.maxY/2)
            //DeselectButton.frame.origin = CGPoint(x: 90, y: 20)
            DeselectButton.backgroundColor = UIColor.white
            DeselectButton.setTitle("Deselect All", for: .normal)
            DeselectButton.isHidden = false
            NewGrade.addSubview(GradeLabel)
            NewGrade.addSubview(DeselectButton)
            NewGrade.backgroundColor = UIColor.white
            return NewGrade
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(Status == 1){
            return 60
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(Status == 0){
            return Courses.count
        }else{
            return LegacyGrades[section].Courses.count
        }
    }
    
    fileprivate func SetClassLevel(_ Class: String) {
        if !ImportantUtils.isKeyPresentInUserDefaults(key: Class+"Level"){
            UserDefaults.standard.set(importantUtils.GuessClassLevel(className: Class), forKey: Class + "Level")
        }
    }
    
    fileprivate func SetCourseCreditWorthLibrary(_ Class: String, credits: Double) {
            UserDefaults.standard.set(credits, forKey: Class + "CreditWorthStorageInGPA")
    }
    
    fileprivate func GetCourseCreditWorthFromLibrary(_ Class: String) -> (Double) {
        if let Retrieved =  UserDefaults.standard.object(forKey: Class + "CreditWorthStorageInGPA"){
            return Retrieved as! Double
        }else{
            SetCourseCreditWorthLibrary(Class, credits: 1.0)
            return 1.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CourseInfo
        var Class = ""
        var AmtOfCredits = 1.0
        if(Status == 0){
            let tmp = Courses[indexPath.row]
            Class = tmp.Class
            AmtOfCredits = tmp.CourseCreditWorth
        }else{
            let tmp = LegacyGrades[indexPath.section].Courses[indexPath.row]
            Class = tmp.Class
            AmtOfCredits = tmp.CourseCreditWorth
        }
        cell.CreditWorth.selectedSegmentIndex = GetIndexOfValue(valueToSelect: AmtOfCredits)
        cell.APInfo.frame = CGRect(x: self.view.frame.width-(8+50), y: cell.APInfo.frame.minY, width: 50, height: cell.APInfo.frame.height)
        cell.CreditWorth.frame = CGRect(x: self.view.frame.width
            - (cell.APInfo.frame.width + cell.CreditWorth.frame.width + 16), y: cell.CreditWorth.frame.minY, width: cell.CreditWorth.frame.width, height: cell.CreditWorth.frame.height)
        cell.Course.text = Class
        SetClassLevel(Class)
        cell.APInfo.text = UserDefaults.standard.object(forKey: Class+"Level") as? String
        cell.Course.frame.size = CGSize(width: self.view.frame.width - (cell.CreditWorth.frame.size.width + cell.APInfo.frame.size.width + 32), height: cell.Course.frame.size.height)
        cell.Section = indexPath.section
        cell.Row = indexPath.row
        cell.frame.size = CGSize(width: self.view.frame.width, height: 44)
        SetTableViewHeightConstraint()
        return cell
    }
    
    func GetIndexOfValue(valueToSelect val: Double) -> (Int){
        return Int(val * 2 - 1)
    }
    
    func SetTableViewHeightConstraint(){
        let TableContentSizeHeight = tableView.contentSize.height
        let CalculationOfTableHeight = self.view.frame.size.height - tableView.frame.minY
        if(TableContentSizeHeight > CalculationOfTableHeight){
            tableViewHighConstraint.constant = CalculationOfTableHeight
            tableView.frame.size = CGSize(width: tableView.frame.size.width, height: tableViewHighConstraint.constant)
            tableView.isScrollEnabled = true
        }else{
            tableViewHighConstraint.constant = TableContentSizeHeight
            tableView.frame.size = CGSize(width: tableView.frame.size.width, height: TableContentSizeHeight)
            tableView.isScrollEnabled = false
        }
    }
    
    func SetFinalAverageValues() {
        if(Status == 0){
            for Classe in 0...Courses.count-1{
            let Class = Courses[Classe].Class
            Courses[Classe].CourseCreditWorth = GetCourseCreditWorthFromLibrary(Class)
            }
        }else{
            for Classe in 0...LegacyGrades.count-1{
                for Classd in 0...LegacyGrades[Classe].Courses.count-1{
                    let Class = LegacyGrades[Classe].Courses[Classd].Class
                        LegacyGrades[Classe].Courses[Classd].CourseCreditWorth = GetCourseCreditWorthFromLibrary(Class)
                }
            }
        }
        var S1AverageInt = ""
        var S2AverageInt = ""
        if(Status == 0){
            S1AverageInt = String(Double(round(1000*reloadGPAValues(term: "S1"))/1000))
            S2AverageInt = String(Double(round(1000*reloadGPAValues(term: "S2"))/1000))
            S1Average.text = S1AverageInt
            S2Average.text = S2AverageInt
            if S1AverageInt == "nan"{
                S1Average.text = "Not Applicable"
            }else if S2AverageInt == "nan"{
                S2Average.text = "Not Applicable"
                FinalGPA.text = String(S1AverageInt)
            }
        }
        let FinalTermAverage = reloadGPAValues(term: "FIN")
        if(String(FinalTermAverage) != "nan"){
        FinalGPA.text = String(FinalTermAverage)
        }else if(S1AverageInt != "nan" && S2AverageInt != "nan" && Status == 0){
            FinalGPA.text = String((Double(S1AverageInt)! + Double(S2AverageInt)!)/2.0)
        }else{
            FinalGPA.text = "N/A"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var Class = ""

        if(Status == 0){
            Class = Courses[indexPath.row].Class
        }else{
            Class = LegacyGrades[indexPath.section].Courses[indexPath.row].Class
        }
        let CurrentLevel = UserDefaults.standard.object(forKey: Class+"Level") as? String
        var newLevel = " "
        
        switch CurrentLevel {
        case "Regular":
            newLevel = "PreAP"
        case "PreAP":
            newLevel = "AP"
        case "AP":
            newLevel = "N/A"
        default:
            newLevel = "Regular"
        }
        
        UserDefaults.standard.set(newLevel, forKey: Class + "Level")
        self.tableView.reloadData()
        SetFinalAverageValues()
    }
    
    fileprivate func CheckAddAmt(level: String?) -> Int{
        if let levelUnwrap = level{
            if levelUnwrap == "PreAP"{
                return 5
            }else if levelUnwrap == "AP"{
                return 10
            }else if levelUnwrap == "N/A"{
                return -1
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    fileprivate func CalculateNewClassAverageFromInformation(_ course: Course, _ NewClassAverage: inout Double, _ term: String, _ FinalCount: inout Double) {
        let className = course.Class
        let level = (UserDefaults.standard.object(forKey: className+"Level") as? String)
        let CreditWorth = course.CourseCreditWorth
        let LevelAddAmt = CheckAddAmt(level: level)
        if LevelAddAmt != -1{
            NewClassAverage += ((Double(course.Grades.Grades[term]!)!) + Double(LevelAddAmt)) * CreditWorth
        }else{
            FinalCount -= CreditWorth
        }
        FinalCount += CreditWorth
    }
    
    func reloadGPAValues(term: String) -> Double{
        var NewClassAverage: Double = 0
        var FinalCount: Double = 0
        if Status == 0{
        for course in Courses{
            if Int(course.Grades.Grades[term]!) != -1000{
                CalculateNewClassAverageFromInformation(course, &NewClassAverage, term, &FinalCount)
            }
        }
        }else{
            for grade in LegacyGrades{
                for Class in grade.Courses{
                    let CreditWorth = Class.CourseCreditWorth
                    let className = Class.Class
                    let level = (UserDefaults.standard.object(forKey: className+"Level") as? String)
                    if (Class.Grades.Grades["FIN"]) != "" && (Class.Grades.Grades["FIN"]) != "-1000"{
                        CalculateNewClassAverageFromInformation(Class, &NewClassAverage, "FIN", &FinalCount)
                    }else if Class.Grades.Grades["S1"] != "" && Class.Grades.Grades["S2"] != "" && Class.Grades.Grades["S1"] != "-1000" && Class.Grades.Grades["S2"] != "-1000"{
                        let LevelAddAmt = CheckAddAmt(level: level)
                        if LevelAddAmt != -1{
                            NewClassAverage += ((Double(Class.Grades.Grades["S1"]!)! + Double(Class.Grades.Grades["S2"]!)!)/2 + Double(LevelAddAmt)) * CreditWorth
                        }else{
                            FinalCount -= CreditWorth
                        }
                        FinalCount += CreditWorth
                    }else if Class.Grades.Grades["S2"] != "" && Class.Grades.Grades["S2"] != "-1000"{
                        CalculateNewClassAverageFromInformation(Class, &NewClassAverage, "S2", &FinalCount)
                    }else if Class.Grades.Grades["S1"] != "" && Class.Grades.Grades["S1"] != "-1000"{
                        CalculateNewClassAverageFromInformation(Class, &NewClassAverage, "S1", &FinalCount)
                    }
                }
            }
        }
        return Double(NewClassAverage)/Double(FinalCount)
    }
    
    @IBAction func SwitchToAdvancedOrSimple(_ sender: Any) {
        if(Status == 1){ Status = 0; }else{ Status = 1 }
        if(Status == 1){
            importantUtils.CreateLoadingView(view: self.view, message: "Getting your grades...")
            AdvancedEnabler.setTitle("Simple", for: .normal)
            let JS = "document.querySelector('a[data-nav=\"sfacademichistory001.w\"]').click()"
            InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
        }else{
            AdvancedEnabler.setTitle("Advanced", for: .normal)
            SetFinalAverageValues()
            tableView.reloadData()
        }
        //ModifyIfCourseCounts.isHidden = !ModifyIfCourseCounts.isHidden
        //ResetAllCourseLevels.isHidden = !ResetAllCourseLevels.isHidden
        S1Average.isHidden = !S1Average.isHidden
        S2Average.isHidden = !S2Average.isHidden
        S1IndicatorLbl.isHidden = !S1IndicatorLbl.isHidden
        S2IndicatorLbl.isHidden = !S2IndicatorLbl.isHidden
    }
    
    func RetrieveGradeInformation(grades: [LegacyGrade]){
        //var temp = LegacyGrade(sectionName: "", courses: [])
        for LEG in grades{
                var prog = 0
                for Class in LEG.Courses{
                    if(Class.Grades.Grades["FIN"] == ""){
                        LEG.Courses.remove(at: prog)
                        prog-=1
                    }
                    prog += 1
                    if prog >= LEG.Courses.count-1{
                        prog = 0
                    }
                }
        }
        LegacyGrades = grades
        let tmp = LegacyGrades.removeFirst()
        tmp.Courses = Courses
        LegacyGrades.insert(tmp, at: 0)
        tableView.reloadData()
        importantUtils.DestroyLoadingView(views: self.view)
        SetFinalAverageValues()
    }
    
    @IBAction func ChangeCreditValueAmount(_ sender: UISegmentedControl) {
        let cell = sender.superview?.superview as! CourseInfo
        let CourseCreditAmts = (Double(sender.selectedSegmentIndex) + 1.0)/2.0
        if Status == 0{
            SetCourseCreditWorthLibrary(Courses[cell.Row].Class, credits: CourseCreditAmts)
        }else{
            SetCourseCreditWorthLibrary(LegacyGrades[cell.Section].Courses[cell.Row].Class, credits: CourseCreditAmts)
        }
        SetFinalAverageValues()
    }
    
    //    @IBAction func HalfCreditSwitchChanged(_ sender: UISwitch) {
//        let cell = sender.superview?.superview as! CourseInfo
//        if Status == 0{
//            SetIsHalfCredit(Courses[cell.Row].Class, isHalfCredit: sender.isOn)
//        }else{
//            SetIsHalfCredit(LegacyGrades[cell.Section].Courses[cell.Row].Class, isHalfCredit: sender.isOn)
//        }
//        SetCellCreditAmount(cell: cell, isHalf: sender.isOn)
//        SetFinalAverageValues()
//        tableView.reloadData()
//    }
    
    @IBAction func goBack(_ sender: Any) {
        let JS = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
        InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func DisplayInstructions(_ sender: Any) {
        let instructions = UIAlertController(title: "Don't know how to use this?", message: "If you tap a cell in table view, it will change weights. Change how many credits a class is worth with the sections on every cell.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        instructions.addAction(ok)
        self.present(instructions, animated: true, completion: nil)
    }
}

class CourseInfo: UITableViewCell{
    @IBOutlet weak var Course: UILabel!
    @IBOutlet weak var APInfo: UILabel!
    @IBOutlet weak var CreditWorth: UISegmentedControl!
    
    var Section: Int = 0
    var Row: Int = 0
}
