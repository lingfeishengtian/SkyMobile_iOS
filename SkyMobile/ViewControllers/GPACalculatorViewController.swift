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
    let Courses = InformationHolder.Courses
    var LegacyGrades: [LegacyGrade] = []
    var importantUtils = ImportantUtils()
    var progress = 0
    //Status 0 is simple and 1 is advanced
    var Status = 0
    
    @IBOutlet weak var S1Average: UILabel!
    @IBOutlet weak var S2Average: UILabel!
    @IBOutlet weak var FinalGPA: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var GPACalculatorTitle: UILabel!
    @IBOutlet weak var tableViewHighConstraint: NSLayoutConstraint!
    @IBOutlet weak var AdvancedEnabler: UIButton!
    @IBOutlet weak var ModifyIfCourseCounts: UIButton!
    @IBOutlet weak var ResetAllCourseLevels: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InformationHolder.SkywardWebsite.frame = CGRect(x: 0, y: 0, width:0, height: 0)
        self.view.addSubview(InformationHolder.SkywardWebsite)
        //tableView.frame.origin = CGPoint(x: 0, y: FinalGPA.frame.maxY + 10)
        //tableView.frame.size = CGSize(width: self.view.frame.width, height: 100)
        
        GPACalculatorTitle.sizeToFit()
        tableView.delegate = self
        tableView.dataSource = self
        
        AdvancedEnabler.backgroundColor = UIColor.clear
        AdvancedEnabler.layer.cornerRadius = 5
        AdvancedEnabler.layer.borderWidth = 1
        AdvancedEnabler.layer.borderColor = UIColor.black.cgColor
        //OGCourses = Courses
        //SetTableViewHeightConstraint()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(Status == 0){
            return 1
        }else{
            return LegacyGrades.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(Status == 1){
            let NewGrade = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
            let GradeLabel = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: NewGrade.frame.maxY/2), size: CGSize(width: self.view.frame.size.width/4 * 3, height: NewGrade.frame.size.height)))
            GradeLabel.center = CGPoint(x: NewGrade.frame.maxX/2, y: NewGrade.frame.maxY/2)
            GradeLabel.text = LegacyGrades[section].Grade
            NewGrade.addSubview(GradeLabel)
            NewGrade.backgroundColor = UIColor.white
            return NewGrade
        }else{
            return nil
        }
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
        if !importantUtils.isKeyPresentInUserDefaults(key: Class+"Level"){
            UserDefaults.standard.set(importantUtils.GuessClassLevel(className: Class), forKey: Class + "Level")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CourseInfo
        var Class = ""
        progress += 1
        if(Status == 0){
            Class = Courses[indexPath.row].Class
            if(progress == Courses.count){
                progress = 0;
                SetFinalAverageValues()
            }
        }else{
            Class = LegacyGrades[indexPath.section].Courses[indexPath.row].Class
            SetFinalAverageValues()
        }
        
        cell.Course.text = Class
        SetClassLevel(Class)
        cell.APInfo.text = UserDefaults.standard.object(forKey: Class+"Level") as? String
        cell.Course.sizeToFit()
        
        cell.APInfo.frame.origin = CGPoint(x: self.view.frame.maxX-80, y: cell.APInfo.frame.minY)
        cell.frame.size = CGSize(width: cell.frame.size.width, height: 44)
        SetTableViewHeightConstraint()
        return cell
    }
    
    func SetTableViewHeightConstraint(){
        let TableContentSizeHeight = tableView.contentSize.height
        let CalculationOfTableHeight = (self.view.frame.size.height * 0.63)
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
    
    fileprivate func CheckLevelHelperForReloadGPAValues(_ level: (String?), _ NewClassAverage: inout Int, _ Class: Course, _ term: String, _ FinalCount: inout Int) {
        let LevelAddAmt = CheckAddAmt(level: level!)
        if LevelAddAmt != -1{
            NewClassAverage += Int(Class.Grades.Grades[term]!)! + LevelAddAmt
        }else{
            FinalCount -= 1
        }
        FinalCount += 1
    }
    
    fileprivate func CheckAddAmt(level: String) -> Int{
        if level == "PreAP"{
            return 5
        }else if level == "AP"{
            return 10
        }else if level == "N/A"{
            return -1
        }else{
            return 0
        }
    }
    
    func reloadGPAValues(term: String) -> Double{
        var NewClassAverage: Int = 0
        var FinalCount = 0
        if Status == 0{
        for course in Courses{
            let className = course.Class
            let level = (UserDefaults.standard.object(forKey: className+"Level") as? String)
            if Int(course.Grades.Grades[term]!) != -1000{
            if level == "PreAP"{
                NewClassAverage += Int(course.Grades.Grades[term]!)! + 5
            }else if level == "AP"{
                NewClassAverage += Int(course.Grades.Grades[term]!)! + 10
            }else if level == "N/A"{
                FinalCount -= 1
            }else{
                NewClassAverage += Int(course.Grades.Grades[term]!)!
            }
                FinalCount += 1
            }
        }
        }else{
            for grade in LegacyGrades{
                for Class in grade.Courses{
                    let className = Class.Class
                    let level = (UserDefaults.standard.object(forKey: className+"Level") as? String)
                    if (Class.Grades.Grades["FIN"]) != "" && (Class.Grades.Grades["FIN"]) != "-1000"{
                        CheckLevelHelperForReloadGPAValues(level, &NewClassAverage, Class, term, &FinalCount)
                    }else if Class.Grades.Grades["S1"] != "" && Class.Grades.Grades["S2"] != "" {
                        let LevelAddAmt = CheckAddAmt(level: level!)
                        if LevelAddAmt != -1{
                            NewClassAverage += (Int(Class.Grades.Grades["S1"]!)! + Int(Class.Grades.Grades["S2"]!)!)/2 + LevelAddAmt
                        }else{
                            FinalCount -= 1
                        }
                        FinalCount += 1
                    }
                    //print("Times " + FinalCount + " AT AVERAGE " + NewClassAverage + " FOR COURSE " + Class.Class)
                }
            }
        }
        return Double(NewClassAverage)/Double(FinalCount)
    }
    
    @IBAction func SwitchToAdvancedOrSimple(_ sender: Any) {
        if(Status == 1){ Status = 0; }else{ Status = 1 }
        if(Status == 1){
            importantUtils.CreateLoadingView(view: self.view, message: "This is a BETA TESTING PHASE!!!! ADDS ALL VALUES POSSIBLE!!!")
            AdvancedEnabler.setTitle("Simple", for: .normal)
            let JS = "document.querySelector('a[data-nav=\"sfacademichistory001.w\"]').click()"
            InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
            ModifyIfCourseCounts.isHidden = false
            ResetAllCourseLevels.isHidden = false
            S1Average.isHidden = true
            S2Average.isHidden = true
        }else{
            //importantUtils.CreateLoadingView(view: self.view, message: "This is a BETA TESTING PHASE!!!! ADDS ALL VALUES POSSIBLE!!!")
            AdvancedEnabler.setTitle("Advanced", for: .normal)
            ModifyIfCourseCounts.isHidden = true
            ResetAllCourseLevels.isHidden = true
            S1Average.isHidden = false
            S2Average.isHidden = false
        }
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
        //LegacyGrades.insert(temp, at: 0)
        tableView.reloadData()
        importantUtils.DestroyLoadingView(views: self.view)
    }
    
    @IBAction func goBack(_ sender: Any) {
        let JS = "document.querySelector('a[data-nav=\"sfgradebook001.w\"]').click()"
        InformationHolder.SkywardWebsite.evaluateJavaScript(JS, completionHandler: nil)
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        self.present(vc, animated: true, completion: nil)
    }
}

class CourseInfo: UITableViewCell{
    @IBOutlet weak var Course: UILabel!
    @IBOutlet weak var APInfo: UILabel!
}
