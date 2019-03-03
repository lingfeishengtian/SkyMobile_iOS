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
import Kanna

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
//                let greenVal = CGFloat(Double(Grade)/Double(100) )
//                var red = CGFloat((Double(Grade+(low-1))/Double(high)) * 10)
//                if Grade == low{
//                    red = red  * 0.7
//                }
                let green = Double(Grade)*2.55/255
                let red = (1.0-green)*6.0
                
                let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: 0, alpha: 1)
                finalColors.append(color)
                //print(color)
                //finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
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
    
    func CreateLoadingView(view: UIView, message: String) {
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
        
        let loadingMessage = UILabel(frame: customView.frame)
        loadingMessage.frame = CGRect(x: view.frame.minX, y: view.center.y + 20, width: view.frame.width, height: 30)
        loadingMessage.textAlignment = .center
        loadingMessage.text = message
        loadingMessage.tag = 156
        loadingMessage.numberOfLines = 5
        
        view.addSubview(loadingMessage)
    }
    
    func DestroyLoadingView(views: UIView){
        for view in views.subviews{
            if view.tag == 154{
                view.removeFromSuperview()
            }else if let loadIcon = view as? UIActivityIndicatorView{
                if loadIcon.tag == 155{
                    loadIcon.removeFromSuperview()
                }
            }else if view.tag == 156{
                view.removeFromSuperview()
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
    func GetMajorAndDailyGrades(htmlCode: String, term: String, Class: String, DailyGrade: inout String, MajorGrade: inout String) -> AssignmentGrades{
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
                    do{
                        let dText =  try assignment.select(".bld.aRt").text()
                        if !dText.split(separator: " ").isEmpty{
                        DailyGrade = String(dText.split(separator: " ")[0])
                        }
                    }catch{}
                    isDaily = true
                }else if assignmentDesc.contains("MAJOR weighted at 50.00%") {
                    do{
                        let dText =  try assignment.select(".bld.aRt").text()
                        if !dText.split(separator: " ").isEmpty{
                        MajorGrade = String(dText.split(separator: " ")[0])
                        }
                    }catch{}
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
    
    @available(*, deprecated, message: "Switching over to Kanna because of higher performance boost")
    func parseHTMLToGetGrades(htmlCodeToParse: String) -> [Course]{
        //Contains all courses that are available
        var newCourse: [Course] = []
        var classes: [String] = []
        let cssSelectorCode = "tr[group-parent]"
        //HINT: document.querySelectorAll("tr[group-parent]")[4].querySelectorAll("a[data-lit=\"T1\"]")[0].textContent
        do{
            let document = try SwiftSoup.parse(htmlCodeToParse)
            print("Finished parsing")
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
        print("DONE")
        return newCourse
    }
    
    //MARK: New function using Kanna HTML parser to retrieve class data
    func ParseHTMLAndRetrieveGrades(html: String) -> [Course]{
        var newCourse: [Course] = []
        var classes: [String] = []
        let cssSelectorCode = "tr[group-parent]"
        
            if let document = try? HTML(html: html, encoding: .utf8){
                let elements = document.css(cssSelectorCode)
                //MARK: Retrieving classes
                for element in elements {
                    let text = element.text
                    if(text!.contains("Period")){
                        classes.append(text!)
                    }
                }
                
                newCourse = SplitClassDescriptionForKanna(classArr: classes)
                for elementIndex in 0...newCourse.count-1{
                    let html = elements[elementIndex].toHTML
                    for (term, _) in newCourse[elementIndex].Grades.Grades{
                        let document1 = try? HTML(html: html!, encoding: .utf8)
                        let gradeElem1 = document1!.css("a[data-lit=\""+term+"\"]")
                        for element in gradeElem1{
                            newCourse[elementIndex].Grades.Grades[term] = element.text
                        }
                    }
                    //print("Class: " + text + "\nGrade: " + html)
                }
            }
        return newCourse
    }
    
    func DisplayErrorMessage(message: String){
        DestroyLoadingView(views: (UIApplication.topViewController()?.view)!)
        let CannotFindValidValue = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        CannotFindValidValue.addAction(OKOption)
        UIApplication.topViewController()?.show(CannotFindValidValue, sender: nil)
    }
    
    fileprivate func SplitClassDescriptionForKanna(classArr: [String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            if Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n").count <= 1{
                let current = Course(
                    period: Int(Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n")[0].components(separatedBy: "(")[0])!,
                    classDesc: Class.components(separatedBy: "\nPeriod")[0].components(separatedBy: "\n\n\n")[1],
                    teacher: Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: "(\n")[0].components(separatedBy: "\n\n\n")[0])
                
                finalPeriod.append(current)
            }else{
                let current = Course(
                    period: Int(Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n")[0].components(separatedBy: "(")[0])!,
                    classDesc: Class.components(separatedBy: "\nPeriod")[0].components(separatedBy: "\n\n\n")[1],
                    teacher: Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n")[1].components(separatedBy: "\n\n\n")[0])
                
                finalPeriod.append(current)
            }
        }
        
        //        for testCase in finalPeriod{
        //            print("Class: " + testCase.Class + "\nPeriod: " + String(testCase.Period) + "\nTeacher: " + testCase.Teacher)
        //        }
        return finalPeriod
    }
    
    fileprivate func SplitClassDescription(classArr: [String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            if Class.components(separatedBy: " Period")[1].components(separatedBy: ") ").count <= 1{
                let current = Course(
                    period: Int(Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[0].components(separatedBy: "(")[0])!,
                    classDesc: Class.components(separatedBy: " Period")[0],
                    teacher: Class.components(separatedBy: " Period")[1].components(separatedBy: "( ")[0])
                
                finalPeriod.append(current)
            }else{
            let current = Course(
                period: Int(Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[0].components(separatedBy: "(")[0])!,
                classDesc: Class.components(separatedBy: " Period")[0],
                teacher: Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[1])
            
            finalPeriod.append(current)
            }
        }
        
        //        for testCase in finalPeriod{
        //            print("Class: " + testCase.Class + "\nPeriod: " + String(testCase.Period) + "\nTeacher: " + testCase.Teacher)
        //        }
        return finalPeriod
    }
    
    func SaveAccountValuesToStorage(accounts: [Account]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: accounts)
        
        UserDefaults.standard.set(encodedData, forKey: "AccountStorageService")
    }
}
