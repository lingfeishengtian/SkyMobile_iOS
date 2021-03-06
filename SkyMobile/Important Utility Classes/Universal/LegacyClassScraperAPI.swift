//
//  LegacyClassScraperAPI.swift
//  SkyMobile
//
//  Created by Hunter Han on 3/2/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

class LegacyGradeSweeperAPI{
    static let JavaScriptToScrapeGrades = """
                                            var p = $( "[id^=grid_gradeGrid_]" ).not( "[vpaginate='no']" )
                                                var Options = \(InformationHolder.AvailableTerms)

                                            function GetValuesOfLegacy(){
                                            var finalString = "";
                                                for(var i = 0;i < p.length; i++){
                                                    var Values = p[i].querySelectorAll("[id^=grid_gradeGrid_]");
                                                    var Classes = Values[1].querySelectorAll("tr");
                                                    var Grades = Values[0].querySelectorAll("tr");
                                                    let isElem = true
                                                    if(Values[0].querySelectorAll("tr")[1].textContent.includes("S1")){ isElem = false }
                                                    if(!isElem){
                                                    for(var j = 0; j < Classes.length; j++){
                                                        if(Classes[j].textContent.includes("Grade")){
                                                            finalString = finalString + "\\n @SWIFT_GRADE_NAME_CODEX " + Classes[j].textContent
                                                        }else
                                                        if(Classes[j].textContent.includes("Class") && Classes[j].textContent.includes("Terms")){
                                                        let theOptions = Grades[j].querySelectorAll("td")
                                                            Options = []
                                                            for(var t = 0; t < theOptions.length; t++){
                                                                 Options[t] = theOptions[t].textContent
                                                            }
                                                        }else{
                                                        finalString = finalString + " @SWIFT_CLASS_CODEX_START " + Classes[j].querySelector("td").textContent
                                                        var CurrentGrades = Grades[j].querySelectorAll("td");
                                                        for(var v = 0; v < CurrentGrades.length; v++){
                                                            finalString = finalString + " @SWIFT_GRADE_PERIOD_START " + Options[v] + ":" + CurrentGrades[v].textContent
                                                        }
                                                        }
                                                    }
                                                    finalString = finalString + "\\n";
                                                }
                                                }
                                            return finalString;
                                            }

                                            GetValuesOfLegacy()
                                            """
    static func ScrapeLegacyGrades(configuredString: String) ->  [LegacyGrade]{
        var FinalLegacyGrades: [LegacyGrade] = []
        let SplitSections = configuredString.components(separatedBy: "\n")
        for Section in SplitSections {
            var Grades = Section.components(separatedBy: "@SWIFT_GRADE_NAME_CODEX ")
            Grades.removeFirst()
            let tmp = LegacyGrade(sectionName: "", courses: [])
            for GradeSection in Grades{
                tmp.Grade = GradeSection.components(separatedBy: "@SWIFT_CLASS_CODEX_START")[0]
                var Classes = GradeSection.components(separatedBy: "@SWIFT_CLASS_CODEX_START")
                Classes.removeFirst()
                var tmpCourse = Course(period: "-1", classDesc: "", teacher: "")
                for ClassSection in Classes{
                    tmpCourse.Class = ClassSection.components(separatedBy: " @SWIFT_GRADE_PERIOD_START ")[0]
                    var GradingPeriods = ClassSection.components(separatedBy: " @SWIFT_GRADE_PERIOD_START ")
                    GradingPeriods.removeFirst()
                    var tmpGrades: [String:String] = [:]
                    for GradingPeriod in GradingPeriods{
                        var GradeFinale = GradingPeriod.components(separatedBy: ":")
                        tmpGrades[GradeFinale[0].trimmingCharacters(in: .whitespaces)] = GradeFinale[1].trimmingCharacters(in: .whitespaces)
                        tmpCourse.termGrades = tmpGrades
                    }
                    tmp.Courses.append(tmpCourse)
                }
                FinalLegacyGrades.append(tmp)
            }
        }
        return FinalLegacyGrades
    }
}
