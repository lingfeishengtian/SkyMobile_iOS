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

class ViewAssignments: UIViewController {
    var webView: WKWebView = WKWebView()
    var Term = "PR1"
    var Class = "Nil"
    var HTMLCodeFromGradeClick = " "
    var Courses: [Course] = []
    
    @IBOutlet weak var navView: UINavigationItem!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navView.hidesBackButton = false
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack(_:)))
        self.navView.leftBarButtonItem = backButton
        SetLabelText(term: Term, Class: Class)
        // Do any additional setup after loading the view.
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
    
    func GetMajorAndDailyGrades(htmlCode: String, term: String, Class: String){
        let cssSelectorCode = "#gradeInfoDialog"
        do{
            //HINT: document.querySelector("#gradeInfoDialog").querySelectorAll("tbody")[2].querySelectorAll("tr.sf_Section,.odd,.even")
            let document = try SwiftSoup.parse(htmlCode)
            let elements: Elements = try document.select(cssSelectorCode)
            for element in elements{
                
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
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
