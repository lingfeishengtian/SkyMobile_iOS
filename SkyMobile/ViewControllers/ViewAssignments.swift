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
    var Grade = ""
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    let importantUtils = ImportantUtils()
    var ColorsOfGrades:[UIColor] = []
    var Assignments = AssignmentGrades(classDesc: "NIL")
    var DailyGrade = "-1000"
    var MajorGrade = "-1000"
    var isEditingTableView = false
    
    @IBOutlet weak var FinalGrade: UILabel!
    @IBOutlet weak var navView: UINavigationItem!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var GradeTableView: UITableView!
    //@IBOutlet weak var LabelTermLeading: NSLayoutConstraint!
    
    let GradeTableViewController: AssignmentViewTable = AssignmentViewTable()
    
    func SetValuesOfGradeTableView() {
        if self.Assignments.DailyGrades.isEmpty && self.Assignments.MajorGrades.isEmpty{
            importantUtils.CreateLoadingView(view: self.view, message: "Trying to view assignment grades...")
        }else{
            self.importantUtils.DestroyLoadingView(views: self.view)
        }
        
            //Assignments = GetMajorAndDailyGrades(htmlCode: HTMLCodeFromGradeClick, term: Term, Class: Class)
        
        ColorsOfGrades = importantUtils.DetermineColor(fromAssignmentGrades: Assignments, gradingTerm: Term)
        GradeTableViewController.Colors = ColorsOfGrades
        FinalGrade.text = Grade
        
        GradeTableViewController.DailyGrades = Assignments.DailyGrades
        GradeTableViewController.MajorGrades = Assignments.MajorGrades
        GradeTableView.delegate = GradeTableViewController
        GradeTableView.dataSource = GradeTableViewController
        GradeTableViewController.webView = webView
        GradeTableViewController.Class = Class
        GradeTableViewController.Term = Term
        GradeTableViewController.Courses = Courses
        GradeTableViewController.Assignments = Assignments
        GradeTableViewController.HTMLCodeFromGradeClick = HTMLCodeFromGradeClick
        GradeTableViewController.headerDaily = DailyGrade
        GradeTableViewController.headerMajor = MajorGrade
        GradeTableViewController.TableView = GradeTableView
        GradeTableViewController.grade = FinalGrade
        GradeTableView.reloadData()
    }
    
    @IBAction func AddAssignment(_ sender: Any) {
        var MockAssignment = Assignment(classDesc: Class, assignments: "Mock Assignment", grade: 100.0)
        MockAssignment.isEditableByUserInteraction = true
        GradeTableViewController.DailyGrades.append(MockAssignment)
        GradeTableViewController.Colors.append(UIColor.black)
        for i in 0...GradeTableViewController.Colors.count-1{
            GradeTableViewController.Colors[i] = UIColor.black
        }
        GradeTableViewController.didPressEditing = true
        GradeTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        isEditingTableView = false
        GradeTableView.layer.cornerRadius = 5
        webView = InformationHolder.SkywardWebsite
        Courses = InformationHolder.Courses
        webView.frame = CGRect(x: 0, y: 350, width: 0, height: 0)
        view.addSubview(webView)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.goBack(_:)))
        self.navView.leftBarButtonItem = backButton
        SetLabelText(term: Term, Class: Class)
        
        navView.hidesBackButton = false
        
        AttemptToGetHTML()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func EditAssignments(_ sender: UIButton) {
        if isEditingTableView{
            sender.setTitle("Edit", for: .normal)
        }else{
            sender.setTitle("Done", for: .normal)
        }
        isEditingTableView = !isEditingTableView
        GradeTableViewController.isEditingTableView = isEditingTableView
        GradeTableView.isEditing = isEditingTableView
    }
    
    func AttemptToGetHTML(){
        let javaScript = "document.querySelector(\"#gradeInfoDialog\").outerHTML"
        var return1 = " "
            self.webView.evaluateJavaScript(javaScript){(obj, err) in
                if err != nil{
                    self.importantUtils.DisplayErrorMessage(message: "There was an error getting your grades, try again.")
                }else{
                    return1 = obj as! String
                        self.HTMLCodeFromGradeClick = return1
                        self.Assignments = self.importantUtils.RetrieveGradesAndAssignmentsFromSelectedTermAndCourse(htmlCode: return1, term: self.Term, Class: self.Class, DailyGrade: &self.DailyGrade, MajorGrade: &self.MajorGrade)
                        self.SetValuesOfGradeTableView()
                }
            }
    }
    
    func SetLabelText(term: String, Class: String){
        lblClass.text = Class
        lblTerm.text = term
    }
    
    @objc func goBack(_ sender: Any) {
        if InformationHolder.GlobalPreferences.ModernUI{
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
            self.present(vc, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
            self.present(vc, animated: true, completion: nil)
        }
    }
}

class AssignmentViewCells: UITableViewCell{
    @IBOutlet weak var lblAssignment: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    
    var Section = 0
    var Row = 0
    var isEditable = false
}

class HeaderCells: UITableViewCell{
    @IBOutlet weak var GradeSectionDesc: UILabel!
    @IBOutlet weak var Grades: UILabel!
}

class AssignmentViewTable: UITableViewController{
    var DailyGrades:[Assignment] = [];
    var MajorGrades:[Assignment] = [];
    var Colors:[UIColor] = []
    var TableView: UITableView = UITableView()
    var isEditingTableView = false
    var webView: WKWebView = WKWebView()
    var Term = "PR1"
    var Class = "Nil"
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    var importantUtils = ImportantUtils()
    var Assignments = AssignmentGrades(classDesc: "NIL")
    var constraint: NSLayoutConstraint = NSLayoutConstraint()
    var headerDaily = "-1000"
    var headerMajor = "-1000"
    var grade = UILabel()
    var didPressEditing = false
    
    func reloadAverageValues(){
        let AssignmentAverages = AddUpValues(grades: DailyGrades)
        let MajorGradeAverages = AddUpValues(grades: MajorGrades)
        headerDaily = String(AssignmentAverages)
        headerMajor = String(MajorGradeAverages)
        if AssignmentAverages == -1000.0{
            headerDaily = "No Grade"
            grade.text = String(MajorGradeAverages)
        }else if MajorGradeAverages == -1000.0{
            headerMajor = "No Grade"
            grade.text = String(AssignmentAverages)
        }else{
            grade.text = String((AssignmentAverages+MajorGradeAverages)/2.0)
        }
        TableView.reloadData()
    }
    
    func AddUpValues(grades: [Assignment]) -> Double{
        var finale: Double = 0.0
        var subVal = Double(grades.count)
        for grade in grades{
            if grade.Grade == -1000{
                subVal -= 1
            }else{
                finale += grade.Grade
            }
        }
        let num = finale/subVal
        if num.isNaN{
            return -1000.0
        }else{
            return Double(round(1000*(finale/subVal))/1000)
        }
    }
    
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
            if headerDaily != "-1000" { headerCell.Grades.text = headerDaily}
        }else{
            headerCell.GradeSectionDesc.text = "Major"
            if headerMajor != "-1000" { headerCell.Grades.text = headerMajor}
        }
        headerCell.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssignmentViewCells
        var AssignmentTMP = Assignment(classDesc: "", assignments: "", grade: -1000)
        var ShouldIndex = indexPath.row
        var grade = "-1000"
        if(indexPath.section == 1){
            AssignmentTMP = (MajorGrades[indexPath.row])
            ShouldIndex += DailyGrades.count-1
        }else{
            AssignmentTMP = DailyGrades[indexPath.row]
        }
        cell.lblAssignment.text = String(AssignmentTMP.AssignmentName)
        grade = String(AssignmentTMP.Grade)
        if grade.contains("-1000"){
            grade = " "
        }
        cell.lblGrade.text = grade
        if didPressEditing{
            cell.lblGrade.textColor = UIColor.black
        }else{
            cell.lblGrade.textColor = Colors[ShouldIndex]
        }
        
        var HasTextBox = false
        for view in cell.subviews{
            if let _ = view as? UITextField{
                HasTextBox = true
            }
        }
        
        if didPressEditing && !HasTextBox{
            let NewGradeTextBox = UITextField(frame: CGRect(x: cell.frame.width - 55 , y: cell.lblAssignment.frame.minY, width: 50, height: 23))
            NewGradeTextBox.keyboardType = .numberPad
            NewGradeTextBox.tag = 212
            cell.lblGrade.isHidden = true
            NewGradeTextBox.placeholder = "100"
            NewGradeTextBox.text = cell.lblGrade.text
            cell.addSubview(NewGradeTextBox)
            cell.Section = indexPath.section
            cell.Row = indexPath.row
            NewGradeTextBox.addTarget(self, action: #selector(NewGradeTextBoxValueDidChange(_:)), for: .editingDidEnd)
        }else if didPressEditing{
            (cell.viewWithTag(212) as? UITextField)?.text = grade
        }
        
        cell.frame.size = CGSize(width: cell.frame.width, height: 44)
        //tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell
    }
    
    @objc func NewGradeTextBoxValueDidChange(_ sender: UITextField){
        var NumTmpp = sender.text ?? ""
        if let _ = NumTmpp.firstIndex(of: "."){
            NumTmpp = String(NumTmpp.split(separator: ".").first ?? "")
        }
        if let cell = sender.superview as? AssignmentViewCells{
            let row = TableView.indexPath(for: cell)?.row
            NumTmpp = NumTmpp.trimmingCharacters(in: .whitespaces)
            if TableView.indexPath(for: cell)?.section == 0{
                DailyGrades[row!].Grade = Double(NumTmpp) ?? -1000
            }else{
                MajorGrades[row!].Grade = Double(NumTmpp) ?? -1000
            }
            reloadAverageValues()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0{
            let movedObject = DailyGrades[sourceIndexPath.row]
            DailyGrades.remove(at: sourceIndexPath.row)
            if destinationIndexPath.section == 0{
                DailyGrades.insert(movedObject, at: destinationIndexPath.row)
            }else{
                MajorGrades.insert(movedObject, at: destinationIndexPath.row)
            }
        }else{
            let movedObject = MajorGrades[sourceIndexPath.row]
            MajorGrades.remove(at: sourceIndexPath.row)
            if destinationIndexPath.section == 0{
                DailyGrades.insert(movedObject, at: destinationIndexPath.row)
            }else{
                MajorGrades.insert(movedObject, at: destinationIndexPath.row)
            }
        }
        for i in 0...Colors.count-1{
            Colors[i] = UIColor.black
        }
        reloadAverageValues()
    }
    
    fileprivate func AttemptToDisplayDetailedAssignment(_ assignmentName: String, _ initialAmt: Int, _ vc: DetailedAssignmentViewController = DetailedAssignmentViewController(), _ vc2: ModernDetailedAssignmentViewController = ModernDetailedAssignmentViewController()) {
        AttemptToClick(assignmentName: assignmentName)
        
        var Attempts = 0;
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true){ timer in
            self.webView.evaluateJavaScript("document.querySelector(\"#dLog_showAssignmentInfo\").querySelector(\"td\").textContent"){ result, err in
                
                //REMOVE AFTER FINISHED TESTING
                print("Searching for valid value attemp ",Attempts)
                Attempts += 1
                if Attempts % 20 == 0{
                    self.AttemptToClick(assignmentName: assignmentName)
                }
                if Attempts >= 61{
                    self.importantUtils.DestroyLoadingView(views: (UIApplication.topViewController()?.view)!)
                    let CannotFindValidValue = UIAlertController(title: "Error", message: "An error occured and we cannot find this assignment. Maybe the website was reloaded?", preferredStyle: .alert)
                    let OKOption = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    CannotFindValidValue.addAction(OKOption)
                    UIApplication.topViewController()?.present(CannotFindValidValue, animated: true, completion: nil)
                    timer.invalidate()
                }
                
                if err == nil{
                    if let fin = result as? String{
                        if fin.contains(assignmentName){
                            
                            print("I found something!")
                            
                            //_ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                            self.webView.evaluateJavaScript("document.querySelector(\"#dLog_showAssignmentInfo\").outerHTML;"){ (result, error) in
                                if error == nil {
                                    let resultFinalString = result as! String
                                    print("Initial, ", initialAmt)
                                    print(resultFinalString.components(separatedBy: assignmentName).count - 1)
                                    vc.html = resultFinalString
                                    vc2.html = resultFinalString
                                    
                                    if InformationHolder.GlobalPreferences.ModernUI{
                                        UIApplication.topViewController()?.present(vc2, animated: true, completion: nil)
                                    }else{
                                        UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                                    }
                                    //    timer.invalidate()
                                }
                                //}
                            }
                            timer.invalidate()
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Array.from(document.querySelectorAll('a'))
        //.find(el => el.textContent === 'Q Map');
        var assignmentName = ""
        if indexPath.section == 0{
            assignmentName = String(DailyGrades[indexPath.row].AssignmentName)
            if DailyGrades[indexPath.row].Grade == -1000{
                importantUtils.DisplayErrorMessage(message: "This assignment's grades haven't been put in yet silly.")
                return
            }
        }else{
            assignmentName = String(MajorGrades[indexPath.row].AssignmentName)
            if MajorGrades[indexPath.row].Grade == -1000{
                importantUtils.DisplayErrorMessage(message: "This assignment's grades haven't been put in yet silly.")
                return
            }
        }
        
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        
        if !InformationHolder.GlobalPreferences.ModernUI{
            let vc : DetailedAssignmentViewController = mainStoryboard.instantiateViewController(withIdentifier: "DetailedAssignmentViewer") as! DetailedAssignmentViewController
            InformationHolder.SkywardWebsite = webView
            vc.Class = self.Class
            vc.Term = self.Term
            vc.AssignmentNameString = assignmentName
            vc.Assignments = self.Assignments
            let initialAmt = HTMLCodeFromGradeClick.components(separatedBy: assignmentName).count - 1
            importantUtils.CreateLoadingView(view: (UIApplication.topViewController()?.view)!, message: "Getting more detail...")
            
            AttemptToDisplayDetailedAssignment(assignmentName, initialAmt, vc)
        }else{
            let vc : ModernDetailedAssignmentViewController = mainStoryboard.instantiateViewController(withIdentifier: "ModernDetailedAssignmentViewer") as! ModernDetailedAssignmentViewController
            InformationHolder.SkywardWebsite = webView
            vc.AssignmentNameString = assignmentName
            vc.Class = self.Class
            vc.Term = self.Term
            let initialAmt = HTMLCodeFromGradeClick.components(separatedBy: assignmentName).count - 1
            importantUtils.CreateLoadingView(view: (UIApplication.topViewController()?.view)!, message: "Getting more detail...")
            
            AttemptToDisplayDetailedAssignment(assignmentName, initialAmt,DetailedAssignmentViewController(),vc)
        }
            }
    func AttemptToClick(assignmentName: String){
        let finalString = assignmentName.replacingOccurrences(of: "'", with: "\\'")
        webView.evaluateJavaScript("Array.from(document.querySelectorAll('a')).find(el => el.textContent === '" + finalString + "').click();", completionHandler: nil)
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

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}
