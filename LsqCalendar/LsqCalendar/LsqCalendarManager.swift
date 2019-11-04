//
//  LsqCalendarManager.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

enum LsqSenctionScalendarType{ //日历显示的类型 可选过去/可选将来
    case past
    case middle
    case future
}
enum LsqSenctionSelectType{ //日历选择的类型 可选一天日期/可选一个日期区间
    case one
    case area
//    case oneAndArea
}
protocol ScalendarProtocol: NSObjectProtocol {
    func callBack(beginTime: Int,endTime: Int)
    func onleSelectOneDateCallBack(selectTime: Int)
}



class LsqCalendarManager: NSObject {

    private lazy var chineseCalendarManager: LsqChineseScalendarManager = {
        return LsqChineseScalendarManager()
    }()
    private var showChineseCalendar: Bool = false
    private var showChineseHolidaty: Bool = false
    private var startDate: Int = 0
    
    private lazy var greCalendar: Calendar = {
        return Calendar(identifier: .gregorian)
    }()
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    private lazy var todayDate: Date = { return Date() }()
    private lazy var todayCompontents: DateComponents = {
        return self.dateToComponents(date: self.todayDate)
    }()
    public var startIndexpath: IndexPath = {
        return IndexPath(row: 0, section: 0)
    }()
    
    init(showChineseHoliday: Bool, showChineseCalendar:Bool, startDate: Int) {
        super.init()
        self.showChineseHolidaty = showChineseHoliday
        self.showChineseCalendar = showChineseCalendar
        self.startDate = startDate
        
    }
    
    
    func getCalendarDataSoruce(limitMonth: Int, type: LsqSenctionScalendarType) -> [LsqSectionCalendarHeaderModel] {
        var resultArray:[LsqSectionCalendarHeaderModel] = []
        var components = self.dateToComponents(date: todayDate)
        components.day = 1
        if type == .future{
            components.month! -= 1
        }else if type == .past{
            components.month! -= limitMonth
        }else{
            components.month! -= (limitMonth + 1)/2
        }
        for i in 0..<limitMonth {
            components.month! += 1
            var headerModel = LsqSectionCalendarHeaderModel()
            let date = self.componentsToDate(components: components)
            self.dateFormatter.dateFormat = "yyyy年MM月"
            let dateString = dateFormatter.string(from: date)
            headerModel.headerText = dateString
            headerModel.calendarItemArray = getCalendarItemArray(date: date, section: i)
            resultArray.append(headerModel)
            
        }
        
        return resultArray
    }
    
    func getCalendarItemArray(date: Date, section: Int) -> [LsqSectionCalendarModel] {
        var resultArray:[LsqSectionCalendarModel] = []
        let tatalDay = numberOfDaysInCurrentMonth(date: date)
        let firstDay = startDayOfWeek(date: date)
        var components = self.dateToComponents(date: date)
        let tempDay = tatalDay + firstDay - 1
        var column = 0
        if tempDay % 7 == 0 {
            column = Int(tempDay/7)
        }else{
            column = Int(tempDay/7 + 1)
        }
        components.day = 0
        for var i in 0..<column {
            for j in 0..<7{
                if i == 0 && j < firstDay - 1 {
                    var calendarItem = LsqSectionCalendarModel()
                    calendarItem.year = nil
                    calendarItem.month = nil
                    calendarItem.day = nil
                    calendarItem.chineseCalendar = nil
                    calendarItem.holiday = nil
                    calendarItem.week = -1
                    calendarItem.dateInterval = -1
                    resultArray.append(calendarItem)
                    continue;
                }
                components.day! += 1
                if components.day == tatalDay + 1 {
                    i = column
                    break
                }
                var calendarItem = LsqSectionCalendarModel()
                calendarItem.year = components.year
                calendarItem.month = components.month
                calendarItem.day = components.day
                calendarItem.week = j
                let date = componentsToDate(components: components)
                calendarItem.dateInterval = dateToInterval(date: date)
                if startDate == calendarItem.dateInterval{
                    startIndexpath = IndexPath(row: 0, section: section)
                }
                //setChineseCalendarAndHoliday(components: components as DateComponents, date: date, calendarItem: &calendarItem)
                resultArray.append(calendarItem)
            }
        }
        
        return resultArray
    }
    func numberOfDaysInCurrentMonth(date:Date) -> Int {
        guard let length: Range<Int> = self.greCalendar.range(of: .day, in: .month, for: date) else {
            return 0
        }
        return length.count
    }
    
    func startDayOfWeek(date:Date) -> Int {
        var startDate: NSDate? = nil
        let gre = self.greCalendar as NSCalendar
        
        let result = gre.range(of: NSCalendar.Unit.month, start: &startDate, interval: nil, for: date)
        if result == true {
            let weekIndex = gre.ordinality(of: NSCalendar.Unit.day, in: NSCalendar.Unit.weekOfMonth, for: date)
            return weekIndex
        }
        return 0
    }
    
    func dateToInterval(date:Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
    
    func setChineseCalendarAndHoliday(components: DateComponents,date: Date, calendarItem: inout LsqSectionCalendarModel) {
        if components.year == todayCompontents.year && components.month == todayCompontents.month && components.day == todayCompontents.day{
            calendarItem.type = LsqSectionScalendType.today
            calendarItem.holiday = "今天"
        }else{
            calendarItem.holiday = nil
            if date.compare(self.todayDate) == .orderedDescending {
                calendarItem.type = LsqSectionScalendType.next
            }else{
                calendarItem.type = LsqSectionScalendType.last
            }
        }
        
        if components.month == 1 && components.day == 1{
            calendarItem.holiday = "元旦"
        }else if components.month == 2 && components.day == 14 {
            calendarItem.holiday = "情人节"
        }else if components.month == 3 && components.day == 8 {
            calendarItem.holiday = "妇女节"
        }else if components.month == 5 && components.day == 1 {
            calendarItem.holiday = "劳动节"
        }else if components.month == 5 && components.day == 4 {
            calendarItem.holiday = "青年节"
        }else if components.month == 6 && components.day == 1 {
            calendarItem.holiday = "儿童节"
        }else if components.month == 8 && components.day == 1 {
            calendarItem.holiday = "建军节"
        }else if components.month == 9 && components.day == 10 {
            calendarItem.holiday = "教师节"
        }else if components.month == 10 && components.day == 1 {
            calendarItem.holiday = "国庆节"
        }else if components.month == 12 && components.day == 25{
            calendarItem.holiday = "圣诞节"
        }
        if showChineseCalendar || showChineseHolidaty {
            chineseCalendarManager.getChineseCalendarWithDate(date: date, calendarItem: &calendarItem)
        }
        
    }
    
    //pragma mark NSDate和NSDateComponents转换
    func dateToComponents(date: Date) -> DateComponents {
       let cps: Set<Calendar.Component> = [
            Calendar.Component.era,
            Calendar.Component.year,
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.hour,
            Calendar.Component.minute,
            Calendar.Component.second
        ]
        let components = self.greCalendar.dateComponents(cps, from: date)
        return components
    }
    
    func componentsToDate(components cpts: DateComponents) -> Date {
        var components = cpts
        components.hour = 0
        components.minute = 0
        components.second = 0
        let date = self.greCalendar.date(from: components)
        return date!
    }
}
