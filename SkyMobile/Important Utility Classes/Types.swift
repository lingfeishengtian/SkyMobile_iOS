//
//  Types.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/10/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation

struct ClassGrades: Hashable {
    var CurrentClass:Course
    
    var hashValue: Int {
        return CurrentClass.Class.hashValue
    }
    
    init(theClassForGrades classGiven:Course) {
       CurrentClass = classGiven
    }
}

func ==(lhs: ClassGrades, rhs: ClassGrades) -> Bool {
    return lhs.CurrentClass.Class == rhs.CurrentClass.Class
}

struct Course: Hashable {
    var Period: Int
    var Class: String
    var Teacher: String
    
    var hashValue: Int {
        return Class.hashValue
    }
    
    init(period: Int, classDesc: String, teacher: String) {
        Period = period
        Class = classDesc
        Teacher = teacher
    }
}

func ==(lhs: Course, rhs: Course) -> Bool {
    return lhs.Class == rhs.Class
}



@available(*, deprecated, message: "Use Course instead, this was done to give support for desktop website")
struct ClassDesc: Hashable {
    var Period: Int
    var Class: String
    var Teacher: String
    var Grade: Int = 0
    
    var hashValue: Int {
        return Class.hashValue
    }
    
    init(period: Int, classDesc: String, teacher: String) {
        Period = period
        Class = classDesc
        Teacher = teacher
    }
}

func ==(lhs: ClassDesc, rhs: ClassDesc) -> Bool {
    return lhs.Class == rhs.Class
}
