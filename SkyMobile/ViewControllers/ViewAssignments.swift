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
    var Class = "Nil"
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    
    @IBOutlet weak var navView: UINavigationItem!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var DailyGradeTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let DailyGradeControl: AssignmentViewTable = AssignmentViewTable()
    let MajorGradeControl: AssignmentViewTable = AssignmentViewTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height*3)
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
        var Assignments = AssignmentGrades(classDesc: Class)
        if !isNotValid{
        Assignments = GetMajorAndDailyGrades(htmlCode: HTMLCodeFromGradeClick, term: Term, Class: Class)
        }
        
        DailyGradeControl.DailyGrades = Assignments.DailyGrades
        DailyGradeControl.MajorGrades = Assignments.MajorGrades
        DailyGradeTable.delegate = DailyGradeControl
        DailyGradeTable.dataSource = DailyGradeControl
        DailyGradeControl.webView = webView

        
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
        var DailyGrades:[String: Double] = [:];
        var MajorGrades:[String: Double] = [:];
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
                    assignmentDesc.removeLast(11)
                    let shortened = assignmentDesc.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let grade = shortened.components(separatedBy: "   ").last?.split(separator: " ").first
                    let finalDesc = shortened.components(separatedBy: "   ").dropLast().joined(separator: " ").components(separatedBy: " ").dropLast().joined(separator: " ")
                    if isDaily{
                        DailyGrades[finalDesc] = Double(String(grade ?? " "))
                    }else{
                        MajorGrades[finalDesc] = Double(String(grade ?? " "))
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
    var DailyGrades:[String: Double] = [:]
    var MajorGrades:[String: Double] = [:]
    var webView = WKWebView()
    
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
            cell.lblAssignment.text = Array(DailyGrades)[indexPath.row].key
            cell.lblGrade.text = String(Array(DailyGrades)[indexPath.row].value)
        }else{
            cell.lblAssignment.text = Array(MajorGrades)[indexPath.row].key
            cell.lblGrade.text = String(Array(MajorGrades)[indexPath.row].value)
        }
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell
    }
    
    func showAssignmentInformation(){
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        vc.webView = self.webView;
        self.present(vc, animated: true, completion: nil)
    }
}
