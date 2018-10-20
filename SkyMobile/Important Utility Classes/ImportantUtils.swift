//
//  ImportantUtils.swift
//  SkyMobile
//
//  Created by Hunter Han on 10/18/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import UIKit

class ImportantUtils {
    fileprivate func findMaxAndLowOf(_ finalGrades: [Double], _ high: inout Double, _ low: inout Double) {
        for Grade in finalGrades{
            if Grade != -1000{
                if max(high, Grade) == Grade{
                    high = Grade
                }
                if min(low, Grade) == Grade{
                    low = Grade
                }
            }
        }
    }
    
    func DetermineColor(fromClassGrades classes: [Course] = [],fromAssignmentGrades assignments: AssignmentGrades = AssignmentGrades(classDesc: "NULL"), gradingTerm: String) -> [UIColor] {
        var finalColors: [UIColor] = []
        var high:Double = -9999.0;
        var low:Double = 9999.0;
        var finalGrades:[Double] = []

        if(classes.isEmpty){
            for grade in assignments.DailyGrades{
                finalGrades.append(grade.Grade)
            }
            for grade in assignments.MajorGrades{
                finalGrades.append(grade.Grade)
            }
        }else{
            for course in classes{
                finalGrades.append(Double(course.Grades.Grades[gradingTerm] ?? "-1000") ?? -1000.0)
            }
        }
        findMaxAndLowOf(finalGrades, &high, &low)
        
        for Grade in finalGrades{
                if Grade != -1000.0{
                    let greenVal = CGFloat(Double(Grade)/Double(100) )
                    let red = CGFloat((Double(Grade-(low-1))/Double(high)) * 10)
                    print((greenVal).description + "  " + red.description)
                    finalColors.append(UIColor(red: 1 - red, green: greenVal, blue: 0, alpha: 1))
                }else{
                    finalColors.append(UIColor(red: 0, green: 0.8471, blue: 0.8039, alpha: 1.0))
                }
            }
        return finalColors
    }
}
