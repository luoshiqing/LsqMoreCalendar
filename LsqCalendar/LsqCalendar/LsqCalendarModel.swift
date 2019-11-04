//
//  LsqCalendarModel.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

enum LsqSectionScalendType: Int {
    case today = 1
    case last = 2
    case next = 3
}

struct LsqSectionCalendarModel {

    var year            : Int?
    var month           : Int?
    var day             : Int?
    
    var dateInterval    : Int?
    var week            : Int?
    var holiday         : String?
    var chineseCalendar : String?
    var type            : LsqSectionScalendType?
}

struct LsqSectionCalendarHeaderModel {
    var headerText: String?
    var calendarItemArray = [LsqSectionCalendarModel]()
}
