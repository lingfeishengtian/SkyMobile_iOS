//
//  ImportantUtils.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/18/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SwiftSoup

class ImportantUtils {
    fileprivate func findMaxAndLowOf(_ finalGrades: [Double], _ high: inout Double, _ low: inout Double) {
        for Grade in finalGrades{
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
    
    func DetermineColor(fromClassGrades classes: [Course] = [],fromAssignmentGrades assignments: AssignmentGrades = AssignmentGrades(classDesc: "NIL"), gradingTerm: String) -> [UIColor] {
        var finalColors: [UIColor] = []
        var high:Double = -9999.0;
        var low:Double = 9999.0;
        var finalGrades:[Double] = []
        
        if(classes.isEmpty){
            for grade in assignments.DailyGrades{
                finalGrades.append(grade.Grade)
            }
            for grade in assignments.MajorGrades{
                finalGrades.append(grade.Grade)
            }
        }else{
            for course in classes{
                finalGrades.append(Double(course.Grades.Grades[gradingTerm] ?? "-1000") ?? -1000.0)
            }
        }
        findMaxAndLowOf(finalGrades, &high, &low)
        
        for Grade in finalGrades{
            if Grade != -1000.0{
                let greenVal = CGFloat(Double(Grade)/Double(100) )
                let red = CGFloat((Double(Grade-(low-1))/Double(high)) * 10)
                finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
            }else{
                finalColors.append(UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0))
            }
        }
        return finalColors
    }
    
    func GetAverageFromSemester(courses: [Course], termName: String) -> Int{
        var finalGrades: Int = 0;
        for course in courses{
            let grade = Int(course.Grades.Grades[termName] ?? "-1000")
            if grade != -1000{
                finalGrades += grade!
            }
        }
        finalGrades /= courses.count
        return finalGrades
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Userstore")
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func CreateLoadingView(view: UIView) {
        let customView = UIView(frame: view.frame)
        customView.backgroundColor = UIColor(red: 111/255, green: 113/255, blue: 121/255, alpha: 0.7)
        customView.tag = 154
        view.addSubview(customView)
        let loadingIcon = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        //Don't forget this line
        loadingIcon.center = view.center
        
        loadingIcon.startAnimating()
        loadingIcon.tag = 155
        view.addSubview(loadingIcon)
    }
    
    func DestroyLoadingView(view: UIView){
        for view in view.subviews{
            if view.tag == 154{
                view.removeFromSuperview()
            }else if let loadIcon = view as? UIActivityIndicatorView{
                if loadIcon.tag == 155{
                    loadIcon.removeFromSuperview()
                }
            }
        }
    }
    
    func GuessClassLevel(className: String) -> String{
        if className.contains("PreA") || className.contains("Pre AP"){
            return "PreAP"
        }else if className.contains("AP"){
            return "AP"
        }else{
            return "Regular"
        }
    }
    func GetMajorAndDailyGrades(htmlCode: String, term: String, Class: String) -> AssignmentGrades{
        var DailyGrades:[Assignment] = [];
        var MajorGrades:[Assignment] = [];
        do{
            //HINT: document.querySelector("#gradeInfoDialog").querySelectorAll("tbody")[2].querySelectorAll("tr.sf_Section,.odd,.even")
            let document = try SwiftSoup.parse(htmlCode)
            let elements: Elements = try document.select("#gradeInfoDialog")
            let elements1: Elements = try elements.eq(0).select("tbody")
            let finalGrades: Elements = try elements1.eq(2).select("tr.sf_Section,.odd,.even")
            var isDaily = true
            
            for assignment in finalGrades{
                var assignmentDesc = try assignment.text()
                if assignmentDesc.contains("DAILY weighted at 50.00%") {
                    isDaily = true
                }else if assignmentDesc.contains("MAJOR weighted at 50.00%") {
                    isDaily = false
                }else{
                    assignmentDesc = assignmentDesc.components(separatedBy: " out of ").dropLast().joined()
                    let shortened = assignmentDesc.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let grade = shortened.components(separatedBy: "  ").last?.split(separator: " ").first
                    let finalDesc = shortened.components(separatedBy: "  ").dropLast().joined(separator: " ").components(separatedBy: " ").dropLast().joined(separator: " ")
                    if isDaily{
                        DailyGrades.append(Assignment(classDesc: Class, assignments: finalDesc, grade: Double(String(grade ?? "-1000.0")) ?? -1000.0))
                    }else{
                        MajorGrades.append(Assignment(classDesc: Class, assignments: finalDesc, grade: Double(String(grade ?? "-1000.0")) ?? -1000.0))
                    }
                }
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        var finalAssignment = AssignmentGrades(classDesc: Class)
        finalAssignment.DailyGrades = DailyGrades
        finalAssignment.MajorGrades = MajorGrades
        return finalAssignment
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
    func parseHTMLToGetGrades(htmlCodeToParse: String) -> [Course]{
        //Contains all courses that are available
        var newCourse: [Course] = []
        var classes: [String] = []
        let cssSelectorCode = "tr[group-parent]"
        //HINT: document.querySelectorAll("tr[group-parent]")[4].querySelectorAll("a[data-lit=\"T1\"]")[0].textContent
        do{
            let document = try SwiftSoup.parse(htmlCodeToParse)
            //print(htmlCodeToParse)
            // firn css selector
            let elements: Elements = try document.select(cssSelectorCode)
            //transform it into a local object (Item)
            
            for element in elements {
                let text = try element.text()
                if(text.contains("Period")){
                    classes.append(text)
                }
            }
            newCourse = SplitClassDescription(classArr: classes)
            for elementIndex in 0...newCourse.count-1{
                let html = try elements.eq(elementIndex).outerHtml()
                for (term, _) in newCourse[elementIndex].Grades.Grades{
                    let document1 = try SwiftSoup.parse(html)
                    let gradeElem1: Elements = try document1.select("a[data-lit=\""+term+"\"]")
                    for element in gradeElem1{
                        newCourse[elementIndex].Grades.Grades[term] = (try element.text())
                    }
                }
                //print("Class: " + text + "\nGrade: " + html)
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        return newCourse
    }
    
    fileprivate func SplitClassDescription(classArr: [String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            let current = Course(
                period: Int(Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[0].components(separatedBy: "(")[0])!,
                classDesc: Class.components(separatedBy: " Period")[0],
                teacher: Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[1])
            finalPeriod.append(current)
        }
        
        //        for testCase in finalPeriod{
        //            print("Class: " + testCase.Class + "\nPeriod: " + String(testCase.Period) + "\nTeacher: " + testCase.Teacher)
        //        }
        return finalPeriod
    }
}
