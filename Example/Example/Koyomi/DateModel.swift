//
//  DateModel.swift
//  Pods
//
//  Created by Shohei Yokoyama on 2016/10/10.
//
//

import UIKit

public enum MonthType { case previous, current, next }

public enum YearType { case previous, current, next }

final class DateModel: NSObject {
    
    // Type properties
    static let dayCountPerRow = 7
    static let maxCellCount   = 42
    
    var chinaeseYear: [String] = ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉", "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛己",  "壬午", "癸未", "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳", "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸丑", "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑", "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"]
    
    var chinaeseMonth: [String] = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"];
    
    var chinaeseDay: [String] = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    // Week text
    var weeks: (String, String, String, String, String, String, String) = ("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")
    
    enum WeekType: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday

        init?(_ indexPath: IndexPath) {
            let firstWeekday = Calendar.current.firstWeekday
            switch indexPath.row % 7 {
            case (8 -  firstWeekday) % 7:  self = .sunday
            case (9 -  firstWeekday) % 7:  self = .monday
            case (10 - firstWeekday) % 7:  self = .tuesday
            case (11 - firstWeekday) % 7:  self = .wednesday
            case (12 - firstWeekday) % 7:  self = .thursday
            case (13 - firstWeekday) % 7:  self = .friday
            case (14 - firstWeekday) % 7:  self = .saturday
            default: return nil
            }
        }
    }
    
    var calendarType: CalendarType {
        didSet {
            if calendarType != oldValue {
                setup()
            }
        }
    }
    
    enum SelectionMode { case single, multiple, sequence, none }
    
    var selectionMode: SelectionMode = .single
    
    struct SequenceDates { var start, end: Date? }
    lazy var sequenceDates: SequenceDates = .init(start: nil, end: nil)
    
    // Fileprivate properties
    fileprivate var currentDates: [Date] = []
    fileprivate var selectedDates: [Date: Bool] = [:]
    fileprivate var highlightedDates: [Date] = []
    fileprivate var currentDate: Date = .init()
    
    // MARK: - Initialization
    
    init(_ calendarType: CalendarType) {
        self.calendarType = calendarType
        super.init()
        setup()
    }
    
    // MARK: - Internal Methods -
    
    func cellCount(in month: MonthType, year: YearType) -> Int {
        if let weeksRange = calendar.range(of: .weekOfMonth, in: .month, for: atBeginning(of: month, year: year)) {
            let count = weeksRange.upperBound - weeksRange.lowerBound
            return count * DateModel.dayCountPerRow
        }
        return 0
    }
    
    func indexAtBeginning(in month: MonthType, year: YearType) -> Int? {
        if let index = calendar.ordinality(of: .day, in: .weekOfMonth, for: atBeginning(of: month, year: year)) {
            return index - 1
        }
        return nil
    }
    
    func indexAtEnd(in month: MonthType, year: YearType) -> Int? {
        if let rangeDays = calendar.range(of: .day, in: .month, for: atBeginning(of: month, year: year)), let beginning = indexAtBeginning(in: month, year: year) {
            let count = rangeDays.upperBound - rangeDays.lowerBound
            return count + beginning - 1
        }
        return nil
    }
    
    func dayString(at indexPath: IndexPath, isHiddenOtherMonth isHidden: Bool) -> String {
        if isHidden && isOtherMonth(at: indexPath) {
            return ""
        }
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "d"
        if calendarType == .chinaese {
            formatter.calendar = calendar
            let day = Int(formatter.string(from: currentDates[indexPath.row]))!
            return chinaeseDay[day-1]
        }else {
            return formatter.string(from: currentDates[indexPath.row])
        }
    }
    
    func isOtherMonth(at indexPath: IndexPath) -> Bool {
        if let beginning = indexAtBeginning(in: .current, year: .current), let end = indexAtEnd(in: .current, year: .current),
            indexPath.row < beginning || indexPath.row > end {
            return true
        }
        return false
    }
    
    func display(in month: MonthType) {
        currentDates = []
        currentDate = date(of: month, year: .current)
        setup()
    }
    
    func display(of year: YearType) {
        currentDates = []
        currentDate = date(of: .current, year: year)
        setup()
    }
    
    func dateString(in month: MonthType, year: YearType, withFormat format: String) -> String {
        if calendarType == .gregorian {
            let formatter: DateFormatter = .init()
            formatter.dateFormat = format
            formatter.calendar = calendar
            return formatter.string(from: date(of: month, year: year))
        }else {
            let formatter: DateFormatter = .init()
            formatter.calendar = calendar
            formatter.dateStyle = .short
            var dateString = formatter.string(from: date(of: month, year: year))
            let dateStrings = dateString.components(separatedBy: "/")
            if let last = dateStrings.last {
                dateString = last
            }
            formatter.dateStyle = .none
            formatter.dateFormat = "yyyy"
            if let year = Int(formatter.string(from: date(of: month, year: year))) {
                dateString = chinaeseYear[year - 1] + "(\(dateString)) "
            }
            formatter.dateFormat = "MM"
            if let month = Int(formatter.string(from: date(of: month, year: year))) {
                dateString += chinaeseMonth[month - 1]
            }
            return dateString
        }
    }
    
    func date(at indexPath: IndexPath) -> Date {
        return currentDates[indexPath.row]
    }
    
    func willSelectDate(at indexPath: IndexPath) -> Date? {
        let date = currentDates[indexPath.row]
        return selectedDates[date] == true ? nil : date
    }
    
    // Select date in programmatically
    func select(from fromDate: Date, to toDate: Date?) {
        if let toDate = toDate?.formated() {
            set(true, withFrom: fromDate, to: toDate)
        } else if let fromDate = fromDate.formated() {
            selectedDates[fromDate] = true
        }
    }
    
    // Unselect date in programmatically
    func unselect(from fromDate: Date, to toDate: Date?) {
        if let toDate = toDate?.formated() {
            set(false, withFrom: fromDate, to: toDate)
        } else if let fromDate = fromDate.formated() {
            selectedDates[fromDate] = false
        }
    }
    
    func unselectAll() {
        selectedDates.keys(of: true).forEach { selectedDates[$0] = false }
    }
    
    func select(with indexPath: IndexPath) {
        let selectedDate = date(at: indexPath)
        
        switch selectionMode {
        case .single:
            selectedDates.forEach { [weak self] date, isSelected in
                guard let me = self else { return }
                if selectedDate == date {
                    me.selectedDates[date] = me.selectedDates[date] == true ? false : true
                } else if isSelected {
                    me.selectedDates[date] = false
                }
            }
            
        case .multiple:
            selectedDates[date(at: indexPath)] = selectedDates[date(at: indexPath)] == true ? false : true
            
        case .sequence:
            
            // user has selected nothing
            if sequenceDates.start == nil && sequenceDates.end == nil {
                sequenceDates.start = selectedDate
                selectedDates[selectedDate] = true
                
            // user has selected sequence date
            } else if let _ = sequenceDates.start, let _ = sequenceDates.end {
                sequenceDates.start = selectedDate
                sequenceDates.end   = nil
                selectedDates.forEach { selectedDates[$0.0] = selectedDate == $0.0 ? true : false }
                
            // user select selected date
            } else if let start = sequenceDates.start , sequenceDates.end == nil && start == selectedDate {
                sequenceDates.start = nil
                selectedDates[selectedDate] = false
                
            // user has selected a date
            } else if let start = sequenceDates.start , sequenceDates.end == nil && start != selectedDate {
                
                let isSelectedBeforeDay = selectedDate < start
                
                let result: ComparisonResult
                let componentDay: Int
                
                if isSelectedBeforeDay {
                    result = .orderedAscending
                    componentDay = -1
                } else {
                    result = .orderedDescending
                    componentDay = 1
                }
                
                var date = start
                var components: DateComponents = .init()
                while selectedDate.compare(date) == result {
                    components.day = componentDay
                    
                    guard let nextDay = calendar.date(byAdding: components, to: date) else {
                        break
                    }
                    selectedDates[nextDay] = true
                    date = nextDay
                }
                
                sequenceDates.start = isSelectedBeforeDay ? selectedDate : start
                sequenceDates.end   = isSelectedBeforeDay ? start : selectedDate
            }
        default: break
        }
    }
    
    // Use only when selectionMode is sequence
    func selectedPeriodLength(with indexPath: IndexPath) -> Int {
        let selectedDate = date(at: indexPath)
        
        if let start = sequenceDates.start, let period = start.daysSince(selectedDate), sequenceDates.end == nil && start != selectedDate {
            return abs(period) + 1
        } else if let start = sequenceDates.start , sequenceDates.end == nil && start == selectedDate {
            return 0
        } else {
            return 1
        }
    }
    
    // Use only when selectionMode is sequence
    func willSelectDates(with indexPath: IndexPath) -> (from: Date?, to: Date?) {
        let willSelectedDate = date(at: indexPath)
        
        if sequenceDates.start == nil && sequenceDates.end == nil {
            return (willSelectedDate, nil)
        } else if let _ = sequenceDates.start, let _ = sequenceDates.end {
            return (willSelectedDate, nil)
        } else if let start = sequenceDates.start , sequenceDates.end == nil && start == willSelectedDate {
            return (nil, nil)
        } else if let start = sequenceDates.start , sequenceDates.end == nil && start != willSelectedDate {
            return willSelectedDate < start ? (willSelectedDate, sequenceDates.start) : (sequenceDates.start, willSelectedDate)
        } else {
            return (nil, nil)
        }
    }
    
    func isSelect(with indexPath: IndexPath) -> Bool {
        let date = currentDates[indexPath.row]
        return selectedDates[date] ?? false
    }
    
    func isHighlighted(with indexPath: IndexPath) -> Bool {
        let date = currentDates[indexPath.row]
        return highlightedDates.contains(date)
    }
    
    func setHighlightedDates(from: Date, to: Date?) {
        guard let fromDate = from.formated() else { return }
        
        if !highlightedDates.contains(fromDate) {
            highlightedDates.append(fromDate)
        }
        
        if let toDate = to?.formated() {
            let isSelectedBeforeDay = toDate < from
            
            let result: ComparisonResult
            let componentDay: Int
            
            if isSelectedBeforeDay {
                result       = .orderedAscending
                componentDay = -1
            } else {
                result = .orderedDescending
                componentDay = 1
            }
            
            var date = fromDate
            var components: DateComponents = .init()
            
            while toDate.compare(date) == result {
                components.day = componentDay
                
                guard let nextDay = calendar.date(byAdding: components, to: date) else {
                    break
                }
                
                if !highlightedDates.contains(nextDay) {
                    highlightedDates.append(nextDay)
                }
                date = nextDay
            }
        }
    }
    
    func week(at index: Int) -> String {
        switch index {
        case 0:  return weeks.0
        case 1:  return weeks.1
        case 2:  return weeks.2
        case 3:  return weeks.3
        case 4:  return weeks.4
        case 5:  return weeks.5
        case 6:  return weeks.6
        default: return ""
        }
    }
}

// MARK: - Private Methods -

private extension DateModel {
    
    var calendar: Calendar {
        if calendarType == .gregorian {
            return Calendar(identifier: .gregorian)
        }else {
            return Calendar(identifier: .chinese)
        }
    }
    
    func setup() {
        selectedDates = [:]
        
        guard let indexAtBeginning = indexAtBeginning(in: .current, year: .current) else { return }

        var components: DateComponents = .init()
        currentDates = (0..<DateModel.maxCellCount).compactMap { index in
                components.day = index - indexAtBeginning
                return calendar.date(byAdding: components, to: atBeginning(of: .current, year: .current))
            }
            .map { (date: Date) in
                selectedDates[date] = false
                return date
            }
        
        let selectedDateKeys = selectedDates.keys(of: true)
        selectedDateKeys.forEach { selectedDates[$0] = true }
    }
    
    func set(_ isSelected: Bool, withFrom fromDate: Date, to toDate: Date) {
        currentDates
            .filter { fromDate <= $0 && toDate >= $0 }
            .forEach { selectedDates[$0] = isSelected }
    }
    
    func atBeginning(of month: MonthType, year: YearType) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: date(of: month, year: year))
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }
    
    func date(of month: MonthType, year: YearType) -> Date {
        var components = DateComponents()
        components.month = {
            switch month {
            case .previous: return -1
            case .current:  return 0
            case .next:     return 1
            }
        }()
        components.year = {
            switch year {
            case .previous: return -1
            case .current:  return 0
            case .next:     return 1
            }
        }()
        return calendar.date(byAdding: components, to: currentDate) ?? Date()
    }
}
