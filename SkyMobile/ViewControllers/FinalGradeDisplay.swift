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

class FinalGradeDisplay: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var Classes:[String] = []
    var GradeBookScrapedData: [String:String] = [:]
    var ClassWithDesc: [Course] = []
    var ClassColorsDependingOnGrade: [UIColor] = []
    
    var Courses: [Course] = []
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        ClassWithDesc = SplitClassDescription(classArr: Classes, gradebook: GradeBookScrapedData)
        //ClassColorsDependingOnGrade = DetermineColor(fromClassGrades: ClassWithDesc)
        table.delegate = self
        table.dataSource = self
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
        
//        let grade = ClassWithDesc[indexPath.row].Grade
//        if(grade == -10000){
//            cell.lblGrade.text = " "
//        }else{
//            cell.lblGrade.text = String(grade)
//        }
        
        //Add cell color!!!!
//        let currentColor = ClassColorsDependingOnGrade[indexPath.row]
//        cell.lblGrade.backgroundColor = currentColor
//        cell.lblClassDesc.backgroundColor = currentColor
//        cell.lblPeriod.backgroundColor = currentColor
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TEST: " + Courses[indexPath.row].Class)
    }
    
    @available(*, deprecated, message: "SplittingClassDescription will be done as a utility")
    func SplitClassDescription(classArr: [String], gradebook:[String:String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            let current = Course(
                period: Int(Class.components(separatedBy: "Prd ")[1].components(separatedBy: " / ")[0])!,
                classDesc: Class.components(separatedBy: "Prd ")[0],
                teacher: Class.components(separatedBy: "Prd ")[1].components(separatedBy: " / ")[1])
            //NOTE GRADE WAS REMOVED
//            if let grade = gradebook[Class]{
//                current.Grade = Int(grade.components(separatedBy: " ")[0])!
//            }else{
//                current.Grade = -10000
//            }
            finalPeriod.append(current)
        }
        
        //        for testCase in finalPeriod{
        //            print("Class: " + testCase.Class + "\nPeriod: " + String(testCase.Period) + "\nTeacher: " + testCase.Teacher)
        //        }
        return finalPeriod
    }
    
    //TODO: UPDATE FUNCTION CLEAN UP FUNCTION
    func DetermineColor(fromClassGrades classes: [ClassDesc]) -> [UIColor] {
        var finalColors: [UIColor] = []
        var high = -9999;
        var low = 9999;
        
        var average = 0;
        var amtOfGrades = 0;
        for Grade in classes{
            if Grade.Grade != -10000{
                average += Grade.Grade
                amtOfGrades += 1
                if max(high, Grade.Grade) == Grade.Grade{
                    high = Grade.Grade
                }
                if min(low, Grade.Grade) == Grade.Grade{
                    low = Grade.Grade
                }
            }
        }
        let range = high - low
        
        print(high)
        print(low)
        print(range)
        
        for Grade in classes{
             if Grade.Grade != -10000{
            let greenVal = CGFloat(Double(Grade.Grade)/Double(100) )
                let red = CGFloat((Double(Grade.Grade-(low-1))/Double(high)) * 10)
            print((greenVal).description + "  " + red.description)
                finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
             }else{
                finalColors.append(.blue)
            }
        }
        
        return finalColors
    }
    
    func ScrapeAssignments(fromCurrentClasses classes: [ClassDesc], atClass wantedClass:ClassDesc, andWebView webView: WKWebView){
        var javascriptCode = """
                            function getElements(attrib) {
                            return document.querySelectorAll('[' + attrib + ']');
                            }
                            """
        var javascriptCallFunc = "getElements('data-iseoc')["
    }
}

class GradeTableViewCell: UITableViewCell{
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblClassDesc: UILabel!
}
