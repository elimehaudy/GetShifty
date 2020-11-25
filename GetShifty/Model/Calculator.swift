//
//  Calculator.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 20/11/2020.
//

import Foundation
import RealmSwift

struct Calculator {
    let realm = try! Realm()
    let shiftManager = ShiftManager()
    
    var groupedShifts: [Date:Results<Shift>]?
    var months: [Date]?
    var totalSalary: Double = 0
    var totalHours: Double = 0
    var totalHoursString: String?
    
    mutating func calculateTotalSalary(salaryPerHour: Double, tips: Double) {
        totalSalary = (ceil((salaryPerHour * totalHours) * 100) / 100) + tips
    }
    
    mutating func calculateTotalHours(between date1: Date, _ date2: Date) {
        let timeInterval = date1.distance(to: date2)
        let secondsInAnHour: Double = 3600
        totalHours = ceil((timeInterval / secondsInAnHour) * 100) / 100
        totalHoursString = String(format: "%.2f", totalHours)
    }
    
    func formatDate(_ date: Date?, format: String) -> String? {
        let formatter = DateFormatter()
        var dateFormatted = String()
        formatter.dateFormat = format
        if let dateToFormat = date {
            dateFormatted = formatter.string(from: dateToFormat)
            return dateFormatted
        } else {
            return nil
        }
    }
    
    mutating func groupByMonth(shifts: Results<Shift>?) {
        months = (shifts?.reduce(into: [Date](), { (month, currentShift) in
            let date = currentShift.startingDate
            
            let beginningOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 1))!
            
            let endOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 31))!
            
            if !month.contains(where: { addedDate-> Bool in
                return addedDate >= beginningOfMonth && addedDate <= endOfMonth
            }) {
                month.append(beginningOfMonth)
            }
        }))!
    }
    
    mutating func groupShiftWithMonth() {
        groupedShifts = months?.reduce(into: [Date:Results<Shift>](), { (results, date) in
            
            let beginningOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 1))!

            let endOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 31))!
            
            results[beginningOfMonth] = realm.objects(Shift.self).filter("startingDate >= %@ AND startingDate <= %@", beginningOfMonth, endOfMonth)
        })
    }
    
    func checkDates(startingDate: Date, endingDate: Date) -> Bool{
        var datesAreCorrect = true
        if startingDate >= endingDate {
            datesAreCorrect = false
        }
        return datesAreCorrect
    }
}
