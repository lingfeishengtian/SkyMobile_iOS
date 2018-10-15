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

class FinalGradeDisplay: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var loadingCircle: UIActivityIndicatorView!
    var webView:WKWebView = WKWebView()
    var ClassColorsDependingOnGrade: [UIColor] = []
    @IBOutlet weak var pickTerm: UIPickerView!
    
    var Courses: [Course] = []
    var Options = ["PR1",
                    "PR2",
                    "T1",
                    "PR3",
                    "PR4",
                    "T2",
                    "SE1",
                    "S1",
                    "PR5",
                    "PR6",
                    "T3",
                    "PR7",
                    "PR8",
                    "T4",
                    "SE2",
                    "S2",
                    "FIN"]
    var indexOfOptions = 0;
    @IBOutlet weak var table: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        if IsElementaryAccount(courses: Courses){
            for option in Options{
                if option.contains("PR") || option.contains("S"){
                    Options.remove(at: Options.firstIndex(of: option)!)
                }
            }
        }
        ClassColorsDependingOnGrade = DetermineColor(fromClassGrades: Courses)
        let ShouldBeDisplay = GuessShouldDisplayScreen(courses: Courses)
        indexOfOptions = Options.firstIndex(of: ShouldBeDisplay)!
    }
    //TODO: Create Func that allows for assignment
    override func viewDidLoad() {
        pickTerm.selectRow(indexOfOptions, inComponent: 0, animated: true)
        ClassColorsDependingOnGrade = DetermineColor(fromClassGrades: Courses)
        table.reloadData()
        table.delegate = self
        table.dataSource = self
        pickTerm.delegate = self
        pickTerm.dataSource = self
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
        ClassColorsDependingOnGrade = DetermineColor(fromClassGrades: Courses)
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Courses.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Find cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GradeTableViewCell
        
        //Add cell text
        cell.lblPeriod.text = String(Courses[indexPath.row].Period)
        cell.lblClassDesc.text = String(Courses[indexPath.row].Class)
        
        let grade = Courses[indexPath.row].Grades.Grades[Options[pickTerm.selectedRow(inComponent: 0)]]!
        if(grade == "-1000"){
            cell.lblGrade.text = " "
        }else{
            cell.lblGrade.text = (grade)
        }
        
        //Add cell color!!!!
        let currentColor = ClassColorsDependingOnGrade[indexPath.row]
        cell.lblGrade.backgroundColor = currentColor
        cell.lblClassDesc.backgroundColor = currentColor
        cell.lblPeriod.backgroundColor = currentColor
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       GetAssignments(webView: webView, indexOfCourse: indexPath.row, indexOfOptions: indexOfOptions)
        print(indexPath.row)
    }
    
    func GetAssignments(webView: WKWebView,indexOfCourse indexOfClass: Int, indexOfOptions:Int){
        var javaScript = "document.querySelectorAll(\"tr[group-parent]\")["+String(indexOfClass)+"].querySelector(\"a[data-lit=\\\"" + Options[indexOfOptions] + "\\\"]\").click();"
        print(javaScript)
        loadingCircle.startAnimating()
        webView.evaluateJavaScript(javaScript){ (result, error) in
        }
        _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
        javaScript = "document.documentElement.outerHTML.toString()"
        webView.evaluateJavaScript(javaScript){ (result, error) in
                if error == nil {
                    let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                    let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
                    vc.webView = self.webView;
                    vc.Class = self.Courses[indexOfClass].Class
                    vc.Term = self.Options[indexOfOptions]
                    vc.HTMLCodeFromGradeClick = result as! String
                    vc.Courses = self.Courses
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
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
            for (term, grade) in course.Grades.Grades{
                if(grade != "-1000" && (term.contains("PR") || term.contains("T"))){
                    CurrentGuess = term
                }
            }
        }
        print("GUESS::     ",CurrentGuess)
        return CurrentGuess
    }
    
    func DetermineColor(fromClassGrades classes: [Course]) -> [UIColor] {
        var finalColors: [UIColor] = []
        var high = -9999;
        var low = 9999;
        for cclass in classes{
            if let Grade = Int(cclass.Grades.Grades[Options[indexOfOptions]]!){
            if Grade != -1000{
                if max(high, Grade) == Grade{
                    high = Grade
                }
                if min(low, Grade) == Grade{
                    low = Grade
                }
            }
            }
        }
        let range = high - low
        
        print(high)
        print(low)
        print(range)
        
        for cclass in classes{
            if let Grade = Int(cclass.Grades.Grades[Options[indexOfOptions]]!){
             if Grade != -1000{
            let greenVal = CGFloat(Double(Grade)/Double(100) )
                let red = CGFloat((Double(Grade-(low-1))/Double(high)) * 10)
            print((greenVal).description + "  " + red.description)
                finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
             }else{
                finalColors.append(UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0))
            }
            }else{
                finalColors.append(UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0))
            }
        }
        
        return finalColors
    }

}

class GradeTableViewCell: UITableViewCell{
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblClassDesc: UILabel!
}
