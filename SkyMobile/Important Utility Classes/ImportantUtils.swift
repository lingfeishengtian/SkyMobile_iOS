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
import Kanna
import SystemConfiguration

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
    
//    func DetermineColor(fromClassGrades classes: [Course] = [],fromAssignmentGrades assignments: AssignmentBlock = AssignmentGrades(classDesc: "NIL"), gradingTerm: String) -> [UIColor] {
//        var finalColors: [UIColor] = []
//        var high:Double = -9999.0;
//        var low:Double = 9999.0;
//        var finalGrades:[Double] = []
//
//        if(classes.isEmpty){
//            for grade in assignments.DailyGrades{
//                finalGrades.append(grade.Grade)
//            }
//            for grade in assignments.MajorGrades{
//                finalGrades.append(grade.Grade)
//            }
//        }else{
//            for course in classes{
//                finalGrades.append(Double(course.Grades.Grades[gradingTerm] ?? "-1000") ?? -1000.0)
//            }
//        }
//        findMaxAndLowOf(finalGrades, &high, &low)
//
//        for Grade in finalGrades{
//            if Grade != -1000.0{
////                let greenVal = CGFloat(Double(Grade)/Double(100) )
////                var red = CGFloat((Double(Grade+(low-1))/Double(high)) * 10)
////                if Grade == low{
////                    red = red  * 0.7
////                }
//                let green = Double(Grade)*2.55/255
//                let red = (1.0-green)*6.0
//
//                let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: 0, alpha: 1)
//                finalColors.append(color)
//                //print(color)
//                //finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
//            }else{
//                finalColors.append(UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0))
//            }
//        }
//        return finalColors
//    }
    
    func DetermineColor(from num: Double) -> UIColor{
        if num != -1000.0{
            let green = Double(num)*2.55/255
            let red = (1.0-green)*6.0
            
            return UIColor(red: CGFloat(red), green: CGFloat(green), blue: 0, alpha: 1)
        }
        return UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0)
    }
    
    func GetAverageFromSemester(courses: [Course], termName: String) -> Int{
        var finalGrades: Int = 0;
        for course in courses{
            let grade = Int(course.termGrades[termName] ?? "-1000")
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
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
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
    
    func GetLoadingViewText(views: UIView) -> String?{
        for view in views.subviews{
            if view.tag == 156{
                return (view as? UILabel)?.text
            }
        }
        return nil
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
    
    func RetrieveGradesAndAssignmentsFromSelectedTermAndCourse(htmlCode: String, term: String, Class: String, DailyGrade: inout String, MajorGrade: inout String) -> AssignmentBlock{
        var finAssignmentBlock = AssignmentBlock()
        do{
            //HINT: document.querySelector("#gradeInfoDialog").querySelectorAll("tbody")[2].querySelectorAll("tr.sf_Section,.odd,.even")
            let document = try? HTML(html: htmlCode, encoding: .utf8)
            let elements = document?.css("tbody").first?.css("tbody")
            let finalGrades = elements![(elements?.count)!-1].css("tr")
            
            var stillScrapingSections = false
            
            for assignment in finalGrades{
                var assignmentDescription = assignment.text
                let separatedTdValues = assignment.css("td")
                
                if (assignment.toHTML?.contains("sf_Section"))!{
                        var weightAttempt: String? = nil
                        var grade: String? = nil
                        
                        if(separatedTdValues[1].text!.contains("weighted at ")){
                            weightAttempt = separatedTdValues[1].text!.components(separatedBy: "weighted at ").last?.replacingOccurrences(of: "%", with: "").replacingOccurrences(of: ")", with: "")
                            assignmentDescription = separatedTdValues[1].text!.components(separatedBy: "weighted at ").first?.replacingOccurrences(of: " (", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        for elem in separatedTdValues{
                            if (Double(elem.text!) != nil){
                                grade = elem.text!
                            }
                        }
                        
                        if (!stillScrapingSections){
                        finAssignmentBlock.AllAssignmentSections.append(MainAssignmentSection(assignmentDescription ?? "", weightAttempt, grade))
                            stillScrapingSections = true
                        }else{
                            finAssignmentBlock.AllAssignmentSections[finAssignmentBlock.AllAssignmentSections.endIndex - 1].minorSections.append(MinorAssignmentSection(assignmentDescription ?? "", weightAttempt!, grade ?? ""))
                        }
                }else{
                    stillScrapingSections = false
                    var grade = ""
                        var FinalAssignment = Assignment(classDesc: Class, assignments: assignmentDescription!, grade: Double(String(grade)) ?? -1000.0)
                    if separatedTdValues.count <= 1{
                        FinalAssignment = Assignment(classDesc: Class, assignments: "No grades here...", grade: -1000)
                        FinalAssignment.AssignmentTag = 1
                    }else{
                    for elem in separatedTdValues{
                        if let assinGrade = Double(elem.text!.trimmingCharacters(in: .whitespaces)){
                            grade = String(assinGrade)
                        }
                    }
                    assignmentDescription = separatedTdValues[1].text!
                        FinalAssignment = Assignment(classDesc: Class, assignments: assignmentDescription!, grade: Double(String(grade )) ?? -1000.0)
                    }
                    finAssignmentBlock.placeAssignmentInLastMainAvailable(assignment: FinalAssignment)
                }
            }
        }
        return finAssignmentBlock
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
    
    //MARK: New function using Kanna HTML parser to retrieve class data
    func ParseHTMLAndRetrieveGrades(html: String, allTheTermsSeperatedByN terms: String, GradesOptionsOut:inout [String]) -> [Course]{
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
                
                var Grades: [String:String] = [:]
                for elem in terms.components(separatedBy: "@SWIFT_TERM_SEPARATOR@"){
                    if !elem.isEmpty{
                        Grades[elem] = "-1000"
                        GradesOptionsOut.append(elem)
                    }
                }
                
                newCourse = SplitClassDescriptionForKanna(classArr: classes)
                for elementIndex in 0...newCourse.count-1{
                    let html = elements[elementIndex].toHTML
                        let document1 = try? HTML(html: html!, encoding: .utf8)
                        let gradeElem1 = document1!.css("td")
                        var index = 0
                        for element in gradeElem1{
                            Grades[GradesOptionsOut[index]] = element.text
                            index += 1
                        }
                    newCourse[elementIndex].termGrades = Grades
                    //print("Class: " + text + "\nGrade: " + html)
                }
            }
        return newCourse
    }
    
    static func AttemptToParseHTMLAndGetAvailableAccounts(html: String) -> [String]{
        var FinalList: [String] = []
        
        if let ParsedHTML = try? HTML(html: html, encoding: .utf8){
            for People in ParsedHTML.css("a"){
                if People.text != "All Students"{
                    FinalList.append(People.text ?? "")
                }
            }
        }else{
            return ["@SWIFT_PROCEDURE_FAILED_ERROR"]
        }
        return FinalList
    }
    
    func DisplayErrorMessage(message: String){
        DestroyLoadingView(views: (UIApplication.topViewController()?.view)!)
        let CannotFindValidValue = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        CannotFindValidValue.addAction(OKOption)
        UIApplication.topViewController()?.show(CannotFindValidValue, sender: nil)
    }
    
    func DisplayWarningMessage(message: String){
        DestroyLoadingView(views: (UIApplication.topViewController()?.view)!)
        let CannotFindValidValue = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        CannotFindValidValue.addAction(OKOption)
        UIApplication.topViewController()?.show(CannotFindValidValue, sender: nil)
    }
    
    fileprivate func SplitClassDescriptionForKanna(classArr: [String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            if Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n").count <= 1{
                let current = Course(
                    period: (Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n")[0].components(separatedBy: "(")[0]),
                    classDesc: Class.components(separatedBy: "\nPeriod")[0].components(separatedBy: "\n\n\n")[1],
                    teacher: Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: "(\n")[0].components(separatedBy: "\n\n\n")[0])
                
                finalPeriod.append(current)
            }else{
                let current = Course(
                    period: (Class.components(separatedBy: "\nPeriod")[1].components(separatedBy: ")\n")[0].components(separatedBy: "(")[0]),
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
    
    static func SaveAccountValuesToStorage(accounts: [Account]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: accounts)
        
        UserDefaults.standard.set(encodedData, forKey: "AccountStorageService")
    }
    
    static func GetAccountValuesFromStorage() -> [Account]{
        var accounts: [Account] = []
        if ImportantUtils.isKeyPresentInUserDefaults(key: "AccountStorageService"){
            if let data = UserDefaults.standard.data(forKey: "AccountStorageService"){
                accounts = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Account]
            }
        }else{
            let encoded = NSKeyedArchiver.archivedData(withRootObject: accounts)
            UserDefaults.standard.set(encoded, forKey: "AccountStorageService")
        }
        return accounts
    }
    
    static func SaveDistrictToStorage(district: District) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: district)
        
        UserDefaults.standard.set(encodedData, forKey: "JefoSelechDieDistraichtein")
    }
    
    static func GetDistrictsFromStorage() -> District{
        var district: District = District(name: "FORT BEND ISD", URLLink: URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!, gpaSupportType: GPACalculatorSupport.HundredPoint)
        if ImportantUtils.isKeyPresentInUserDefaults(key: "JefoSelechDieDistraichtein"){
            if let data = UserDefaults.standard.data(forKey: "JefoSelechDieDistraichtein"){
                district = NSKeyedUnarchiver.unarchiveObject(with: data) as! District
            }
        }else{
            let encoded = NSKeyedArchiver.archivedData(withRootObject: district)
            UserDefaults.standard.set(encoded, forKey: "JefoSelechDieDistraichtein")
        }
        return district
    }
    
    static func isConnectedToNetwork() -> Bool {
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
}
