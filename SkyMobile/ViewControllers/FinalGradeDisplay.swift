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
import iAd

// MARK: - Prep into Private Beta 2.8
class FinalGradeDisplay: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{

    var webView:WKWebView = WKWebView()
    var ClassColorsDependingOnGrade: [UIColor] = []
    @IBOutlet weak var pickTerm: UIPickerView!
    
    @IBOutlet weak var moreMenuItemsStackView: UIStackView!
    let importantUtils = ImportantUtils()
    
    var Courses: [Course] = []
    var Options = ["PR1",
                    "PR2",
                    "T1",
                    "PR3",
                    "PR4",
                    "T2",
                    "S1",
                    "PR5",
                    "PR6",
                    "T3",
                    "PR7",
                    "PR8",
                    "T4",
                    "S2",
                    "FIN"]
    var indexOfOptions = 0;
    var isFirstRun = true
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        if IsElementaryAccount(courses: Courses){
            for option in Options{
                if option.contains("PR") || option.contains("S"){
                    Options.remove(at: Options.firstIndex(of: option)!)
                }
            }
        }
        let ShouldBeDisplay = GuessShouldDisplayScreen(courses: Courses)
        indexOfOptions = Options.firstIndex(of: ShouldBeDisplay)!
        pickTerm.selectRow(indexOfOptions, inComponent: 0, animated: true)
       ClassColorsDependingOnGrade = importantUtils.DetermineColor(fromClassGrades: Courses, gradingTerm: Options[indexOfOptions])
    }
    //TODO: Create Func that allows for assignment
    override func viewDidLoad() {
        table.frame.origin = CGPoint(x: pickTerm.frame.minX, y: pickTerm.frame.maxY)
        table.frame.size = CGSize(width: self.view.frame.width, height: 100)
        webView.frame = CGRect(x: 0, y: 250, width: 0, height: 0)
        view.addSubview(webView)
        
        table.reloadData()
        table.delegate = self
        table.dataSource = self
        pickTerm.delegate = self
        pickTerm.dataSource = self
        
        pickTerm.selectRow(indexOfOptions, inComponent: 0, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexOfOptions = row
        ClassColorsDependingOnGrade = importantUtils.DetermineColor(fromClassGrades: Courses, gradingTerm: Options[indexOfOptions])
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Courses.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        //Find cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GradeTableViewCell
        
        //Add cell text
        cell.lblPeriod.text = String(Courses[indexPath.row].Period)
        cell.lblClassDesc.text = String(Courses[indexPath.row].Class)
        cell.lblGrade.frame.origin = CGPoint(x: self.view.frame.maxX-50, y: cell.lblGrade.frame.minY)
        print(CGPoint(x: self.view.frame.maxX-50, y: cell.lblGrade.frame.minY))
        
        let grade = Courses[indexPath.row].Grades.Grades[Options[pickTerm.selectedRow(inComponent: 0)]]!
        if(grade == "-1000"){
            cell.lblGrade.text = " "
        }else{
            cell.lblGrade.text = (grade)
        }
        cell.lblClassDesc.sizeToFit()
        //Add cell color!!!!
        let currentColor = ClassColorsDependingOnGrade[indexPath.row]
        cell.backgroundColor = currentColor
        cell.alpha = CGFloat(0.7)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       GetAssignments(webView: webView, indexOfCourse: indexPath.row, indexOfOptions: indexOfOptions)
    }
    
//    func GetAssignments(webView: WKWebView,indexOfCourse indexOfClass: Int, indexOfOptions:Int){
//        var javaScript = "document.querySelectorAll(\"tr[group-parent]\")["+String(indexOfClass)+"].querySelector(\"a[data-lit=\\\"" + Options[indexOfOptions] + "\\\"]\").click();"
//        print(javaScript)
//        loadingCircle.startAnimating()
//        HideView.isHidden = false
//        webView.evaluateJavaScript(javaScript){ (result, error) in
//        }
//        _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
//        javaScript = "document.documentElement.outerHTML.toString()"
//        webView.evaluateJavaScript(javaScript){ (result, error) in
//                if error == nil {
//                    let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
//                    let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
//                    vc.webView = self.webView;
//                    vc.Class = self.Courses[indexOfClass].Class
//                    vc.Term = self.Options[indexOfOptions]
//                    vc.HTMLCodeFromGradeClick = result as! String
//                    vc.Courses = self.Courses
//                    self.present(vc, animated: true, completion: nil)
//                }
//            }
//        }
//    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    func GetAssignments(webView: WKWebView,indexOfCourse indexOfClass: Int, indexOfOptions:Int){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
        vc.webView = webView;
        vc.Class = self.Courses[indexOfClass].Class
        vc.Term = self.Options[indexOfOptions]
        vc.Courses = self.Courses
        
        webView.evaluateJavaScript("document.querySelectorAll(\"tr[group-parent]\")["+String(indexOfClass)+"].querySelector(\"a[data-lit=\\\"" + self.Options[indexOfOptions] + "\\\"]\").click();", completionHandler: nil)
        let javaScript = "document.querySelector(\"table[id^=grid_stuGradeInfoGrid]\").querySelector(\"a\").text"
        importantUtils.CreateLoadingView(view: self.view, message: "Trying to get grades...")
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true){ timer in
        DispatchQueue.main.async {
            webView.evaluateJavaScript(javaScript){ (result, error) in
                if let fin = result as? String{
                    if fin == self.Courses[indexOfClass].Class{
                        self.present(vc, animated: true, completion: nil)
                        timer.invalidate()
                    }
                }
            }
        }
        }
            // for _ in 1...10{
//            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
//                if vc.Assignments.DailyGrades.isEmpty && vc.Assignments.MajorGrades.isEmpty{
//                    webView.evaluateJavaScript(javaScript){ (result, error) in
//                        if error == nil {
//                            let resultString = result as! String
//                            //if resultString.contains(self.Options[indexOfOptions] + " Progress Report"){
//                            if resultString.contains(self.Options[indexOfOptions] + " Progress Report"){
//                                vc.HTMLCodeFromGradeClick = result as! String
//                                vc.Assignments = self.importantUtils.GetMajorAndDailyGrades(htmlCode: resultString, term: vc.Term, Class: vc.Class)
//                                vc.ColorsOfGrades = self.importantUtils.DetermineColor(fromAssignmentGrades: vc.Assignments, gradingTerm: vc.Term)
//                                vc.SetValuesOfGradeTableView()
//                                vc.GradeTableView.reloadData()
//                                timer.invalidate()
//                            }
//                        }
//                    }}else{ timer.invalidate() }
//            }
    }
    
    func IsElementaryAccount(courses: [Course]) -> Bool{
        for course in courses{
            for (term, grade) in course.Grades.Grades{
                if(grade != "-1000" && (term.contains("PR"))){
                    return false
                }
            }
        }
        return true
    }
    
    func GuessShouldDisplayScreen(courses: [Course]) -> String{
        var CurrentGuess = Options[0]
        for course in courses{
            for term in Options{
                if course.Grades.Grades[term] == "-1000"{
                    break
                }
                let isSatisfy = term.contains("PR") || term.contains("T")
                let indexSatisfy = abs(Options.firstIndex(of: term)!.distance(to: 0)) > abs(Options.firstIndex(of: CurrentGuess)!.distance(to: 0))
                if isSatisfy && indexSatisfy {
                    CurrentGuess = term
                }
            }
        }
        print("GUESS::     ",CurrentGuess)
        return CurrentGuess
    }
    @IBAction func goToGPACalculator(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : GPACalculatorViewController = mainStoryboard.instantiateViewController(withIdentifier: "GPACalculator") as! GPACalculatorViewController
        vc.webView = self.webView;
        vc.Courses = self.Courses
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func Logout(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout",
                                                message: "Are you sure you want to logout?",
                                                preferredStyle: UIAlertController.Style.alert)
        let confirmAction = UIAlertAction(
        title: "No", style: UIAlertAction.Style.cancel) { (action) in
            // ...
        }
        let confirmedAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive){ (action) in
            self.webView.removeFromSuperview()
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.importantUtils.resetDefaults()
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(confirmedAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func ShowMoreMenuItems(_ sender: Any) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn, .transitionCurlDown] ,animations: {
                for view in self.moreMenuItemsStackView.arrangedSubviews{
                    let btn = view as? UIButton
                    btn?.backgroundColor = .clear
                    btn?.layer.cornerRadius = 5
                    btn?.layer.borderWidth = 1
                    btn?.layer.borderColor = UIColor.black.cgColor
                    //btn?.frame = CGRect(x: btn!.frame.minX, y: (btn?.frame.minY)!, width: (btn?.frame.width)!, height: 50)
                    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                      view.isHidden = !view.isHidden
                    })
                }
                self.moreMenuItemsStackView.layoutIfNeeded()
            })
        }
}

class GradeTableViewCell: UITableViewCell{
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblClassDesc: UILabel!
}
