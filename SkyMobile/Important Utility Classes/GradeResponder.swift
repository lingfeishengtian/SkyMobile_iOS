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
        var Classes = getClassAndGradesFrom(parsedHTML: HTMLParse)
        Courses = SplitClassDescription(classArr: Classes)
        //TODO: Create new func that gets grades HINT: document.querySelectorAll("tr[group-parent]")[0]
    }
    
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
            var current = Course(
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
