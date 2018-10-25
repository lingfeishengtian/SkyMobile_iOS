//
//  ViewAssignments.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/13/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import SwiftSoup
import WebKit


//TODO: Fix bug that crashes app when trying to view grades at Semester levels

class ViewAssignments: UIViewController {
    var webView: WKWebView = WKWebView()
    var Term = "PR1"
    var Class = "NIL"
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    let importantUtils = ImportantUtils()
    var ColorsOfGrades:[UIColor] = []
    var Assignments = AssignmentGrades(classDesc: "NIL")
    
    @IBOutlet weak var navView: UINavigationItem!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var GradeTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: GradientView!
    
    let GradeTableViewController: AssignmentViewTable = AssignmentViewTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: mainView.frame.height)
        navView.hidesBackButton = false
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack(_:)))
        self.navView.leftBarButtonItem = backButton
        SetLabelText(term: Term, Class: Class)
        var isNotValid = true
        for course in Courses{
            if(course.Class == Class){
                if(course.Grades.Grades[Term] != "-1000"){
                    isNotValid = false
                }
            }
        }
        
        webView.frame = CGRect(x: 0, y: 250, width: 0, height: 0)
        view.addSubview(webView)
        
        if !isNotValid && Assignments.Class == "NIL"{
        Assignments = GetMajorAndDailyGrades(htmlCode: HTMLCodeFromGradeClick, term: Term, Class: Class)
        }
        ColorsOfGrades = importantUtils.DetermineColor(fromAssignmentGrades: Assignments, gradingTerm: Term)
        GradeTableViewController.Colors = ColorsOfGrades
        
        GradeTableViewController.DailyGrades = Assignments.DailyGrades
        GradeTableViewController.MajorGrades = Assignments.MajorGrades
        GradeTableView.delegate = GradeTableViewController
        GradeTableView.dataSource = GradeTableViewController
        GradeTableViewController.webView = webView
        GradeTableViewController.Class = Class
        GradeTableViewController.Term = Term
        GradeTableViewController.Courses = Courses
        GradeTableViewController.Assignments = Assignments
    }
    
    func SetLabelText(term: String, Class: String){
        lblClass.text = Class
        lblTerm.text = term
    }
    
    @objc func goBack(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        vc.webView = self.webView;
        vc.Courses = Courses
        self.present(vc, animated: true, completion: nil)
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
                    print(assignmentDesc)
                    if isDaily{
                        DailyGrades.append(Assignment(classDesc: Class, assignments: finalDesc, grade: Double(String(grade ?? "-1000.0")) ?? -1000.0))
                    }else{
                        MajorGrades.append(Assignment(classDesc: Class, assignments: finalDesc, grade: Double(String(grade ?? "-1000.0")) ?? -1000.0))
                    }
                    print(finalDesc)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class AssignmentViewCells: UITableViewCell{
    @IBOutlet weak var lblAssignment: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
}

class HeaderCells: UITableViewCell{
    @IBOutlet weak var GradeSectionDesc: UILabel!
}

class AssignmentViewTable: UITableViewController{
    var DailyGrades:[Assignment] = [];
    var MajorGrades:[Assignment] = [];
    var Colors:[UIColor] = []
    
    var webView: WKWebView = WKWebView()
    var Term = "PR1"
    var Class = "Nil"
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    var importantUtils = ImportantUtils()
    var Assignments = AssignmentGrades(classDesc: "NIL")
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return DailyGrades.count
        }else{
            return MajorGrades.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderCells
        if section == 0 {
            headerCell.GradeSectionDesc.text = "Daily"
        }else{
            headerCell.GradeSectionDesc.text = "Major"
        }
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssignmentViewCells
        
        if(indexPath.section == 0){
            cell.lblAssignment.text = String(DailyGrades[indexPath.row].AssignmentName)
            var grade = String(DailyGrades[indexPath.row].Grade)
            if grade.contains("-1000"){
                grade = " "
            }
            cell.lblGrade.text = grade
            cell.lblGrade.textColor = Colors[indexPath.row]
        }else{
            cell.lblAssignment.text = String(MajorGrades[indexPath.row].AssignmentName)
            var grade = String(MajorGrades[indexPath.row].Grade)
            if grade.contains("-1000"){
                grade = " "
            }
            cell.lblGrade.text = grade
            cell.lblGrade.textColor = Colors[indexPath.row + DailyGrades.count]
        }
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Array.from(document.querySelectorAll('a'))
        //.find(el => el.textContent === 'Q Map');
        var assignmentName = ""
        if indexPath.section == 0{
            assignmentName = String(DailyGrades[indexPath.row].AssignmentName)
        }else{
            assignmentName = String(MajorGrades[indexPath.row].AssignmentName)
        }
        
        importantUtils.CreateLoadingView(view: (UIApplication.topViewController()?.view)!)
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if (UIApplication.topViewController()?.description.contains("ViewAssignments"))!{
                DispatchQueue.main.async {
                    self.webView.evaluateJavaScript("Array.from(document.querySelectorAll('a')).find(el => el.textContent === '" + assignmentName + "').click();\ndocument.documentElement.outerHTML.toString();"){ (result, error) in
                        if error == nil {
                            let resultFinalString = result as! String
                            if resultFinalString.contains("Assignment Details") && resultFinalString.contains("<td scope=\"row\" style=\"font-weight:bold\" colspan=\"4\">" + assignmentName) && resultFinalString.contains("dLog_showAssignmentInfo"){
                                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                                let vc : DetailedAssignmentViewController = mainStoryboard.instantiateViewController(withIdentifier: "DetailedAssignmentViewer") as! DetailedAssignmentViewController
                                vc.webView = self.webView;
                                vc.html = resultFinalString
                                vc.Class = self.Class
                                vc.Courses = self.Courses
                                vc.Term = self.Term
                                vc.AssignmentNameString = assignmentName
                                vc.Assignments = self.Assignments
                                UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }else{
                timer.invalidate()
            }
        }
    }
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}