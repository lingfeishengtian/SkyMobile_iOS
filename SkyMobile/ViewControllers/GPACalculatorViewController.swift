//
//  GPACalculatorViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/19/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import UIKit
import WebKit

class GPACalculatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var webView = WKWebView();
    var Courses: [Course] = []
    var importantUtils = ImportantUtils()
    
    @IBOutlet weak var S1Average: UILabel!
    @IBOutlet weak var S2Average: UILabel!
    @IBOutlet weak var FinalGPA: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var GPACalculatorTitle: UILabel!
    @IBOutlet weak var tableViewHighConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame.origin = CGPoint(x: 0, y: FinalGPA.frame.maxY + 10)
        tableView.frame.size = CGSize(width: self.view.frame.width, height: 100)
        
        webView.frame = CGRect(x: 0, y: 250, width: 0, height: 0)
        GPACalculatorTitle.sizeToFit()
        tableView.delegate = self
        tableView.dataSource = self
        SetFinalAverageValues()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CourseInfo
        let Class = Courses[indexPath.row].Class
        
        cell.Course.text = Class
        if !importantUtils.isKeyPresentInUserDefaults(key: Class+"Level"){
            UserDefaults.standard.set(importantUtils.GuessClassLevel(className: Class), forKey: Class + "Level")
        }
        cell.APInfo.text = UserDefaults.standard.object(forKey: Class+"Level") as? String
        cell.Course.sizeToFit()
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        tableViewHighConstraint.constant = tableView.contentSize.height
        
        cell.APInfo.frame.origin = CGPoint(x: self.view.frame.maxX-80, y: cell.APInfo.frame.minY)
        return cell
    }
    
    func SetFinalAverageValues() {
        let S1AverageInt = String(Double(round(1000*reloadGPAValues(term: "S1"))/1000))
        let S2AverageInt = String(Double(round(1000*reloadGPAValues(term: "S2"))/1000))
        S1Average.text = S1AverageInt
        S2Average.text = S2AverageInt
        if S1AverageInt == "nan"{
            S1Average.text = "Not Applicable"
        }
        if S2AverageInt == "nan"{
            S2Average.text = "Not Applicable"
            FinalGPA.text = String(S1AverageInt)
        }else{
            FinalGPA.text = String(reloadGPAValues(term: "FIN"))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Class = Courses[indexPath.row].Class
        let CurrentLevel = UserDefaults.standard.object(forKey: Class+"Level") as? String
        var newLevel = " "
        if CurrentLevel == "Regular"{
            newLevel = "PreAP"
        }else if CurrentLevel == "PreAP"{
            newLevel = "AP"
        }else if CurrentLevel == "AP"{
            newLevel = "N/A"
        }else{
            newLevel = "Regular"
        }
        
        UserDefaults.standard.set(newLevel, forKey: Class + "Level")
        self.tableView.reloadData()
        SetFinalAverageValues()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func reloadGPAValues(term: String) -> Double{
        var NewClassAverage: Int = 0
        var FinalCount = 0
        for course in Courses{
            let className = course.Class
            let level = (UserDefaults.standard.object(forKey: className+"Level") as? String)
            if Int(course.Grades.Grades[term]!) != -1000{
            if level == "PreAP"{
                NewClassAverage += Int(course.Grades.Grades[term]!)! + 5
            }else if level == "AP"{
                NewClassAverage += Int(course.Grades.Grades[term]!)! + 10
            }else if level == "N/A"{
                FinalCount -= 1
            }else{
                NewClassAverage += Int(course.Grades.Grades[term]!)!
            }
                FinalCount += 1
        }
        }
        return Double(NewClassAverage)/Double(FinalCount)
    }
    
    @IBAction func goBack(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : FinalGradeDisplay = mainStoryboard.instantiateViewController(withIdentifier: "FinalGradeDisplay") as! FinalGradeDisplay
        vc.webView = self.webView;
        vc.Courses = Courses
        self.present(vc, animated: true, completion: nil)
    }
}

class CourseInfo: UITableViewCell{
    @IBOutlet weak var Course: UILabel!
    @IBOutlet weak var APInfo: UILabel!
}
