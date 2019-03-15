//
//  DetailedAssignmentViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/18/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//
import Foundation
import UIKit
import SwiftSoup
import WebKit

class DetailedAssignmentViewController: UIViewController {
    @IBOutlet weak var AssignmentName: UINavigationItem!
    @IBOutlet weak var AssignmentInfo: UILabel!
    @IBOutlet weak var AssignDate: UILabel!
    @IBOutlet weak var DueDate: UILabel!
    @IBOutlet weak var MaxPoints: UILabel!
    @IBOutlet weak var Weight: UILabel!
    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var PointsEarned: UILabel!
    @IBOutlet weak var ClassAverage: UILabel!
    @IBOutlet weak var ClassMedian: UILabel!
    @IBOutlet weak var ClassHigh: UILabel!
    @IBOutlet weak var ClassLow: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var Comments: UILabel!
    @IBOutlet weak var CommentScrollView: UIScrollView!
    
    var Term = "PR1"
    var Class = "Nil"
    var html = " "
    var Courses: [Course] = []
    var AssignmentNameString = ""
    var Assignments = AssignmentGrades(classDesc: "NIL")
    var importantUtils = ImportantUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parseHTMLAndSetValues(html: self.html)
        Courses = InformationHolder.Courses
        
        scrollView.frame.size = CGSize(width: self.view.frame.width, height: scrollView.frame.height)
        AssignmentName.hidesBackButton = false
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack(_:)))
        self.AssignmentName.leftBarButtonItem = backButton
        
        AssignmentName.title = AssignmentNameString
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: AssignmentInfo.frame.height + 10)
        self.CommentScrollView.contentSize = CGSize(width: self.view.frame.width, height: Comments.frame.height + 10)
    }
    
    @available(*, deprecated, message: "Still uses SwiftSoup")
    func parseHTMLAndSetValues(html: String){
        do{
            let document = try SwiftSoup.parse(html)
            let gradeElements: Elements = try document.select("#dLog_showAssignmentInfo")
            let tablesOfInfo: Elements = try gradeElements.eq(0).select(".sf_gridTableWrap")
            
            //dLog_showAssignmentInfo.querySelectorAll("a[onclick]")[1].outerHTML
            var elem: String = try gradeElements.eq(0).select("a[onclick]").eq(1).parents().eq(0).html()
            if !elem.isEmpty{
                print(elem)
                elem = elem.components(separatedBy: "html&quot;: &quot;").last?.components(separatedBy: "&quot;, &quot;autoHide&quot").first ?? ""
                print(elem)
                Comments.text = elem
                Comments.sizeToFit()
            }else{
                lblComment.isEnabled = false
                lblComment.isHidden = true
                Comments.isHidden = true
            }
            for table in tablesOfInfo{
                let infoElements: Elements = try table.select(".odd,.even")
                if tablesOfInfo.array().firstIndex(of: table) == 0{
                    AssignmentInfo.text = (try infoElements.eq(1).text())
                    AssignmentInfo.sizeToFit()
                }
                
                for element in infoElements{
                    var elemText = try element.text()
                    
                    //Delete when not testing
                    print(elemText)
                    
                    if elemText.contains(" Date Due: "){
                        DueDate.text = elemText.components(separatedBy: " Date Due: ")[1]
                        var AssignDateTemp = elemText.components(separatedBy: " Date Due: ")[0]
                        AssignDateTemp.removeFirst(13)
                        AssignDate.text = AssignDateTemp
                    }else if elemText.contains(" Weight: "){
                        elemText.removeFirst(12)
                        MaxPoints.text = elemText.components(separatedBy: " Weight: ")[0]
                        Weight.text = elemText.components(separatedBy: " Weight: ")[1]
                    }else if elemText.contains("Score: "){
                        elemText.removeFirst(7)
                        Score.text = elemText
                    }else if elemText.contains("Points Earned: "){
                        elemText.removeFirst(15)
                        PointsEarned.text = elemText
                    }else if elemText.contains("Average: "){
                        elemText.removeFirst(9)
                        ClassAverage.text = elemText.components(separatedBy: " Median: ")[0]
                        ClassMedian.text = elemText.components(separatedBy: " Median: ")[1]
                    }else if elemText.contains(" Low: "){
                        elemText.removeFirst(6)
                        ClassHigh.text = elemText.components(separatedBy: " Low: ")[0]
                        ClassLow.text = elemText.components(separatedBy: " Low: ")[1]
                    }
                }
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    @objc func goBack(_ sender: Any) {
        importantUtils.CreateLoadingView(view: self.view, message: "Going back...")
                let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
                let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
                vc.HTMLCodeFromGradeClick = html
                vc.Class = self.Class
                vc.Term = self.Term
                vc.Assignments = self.Assignments
                self.present(vc, animated: true, completion: nil)
    }
    
}
