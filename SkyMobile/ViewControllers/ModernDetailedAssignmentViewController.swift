//
//  ModernDetailedAssignmentViewController.swift
//  SkyMobile
//
//  Created by Hunter Han on 3/14/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Kanna
import UIKit

class ModernDetailedAssignmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var DetailedInfoTableView: UITableView!
    @IBOutlet weak var AssignementName: UINavigationItem!
    
    var AssignmentNameString = ""
    var html = ""
    var Term = "PR1"
    var Class = "Nil"
    var FinalValues: [InfoDetailType] = []
    var importantUtils = ImportantUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailedInfoTableView.delegate = self
        DetailedInfoTableView.dataSource = self
        
        FinalValues = ParseAndReturnValues()
        AssignementName.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goBack(_:)))
        AssignementName.title = AssignmentNameString
        DetailedInfoTableView.backgroundColor = .clear
        DetailedInfoTableView.separatorColor = .clear
    }
    
    func ParseAndReturnValues() -> [InfoDetailType]{
        var FinalValues: [InfoDetailType] = []
        
        if let document = try? HTML(html: html, encoding: .utf8){
            let gradeElements = document.css("#dLog_showAssignmentInfo")
            
            for tableElem in (gradeElements.first?.css("table"))!{
                for trElem in tableElem.css("tr"){
                    let tdElements = trElem.css("td")
                    if tdElements.count == 1{
                        let NewAssignmentDetailCell = InfoDetailType()
//                        NewAssignmentDetailCell.Description = UILabel(frame: CGRect(x: 5, y: 0, width: self.view.frame.size.width - 20, height: 44))
//                        NewAssignmentDetailCell.ExpandedDetail = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//                        NewAssignmentDetailCell.ExpandedDetail.isHidden = true
//                        NewAssignmentDetailCell.Description.numberOfLines = 10
//                        NewAssignmentDetailCell.Description.lineBreakMode = .byWordWrapping
//                        NewAssignmentDetailCell.Description.text = tdElements.first?.text
//                        NewAssignmentDetailCell.Description.sizeThatFits(CGSize(width: self.view.frame.size.width - 10, height: 999))
                        NewAssignmentDetailCell.ExpandedDetail = (tdElements.first?.text)!
                        NewAssignmentDetailCell.count = 1
                        FinalValues.append(NewAssignmentDetailCell)
                    }else{
                        for index in stride(from: 0, to: tdElements.count, by: 2){
                            let NewAssignmentDetailCell = InfoDetailType()
                            NewAssignmentDetailCell.Description = tdElements[index].text!
                            NewAssignmentDetailCell.ExpandedDetail = tdElements[index+1].text!
                            NewAssignmentDetailCell.count = 2
                            FinalValues.append(NewAssignmentDetailCell)
                        }
                    }
                }
            }
            
            //MARK: Attempt to get any comments that are available
            if gradeElements.first?.css("a[onclick]").count ?? 0 >= 2{
                var elem = gradeElements.first?.css("a[onclick]")[1].parent!.toHTML ?? ""
                if !elem.isEmpty{
                    elem = elem.components(separatedBy: "\"html\": \"").last?.components(separatedBy: "\", \"autoHide\"").first ?? ""
                    print(elem)
                    let NewAssignmentDetailCell = InfoDetailType()
                    NewAssignmentDetailCell.Description = "Comments:"
                    NewAssignmentDetailCell.ExpandedDetail = elem
                    FinalValues.append(NewAssignmentDetailCell)
                }
            }
        }
        return FinalValues
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FinalValues.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! AssignmentInfoDetailedCell
        cell.selectionStyle = .none
        
        if indexPath.row % 2 == 0{
            let tdElements = FinalValues[indexPath.row/2]
            
            if tdElements.count == 1{
                cell.ExpandedDetail.isHidden = true
                cell.ExpandedDetail.isEnabled = false
                cell.Description.numberOfLines = 50
                cell.Description.lineBreakMode = .byWordWrapping
                cell.Description.text = tdElements.ExpandedDetail
                cell.Description.frame = CGRect(x: 10, y: 11, width: cell.frame.width - 20, height: cell.frame.size.height)
                cell.Description.sizeToFit()
            }else{
                cell.ExpandedDetail.isHidden = false
                cell.ExpandedDetail.isEnabled = true
                cell.Description.frame = CGRect(x: 10, y: 11, width: 0, height: 44)
                cell.Description.text = tdElements.Description
                cell.Description.sizeToFit()
                cell.ExpandedDetail.text = tdElements.ExpandedDetail
                cell.ExpandedDetail.frame = CGRect(x: cell.Description.frame.maxX + 5, y: 11, width: cell.frame.size.width - (cell.Description.frame.width + 25), height: 21)
                cell.ExpandedDetail.textColor = UIColor.white
                cell.Description.sizeToFit()
            }
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.init(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
            cell.Description.textColor = UIColor.white
        }else{
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0{
            if FinalValues[indexPath.row/2].count == 1{
                let width = self.DetailedInfoTableView.frame.size.width
                let label = UILabel(frame: CGRect(x: 10, y: 11, width: Int(width - 20), height: 44))
                label.text = FinalValues[indexPath.row/2].ExpandedDetail
                label.numberOfLines = 50
                label.sizeToFit()
                return label.frame.size.height + 22
            }else{
                return 44
            }
        }else{
            return 3
        }
        
    }
    
    @objc func goBack(_ sender: Any) {
        importantUtils.CreateLoadingView(view: self.view, message: "Going back...")
        let mainStoryboard = UIStoryboard(name: "FinalGradeDisplay", bundle: Bundle.main)
        let vc : ViewAssignments = mainStoryboard.instantiateViewController(withIdentifier: "ViewAssignments") as! ViewAssignments
        vc.HTMLCodeFromGradeClick = html
        vc.Class = self.Class
        vc.Term = self.Term
        self.present(vc, animated: true, completion: nil)
    }
}

class InfoDetailType{
    var Description = ""
    var ExpandedDetail = ""
    var count = 0
}

class AssignmentInfoDetailedCell: UITableViewCell {
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var ExpandedDetail: UILabel!
}
