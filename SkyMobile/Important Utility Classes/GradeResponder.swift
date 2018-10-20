//
//  GradeResponder.swift
//  GradeChecker
//
//  Created by Hunter Han on 10/6/18.
//  Copyright © 2018 Hunter Han. All rights reserved.
//

import Foundation
import SwiftSoup

class GradeResponder {
    typealias Item = (text: String, html: String)
    
    var code: String
    var Classes: [String] = []
    var GradeBookScrapedData: [String:String] = [:]
    
    var Courses: [Course] = []
    
    init(_ HTMLCode: String) {
        code = HTMLCode
        Courses = parseHTMLToGetGrades(htmlCodeToParse: code)
        //TODO: Create new func that gets grades HINT: document.querySelectorAll("tr[group-parent]")[0]
    }
    func parseHTMLToGetGrades(htmlCodeToParse: String) -> [Course]{
        //Contains all courses that are available
        var newCourse: [Course] = []
        var classes: [String] = []
        let cssSelectorCode = "tr[group-parent]"
        //HINT: document.querySelectorAll("tr[group-parent]")[4].querySelectorAll("a[data-lit=\"T1\"]")[0].textContent
        do{
                let document = try SwiftSoup.parse(htmlCodeToParse)
                //print(htmlCodeToParse)
                // firn css selector
                let elements: Elements = try document.select(cssSelectorCode)
                //transform it into a local object (Item)
            
                for element in elements {
                    let text = try element.text()
                    if(text.contains("Period")){
                        classes.append(text)
                    }
                }
                newCourse = SplitClassDescription(classArr: classes)
                for elementIndex in 0...newCourse.count-1{
                    let html = try elements.eq(elementIndex).outerHtml()
                    for (term, _) in newCourse[elementIndex].Grades.Grades{
                        let document1 = try SwiftSoup.parse(html)
                        let gradeElem1: Elements = try document1.select("a[data-lit=\""+term+"\"]")
                        for element in gradeElem1{
                            print(term,": ",try element.text())
                            newCourse[elementIndex].Grades.Grades[term] = (try element.text())
                        }
                    }
                    //print("Class: " + text + "\nGrade: " + html)
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        return newCourse
    }
    
    func SplitClassDescription(classArr: [String]) -> [Course]{
        var finalPeriod: [Course] = []
        for Class in classArr{
            let current = Course(
                period: Int(Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[0].components(separatedBy: "(")[0])!,
                classDesc: Class.components(separatedBy: " Period")[0],
                teacher: Class.components(separatedBy: " Period")[1].components(separatedBy: ") ")[1])
            finalPeriod.append(current)
        }
        
        //        for testCase in finalPeriod{
        //            print("Class: " + testCase.Class + "\nPeriod: " + String(testCase.Period) + "\nTeacher: " + testCase.Teacher)
        //        }
        return finalPeriod
    }
}
