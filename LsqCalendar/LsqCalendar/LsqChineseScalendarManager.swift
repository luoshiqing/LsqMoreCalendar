//
//  LsqChineseScalendarManager.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class LsqChineseScalendarManager: NSObject {

    lazy var chineseCalendar: Calendar = {
        return Calendar(identifier: .chinese)
    }()
    lazy var chineseMonthArray : [String] = {
        let months = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月",
        "九月", "十月", "冬月", "腊月"]
        return months
    }()
//    var chineseYearArray : [String]?
    
    lazy var chineseDayArray : [String] = {
        let days = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
         "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        return days
    }()
    
    override init() {
        super.init()
    }
    
    public func getChineseCalendarWithDate(date: Date, calendarItem: inout LsqSectionCalendarModel) {
        
        let cps: Set<Calendar.Component> = [
            Calendar.Component.year,
            Calendar.Component.month,
            Calendar.Component.day
        ]
        let localeComp = chineseCalendar.dateComponents(cps, from: date)
        var tempday: Int? = localeComp.day
        
        if tempday == 0 {
            tempday = 30
        }
        let chineseMonth = chineseMonthArray[(localeComp.month)! - 1]
        let chineseDay = chineseDayArray[tempday! - 1]
        calendarItem.chineseCalendar = chineseDay
        
        if chineseMonth == "正月" && chineseDay == "初一" {
            calendarItem.holiday = "春节"
        }else if chineseMonth == "正月" && chineseDay == "十五" {
            calendarItem.holiday = "元宵节"
        }
        else if chineseMonth == "二月" && chineseDay == "初二" {
            calendarItem.holiday = "龙抬头"
        }
        else if chineseMonth == "五月" && chineseDay == "初五" {
            calendarItem.holiday = "端午节"
        }
        else if chineseMonth == "七月" && chineseDay == "初七" {
            calendarItem.holiday = "七夕"
        }
        else if chineseMonth == "八月" && chineseDay == "十五" {
            calendarItem.holiday = "中秋节"
        }
        else if chineseMonth == "九月" && chineseDay == "初九" {
            calendarItem.holiday = "重阳节"
        }
        else if chineseMonth == "腊月" && chineseDay == "初八" {
            calendarItem.holiday = "腊八"
        }
        else if chineseMonth == "腊月" && chineseDay == "二四" {
            calendarItem.holiday = "小年"
        }
        else if chineseMonth == "腊月" && chineseDay == "三十" {
            calendarItem.holiday = "除夕"
        }
        
    }
    /*
     清明节日期的计算 [Y*D+C]-L
     公式解读：Y=年数后2位，D=0.2422，L=闰年数，21世纪C=4.81，20世纪=5.59。
     */
    func isQingMingHolidayWithYear(year: Int,month: Int, day: Int) -> Bool {
        if month == 4 {
            let pre = year / 100
            var c:Double = 4.81
            if pre == 19 {
                c = 5.59
            }
            let y  = year % 100
            let qingMingDay = (Double(y) * 0.2422 + c) - Double(y)/4
            if Double(day) == qingMingDay {
                return true
            }
        }
        return false
    }
    
}
