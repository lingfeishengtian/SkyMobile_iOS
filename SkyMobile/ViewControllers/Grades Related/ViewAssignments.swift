//
//  ViewAssignments.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/13/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
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
    var index = -1
    
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
        GradeTableViewController.Grade = Grade
        
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
        GradeTableViewController.reloadAverageValues()
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
        GradeTableView.allowsSelectionDuringEditing = false
        
        navView.hidesBackButton = false
        
        AttemptToGetHTML()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func SaveCoursesToMain(_ sender: Any) {
        if InformationHolder.GlobalPreferences.ModernUI{
            let Warn = UIAlertController(title: "Warning", message: "Saving to courses will disable some features until you reset to default. Saving to courses allows for your GPA to be recalculated.", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Do it", style: .default, handler: { alert in
                InformationHolder.isModified = true
                let DoubleGradeValue = (Double(self.FinalGrade.text!)!)
                let Rounded = round(DoubleGradeValue)
                InformationHolder.Courses[self.index].Grades.Grades[self.Term] = String(Int(Rounded))
            })
            let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            Warn.addAction(Cancel)
            Warn.addAction(Ok)
            self.present(Warn, animated: true, completion: nil)
        }else{
            importantUtils.DisplayErrorMessage(message: "This is a Modern UI only function.")
        }
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
        GradeTableViewController.didPressEditing = true
        GradeTableViewController.isEditingTableView = isEditingTableView
        GradeTableView.isEditing = isEditingTableView
        GradeTableView.reloadData()
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
    @IBOutlet weak var GradeInputTextInput: UITextField!
    
    var Section = 0
    var Row = 0
    var isEditable = false
    var ViewController: AssignmentViewTable? = nil
    
    @IBAction func GradeInputChanged(_ sender: UITextField) {
        var NumTmpp = sender.text ?? ""
        let TableView = sender.superview?.superview?.superview as! UITableView
        if let _ = NumTmpp.firstIndex(of: "."){
            NumTmpp = String(NumTmpp.split(separator: ".").first ?? "")
        }
        if let cell = sender.superview?.superview as? AssignmentViewCells{
            let row = TableView.indexPath(for: cell)?.row
            NumTmpp = NumTmpp.trimmingCharacters(in: .whitespaces)
            if TableView.indexPath(for: cell)?.section == 0{
                ViewController?.DailyGrades[row!].Grade = Double(NumTmpp) ?? -1000
            }else{
                ViewController?.MajorGrades[row!].Grade = Double(NumTmpp) ?? -1000
            }
            ViewController?.reloadAverageValues()
        }
    }
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
    var Grade = ""
    
    func reloadAverageValues(){
        let AssignmentAverages = AddUpValues(grades: DailyGrades)
        let MajorGradeAverages = AddUpValues(grades: MajorGrades)
        headerDaily = String(AssignmentAverages)
        headerMajor = String(MajorGradeAverages)
        grade.text = String((AssignmentAverages + MajorGradeAverages)/2.0)
        if AssignmentAverages == -1000.0{
            headerDaily = "No Grade"
            grade.text = String(MajorGradeAverages)
        }
        if MajorGradeAverages == -1000.0{
            headerMajor = "No Grade"
            grade.text = String(AssignmentAverages)
        }
        if AssignmentAverages == -1000.0 && MajorGradeAverages == -1000.0{
            grade.text = "No Grade"
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
            ShouldIndex += DailyGrades.count
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
        
        if didPressEditing{
            cell.lblGrade.isHidden = true
            cell.GradeInputTextInput.isHidden = false
            cell.GradeInputTextInput.text = grade
            cell.ViewController = self
        }else{
            cell.lblGrade.isHidden = false
            cell.GradeInputTextInput.isHidden = true
        }
        
//        if isEditingTableView && HasTextBox{
//            var TextViewFrame = (cell.viewWithTag(212) as? UITextField)?.frame
//            var AssignmentNameViewFrame = (cell.lblAssignment.frame)
//            TextViewFrame = CGRect(x: (TextViewFrame?.minX)! - 30, y: (TextViewFrame?.minY)!, width: (TextViewFrame?.width)!, height: (TextViewFrame?.height)!)
//            AssignmentNameViewFrame.size = CGSize(width: AssignmentNameViewFrame.width - 30, height: AssignmentNameViewFrame.height)
//        }else{
//            var TextViewFrame = (cell.viewWithTag(212) as? UITextField)?.frame
//            var AssignmentNameViewFrame = (cell.lblAssignment.frame)
//            TextViewFrame = CGRect(x: cell.frame.width - 55 , y: cell.lblAssignment.frame.minY, width: 50, height: 23)
//            AssignmentNameViewFrame = CGRect(x: 15, y: 10, width: cell.frame.width - CGFloat(75), height: 23)
//        }
        
        cell.frame.size = CGSize(width: cell.frame.width, height: 44)
        //tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if indexPath.section == 0{
                DailyGrades.remove(at: indexPath.row)
            }else{
                MajorGrades.remove(at: indexPath.row)
            }
        }
        self.didPressEditing = true
        reloadAverageValues()
        TableView.reloadData()
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
    
    fileprivate func AttemptToDisplayDetailedAssignment(_ assignmentName: String, _ initialAmt: Int, _ vc2: ModernDetailedAssignmentViewController = ModernDetailedAssignmentViewController()) {
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
                if Attempts >= 41{
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
                            
                            self.webView.evaluateJavaScript("document.querySelector(\"#dLog_showAssignmentInfo\").outerHTML;"){ (result, error) in
                                if error == nil {
                                    let resultFinalString = result as! String
                                    print("Initial, ", initialAmt)
                                    print(resultFinalString.components(separatedBy: assignmentName).count - 1)
                                    vc2.html = resultFinalString
                                    
                                    UIApplication.topViewController()?.present(vc2, animated: true, completion: nil)
                                }
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
        }else{
            assignmentName = String(MajorGrades[indexPath.row].AssignmentName)
        }
        
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        
            let vc : ModernDetailedAssignmentViewController = mainStoryboard.instantiateViewController(withIdentifier: "ModernDetailedAssignmentViewer") as! ModernDetailedAssignmentViewController
            InformationHolder.SkywardWebsite = webView
            vc.AssignmentNameString = assignmentName
            vc.Class = self.Class
            vc.Term = self.Term
            vc.Grade = self.Grade
            let initialAmt = HTMLCodeFromGradeClick.components(separatedBy: assignmentName).count - 1
            importantUtils.CreateLoadingView(view: (UIApplication.topViewController()?.view)!, message: "Getting more detail...")
            
            AttemptToDisplayDetailedAssignment(assignmentName, initialAmt, vc)
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