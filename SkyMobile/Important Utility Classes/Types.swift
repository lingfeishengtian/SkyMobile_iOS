//
//  Types.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/10/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import WebKit

struct Course: Hashable {
    var Period: String
    var Class: String
    var Teacher: String
    var CourseCreditWorth = 1.0
    var termGrades: [String: String] = [:]
    
    init(period: String, classDesc: String, teacher: String, courseWorth: Double) {
        Period = period
        Class = classDesc
        Teacher = teacher
        CourseCreditWorth = courseWorth
    }
    init(period: String, classDesc: String, teacher: String){
        Period = period
        Class = classDesc
        Teacher = teacher
    }
}

func ==(lhs: Course, rhs: Course) -> Bool {
    return lhs.Class == rhs.Class
}

struct Assignment: Hashable{
    var Class: String
    var AssignmentName: String
    var Grade: Double
    var AssignmentTag = 0
    
    init(classDesc: String, assignments: String, grade: Double) {
        Class = classDesc
        AssignmentName = assignments
        Grade = grade
    }
}

func ==(lhs: Assignment, rhs: Assignment) -> Bool {
    return lhs.Class == rhs.Class
}

class Account: NSObject, NSCoding{
    var NickName: String
    var Username: String
    var Password: String
    var district = District(name: "FBISD", URLLink: URL(string: "https://skyward-fbprod.iscorp.com/scripts/wsisa.dll/WService=wsedufortbendtx/seplog01.w")!, gpaSupportType: GPACalculatorSupport.HundredPoint)
    
    init(nick: String, user: String, pass: String) {
        NickName = nick
        Username = user
        Password = pass
    }
    
    required init(coder decoder: NSCoder) {
        self.NickName = decoder.decodeObject(forKey: "nick") as! String
        self.Username = decoder.decodeObject(forKey: "user") as! String
        self.Password = decoder.decodeObject(forKey: "pass") as! String
        self.district = decoder.decodeObject(forKey: "dist") as! District
    }
    func encode(with code: NSCoder){
        code.encode(NickName, forKey: "nick")
        code.encode(Username, forKey: "user")
        code.encode(Password, forKey: "pass")
        code.encode(district, forKey: "dist")
    }
}

struct AssignmentBlock{
    var AllAssignmentSections : [MainAssignmentSection] = []
    
    mutating func placeAssignmentInLastMainAvailable(assignment: Assignment) {
        AllAssignmentSections[AllAssignmentSections.endIndex - 1].assignmentList.append(assignment)
    }
}

struct MainAssignmentSection {
    var name: String
    var weightIfApplicable : String?
    var minorSections:[MinorAssignmentSection] =  []
    var assignmentList: [Assignment] = []
    var grade: String?
    
    init(_ Name:String, _ weight: String?, _ Grade: String?) {
        name = Name
        weightIfApplicable = weight
        grade = Grade
    }
}

struct MinorAssignmentSection {
    var name: String
    var weight: String
    var grade: String
    
    init(_ Name:String, _ Weight: String, _ Grade: String) {
        name = Name
        weight = Weight
        grade = Grade
    }
}

struct InformationHolder{
    static var SkywardWebsite: WKWebView = WKWebView()
    static var Courses: [Course] = []
    static var AvailableTerms:[String] = []
    static var GlobalPreferences : [Preference] = []
    static var isModified = false
    static var CoursesBackup: [Course] = []
    static var isElementary = false
    static var isParentAccount = false
    static var childrenAccounts:[String] = []
}

class LegacyGrade{
    var Courses: [Course] = []
    var Grade: String = ""
    
    init(sectionName: String,courses: [Course]) {
        Courses = courses
        Grade = sectionName
    }
}

class District : NSObject, NSCoding{
    var DistrictName: String
    var DistrictLink: URL
    var GPACalculatorSupportType: GPACalculatorSupport = GPACalculatorSupport.NoSupport
    
    init(name: String, URLLink: URL, gpaSupportType: GPACalculatorSupport) {
        DistrictName = name
        DistrictLink = URLLink
        GPACalculatorSupportType = gpaSupportType
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.DistrictName = aDecoder.decodeObject(forKey: "dName") as! String
        self.DistrictLink = aDecoder.decodeObject(forKey: "dLink") as! URL
        self.GPACalculatorSupportType = GPACalculatorSupport(rawValue: aDecoder.decodeInteger(forKey: "dType")) ?? GPACalculatorSupport.NoSupport
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(DistrictName, forKey: "dName")
        aCoder.encode(DistrictLink, forKey: "dLink")
        aCoder.encode(GPACalculatorSupportType.rawValue, forKey: "dType")
    }
}

enum GPACalculatorSupport: Int{
    case HundredPoint
    case FourPoint
    case NoSupport
}

struct PreferenceParent: Decodable{
    var preferences: [Preference]
}

class Preference: NSObject, Decodable, NSCoding{
    var id: String
    var title: String
    var desc: String
    var defaultBool: Bool
    var editableOnLockscreen = true
    
    init(iid: String, ititle: String, idesc: String, iBoolL: Bool) {
        id = iid
        title = ititle
        desc = idesc
        defaultBool = iBoolL
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        self.title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.desc = aDecoder.decodeObject(forKey: "desc") as? String ?? ""
        self.defaultBool = aDecoder.decodeBool(forKey: "bool")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(defaultBool, forKey: "bool")
    }
}
