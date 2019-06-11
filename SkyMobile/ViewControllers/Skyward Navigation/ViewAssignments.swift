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

class ViewAssignments: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var webView: WKWebView = WKWebView()
    var Term = "PR1"
    var Class = "NIL"
    var Grade = ""
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    let importantUtils = ImportantUtils()
    var Assignments = AssignmentBlock()
    var DailyGrade = "-1000"
    var MajorGrade = "-1000"
    var isEditingTableView = false
    var index = -1
    var didPressEditing: Bool = false
    
    @IBOutlet weak var FinalGrade: UILabel!
    @IBOutlet weak var navView: UINavigationItem!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var GradeTableView: UITableView!
    
    func SetValuesOfGradeTableView() {
        if Assignments.AllAssignmentSections.isEmpty{
            importantUtils.CreateLoadingView(view: self.view, message: "Trying to view assignment grades...")
        }else{
            self.importantUtils.DestroyLoadingView(views: self.view)
        }
        
            //Assignments = GetMajorAndDailyGrades(htmlCode: HTMLCodeFromGradeClick, term: Term, Class: Class)
        FinalGrade.text = Grade
        
        GradeTableView.delegate = self
        GradeTableView.dataSource = self
        
        GradeTableView.reloadData()
    }
    
    @IBAction func AddAssignment(_ sender: Any) {
        let MockAssignment = Assignment(classDesc: Class, assignments: "Mock Assignment", grade: 100.0)
        self.Assignments.placeAssignmentInLastMainAvailable(assignment: MockAssignment)
        
        GradeTableView.isEditing = true
        self.RecalculateHeaders()
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
        if PreferenceLoader.findPref(prefID: "modernUI"){
            let Warn = UIAlertController(title: "Warning", message: "Saving to courses will disable some features until you reset to default. Saving to courses allows for your GPA to be recalculated.", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Do it", style: .default, handler: { alert in
                InformationHolder.isModified = true
                let DoubleGradeValue = (Double(self.FinalGrade.text!)!)
                let Rounded = round(DoubleGradeValue)
                InformationHolder.Courses[self.index].termGrades[self.Term] = String(Int(Rounded))
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
        if PreferenceLoader.findPref(prefID: "modernUI"){
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "ModernUITableSelection") as! ModernUITabController
            self.present(vc, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
            let vc : ProgressReportAverages = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! ProgressReportAverages
            self.present(vc, animated: true, completion: nil)
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Assignments.AllAssignmentSections.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Assignments.AllAssignmentSections[section].assignmentList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderCells
        headerCell.Grades.text = Assignments.AllAssignmentSections[section].grade
        headerCell.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        headerCell.GradeSectionDesc.text = Assignments.AllAssignmentSections[section].name
        
        if let weight = Assignments.AllAssignmentSections[section].weightIfApplicable{
            headerCell.weightLabel.text = "weighted at \(weight)"
        }else{
            //TODO: MINOR SECTIONS
        }
        headerCell.sizeToFit()
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssignmentViewCells
        var AssignmentTMP = Assignment(classDesc: "", assignments: "", grade: -1000)
        var grade = "-1000"
        AssignmentTMP = Assignments.AllAssignmentSections[indexPath.section].assignmentList[indexPath.row]
        cell.lblAssignment.text = String(AssignmentTMP.AssignmentName)
        grade = String(AssignmentTMP.Grade)
        if grade.contains("-1000"){
            grade = " "
        }
        cell.lblGrade.text = grade
        if didPressEditing{
            cell.lblGrade.textColor = UIColor.black
        }else{
            if let gradeAsDouble = Double(grade){
                cell.lblGrade.textColor = importantUtils.DetermineColor(from: Double(gradeAsDouble))
            }
        }
        
        if isEditingTableView{
            cell.lblGrade.isHidden = true
            cell.GradeInputTextInput.isHidden = false
            cell.GradeInputTextInput.text = grade
        }else{
            cell.lblGrade.isHidden = false
            cell.GradeInputTextInput.isHidden = true
        }
        
        cell.frame.size = CGSize(width: cell.frame.width, height: 44)
        //tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            Assignments.AllAssignmentSections[indexPath.section].assignmentList.remove(at: indexPath.row)
        }
        self.didPressEditing = true
        GradeTableView.reloadData()
        self.RecalculateHeaders()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let source = Assignments.AllAssignmentSections[sourceIndexPath.section].assignmentList.remove(at: sourceIndexPath.row)
        Assignments.AllAssignmentSections[destinationIndexPath.section].assignmentList.insert(source, at: destinationIndexPath.row)
        GradeTableView.reloadData()
        self.RecalculateHeaders()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Array.from(document.querySelectorAll('a'))
        //.find(el => el.textContent === 'Q Map');
        if Assignments.AllAssignmentSections[indexPath.section].assignmentList[indexPath.row].AssignmentTag == 0{
            var assignmentName = ""
            assignmentName = Assignments.AllAssignmentSections[indexPath.section].assignmentList[indexPath.row].AssignmentName
            
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
    }
    func AttemptToClick(assignmentName: String){
        let finalString = assignmentName.replacingOccurrences(of: "'", with: "\\'")
        webView.evaluateJavaScript("Array.from(document.querySelectorAll('a')).find(el => el.textContent === '" + finalString + "').click();", completionHandler: nil)
    }
    
    func RecalculateHeaders(){
        var averageOfMainSections = 0.0
        for SectionNum in 0...Assignments.AllAssignmentSections.count-1{
            var finalAverage = 0.0
            var counted = 0
            for assignment in Assignments.AllAssignmentSections[SectionNum].assignmentList{
                if assignment.Grade != -1000.0{
                    finalAverage += assignment.Grade
                    counted += 1
                }
            }
            finalAverage /= Double(counted)
            averageOfMainSections += finalAverage
            Assignments.AllAssignmentSections[SectionNum].grade = String(finalAverage)
            if counted == 0{
                Assignments.AllAssignmentSections[SectionNum].grade = "No grade..."
            }
        }
        averageOfMainSections /= Double(Assignments.AllAssignmentSections.count)
        
        FinalGrade.text = String(averageOfMainSections)
    }
}

class AssignmentViewCells: UITableViewCell{
    @IBOutlet weak var lblAssignment: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var GradeInputTextInput: UITextField!
    
    var Section = 0
    var Row = 0
    var isEditable = false
    
    @IBAction func GradeInputChanged(_ sender: UITextField) {
        let ViewController = UIApplication.topViewController() as? ViewAssignments
        var NumTmpp = sender.text ?? ""
        let TableView = sender.superview?.superview?.superview as! UITableView
        if let _ = NumTmpp.firstIndex(of: "."){
            NumTmpp = String(NumTmpp.split(separator: ".").first ?? "")
        }
        if let cell = sender.superview?.superview as? AssignmentViewCells{
            let indexPath = TableView.indexPath(for: cell)
            NumTmpp = NumTmpp.trimmingCharacters(in: .whitespaces)
            ViewController?.Assignments.AllAssignmentSections[(indexPath?.section)!].assignmentList[(indexPath?.row)!].Grade = Double(Int(NumTmpp) ?? -1000)
            ViewController?.RecalculateHeaders()
            TableView.reloadData()
        }
    }
}

class HeaderCells: UITableViewCell{
    @IBOutlet weak var GradeSectionDesc: UILabel!
    @IBOutlet weak var Grades: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
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
