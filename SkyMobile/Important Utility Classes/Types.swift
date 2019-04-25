//
//  Types.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/10/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import WebKit

struct ClassGrades: Hashable{
    var ClassName: String
    
    var Grades: [String: String] =
    ["PR1":"-1000",
     "PR2":"-1000",
     "T1": "-1000",
     "PR3":"-1000",
     "PR4":"-1000",
     "T2":"-1000",
     "SE1":"-1000",
     "S1":"-1000",
     "PR5":"-1000",
     "PR6":"-1000",
     "T3":"-1000",
     "PR7":"-1000",
     "PR8":"-1000",
     "T4":"-1000",
     "SE2":"-1000",
     "S2":"-1000",
     "FIN":"-1000"]
    
    var hashValue: Int {
        return ClassName.hashValue
    }
    
    init(className: String) {
        ClassName = className
    }
}

func ==(lhs: ClassGrades, rhs: ClassGrades) -> Bool {
    return lhs.ClassName == rhs.ClassName
}

struct Course: Hashable {
    var Period: Int
    var Class: String
    var Teacher: String
    var Grades: ClassGrades
    var CourseCreditWorth = 1.0
    
    var hashValue: Int {
        return Class.hashValue
    }
    
    init(period: Int, classDesc: String, teacher: String, courseWorth: Double) {
        Period = period
        Class = classDesc
        Teacher = teacher
        Grades = ClassGrades(className: classDesc)
        CourseCreditWorth = courseWorth
    }
    init(period: Int, classDesc: String, teacher: String){
        Period = period
        Class = classDesc
        Teacher = teacher
        Grades = ClassGrades(className: classDesc)
    }
}

func ==(lhs: Course, rhs: Course) -> Bool {
    return lhs.Class == rhs.Class
}

struct AssignmentGrades: Hashable{
    var Class: String
    var DailyGrades:[Assignment] = []
    var MajorGrades:[Assignment] = []
    
    var hashValue: Int {
        return Class.hashValue
    }
    
    init(classDesc: String) {
        Class = classDesc
    }
}

func ==(lhs: AssignmentGrades, rhs: AssignmentGrades) -> Bool {
    return lhs.Class == rhs.Class
}

struct Assignment: Hashable{
    var Class: String
    var AssignmentName: String
    var Grade: Double
    var isEditableByUserInteraction: Bool = false
    
    var hashValue: Int {
        return Class.hashValue
    }
    
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
    
    init(nick: String, user: String, pass: String) {
        NickName = nick
        Username = user
        Password = pass
    }
    
    required init(coder decoder: NSCoder) {
        self.NickName = decoder.decodeObject(forKey: "nick") as! String
        self.Username = decoder.decodeObject(forKey: "user") as! String
        self.Password = decoder.decodeObject(forKey: "pass") as! String
    }
    func encode(with code: NSCoder){
        code.encode(NickName, forKey: "nick")
        code.encode(Username, forKey: "user")
        code.encode(Password, forKey: "pass")
    }
}

struct InformationHolder{
    static var SkywardWebsite: WKWebView = WKWebView()
    static var Courses: [Course] = []
    static var AvailableTerms:[String] = []
    static var WebsiteStatus = WebsitePage.Login;
    static var GlobalPreferences = Preferences()
    static var isModified = false
    static var CoursesBackup: [Course] = []
}

enum WebsitePage {
    case Login
    case Home
    case Gradebook
    case AcademicHistory
}

class LegacyGrade{
    var Courses: [Course] = []
    var Grade: String = ""
    
    init(sectionName: String,courses: [Course]) {
        Courses = courses
        Grade = sectionName
    }
}

class Preferences: NSObject, NSCoding{
    var AutoLoginMethodDoesStoreAllAvailableAccounts = true
    var ModernUI = true //Currently being implemented
    var BiometricEnabled = false
    
    init(loginMethodStore: Bool = true, modern: Bool = true, biometricEnacted: Bool = false){
        AutoLoginMethodDoesStoreAllAvailableAccounts = loginMethodStore
        ModernUI = modern
        BiometricEnabled = biometricEnacted
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let foundAutoLoginMethodDoesStoreAllAvailableAccounts = aDecoder.decodeBool(forKey: "AutoLoginMethodDoesStoreAllAvailableAccounts")
        let foundModernUI = aDecoder.decodeBool(forKey: "ModernUI")
        let foundBiometricOption = aDecoder.decodeBool(forKey: "BiometricSecurity")
        self.init(loginMethodStore: foundAutoLoginMethodDoesStoreAllAvailableAccounts, modern: foundModernUI, biometricEnacted: foundBiometricOption)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(AutoLoginMethodDoesStoreAllAvailableAccounts,forKey: "AutoLoginMethodDoesStoreAllAvailableAccounts")
        aCoder.encode(ModernUI, forKey: "ModernUI")
        aCoder.encode(BiometricEnabled, forKey: "BiometricSecurity")
    }
}

struct District{
    var DistrictName: String
    var DistrictLink: URL
    var GPACalculatorSupportType: GPACalculatorSupport
    
    init(name: String, URLLink: URL, gpaSupportType: GPACalculatorSupport) {
        DistrictName = name
        DistrictLink = URLLink
        GPACalculatorSupportType = gpaSupportType
    }
}

enum GPACalculatorSupport{
    case HundredPoint
    case FourPoint
    case NoSupport
}
