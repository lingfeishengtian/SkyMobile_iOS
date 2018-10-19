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
        let HTMLParse:[Item] = parseHTML(htmlCodeToParse: HTMLCode)
        Classes = getClassAndGradesFrom(parsedHTML: HTMLParse)
        Courses = SplitClassDescription(classArr: Classes)
        Courses = parseHTMLToGetGrades(htmlCodeToParse: code, courseToTakeInfoFrom: Courses)
        //TODO: Create new func that gets grades HINT: document.querySelectorAll("tr[group-parent]")[0]
    }
    func parseHTMLToGetGrades(htmlCodeToParse: String, courseToTakeInfoFrom course: [Course]) -> [Course]{
        //Contains all courses that are available
        var newCourse: [Course] = course
        let cssSelectorCode = "tr[group-parent]"
        //HINT: document.querySelectorAll("tr[group-parent]")[4].querySelectorAll("a[data-lit=\"T1\"]")[0].textContent
        do{
                let document = try SwiftSoup.parse(htmlCodeToParse)
                //print(htmlCodeToParse)
                // firn css selector
                let elements: Elements = try document.select(cssSelectorCode)
                //transform it into a local object (Item)
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
    
    @available(*, deprecated, message: "Moving to one function that gets classes AND grades!")
    func parseHTML(htmlCodeToParse: String) -> [Item]{
        var items: [Item] = []
        do {
            let document = try SwiftSoup.parse(htmlCodeToParse)
            //print(htmlCodeToParse)
            // firn css selector
            let elements: Elements = try document.select("tr[group-parent]")
            //transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                items.append(Item(text: text, html: html))
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        return items
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

    func getClassAndGradesFrom(parsedHTML: [Item]) -> [String]{
        var FinalProduct: [String] = []
        for item in parsedHTML{
            if(item.text.contains("Period")){
                FinalProduct.append(item.text)
            }
        }
//                for Class in Classes{
//                    print(Class + " is a " + GradeBookScrapedData[Class]!)
//            }
        return FinalProduct
    }
    
}
