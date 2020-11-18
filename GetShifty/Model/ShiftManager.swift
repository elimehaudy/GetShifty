//
//  ShiftManager.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 10/11/2020.
//

import Foundation
import RealmSwift

struct ShiftManager {
    let realm = try! Realm()
    var shifts: Results<Shift>?
    var groupedShifts = [Date:Results<Shift>]()
    var shiftDates = [Date]()
    
    var totalSalary: Double = 0
    var totalHours: Double = 0
    var totalHoursString: String?
    
    func createNewShift(startingDate: Date, endingDate: Date, shiftTotalHours: Double, salaryPerHour: Double, totalSalary: Double, tips: Double) -> Shift {
        let newShift = Shift()
        
        newShift.startingDate = startingDate
        newShift.endingDate = endingDate
        newShift.totalHours = shiftTotalHours
        newShift.salaryPerHour = salaryPerHour
        newShift.totalSalary = totalSalary
        newShift.tips = tips
        
        return newShift
    }
    
    func saveShift(_ shift: Shift) {
        do {
            try realm.write{
                realm.add(shift)
            }
        } catch {
            print("Error saving shift to realm, \(error)")
        }
    }
    
    mutating func loadShifts() {
        shifts = realm.objects(Shift.self).sorted(byKeyPath: "startingDate", ascending: true)
    }
    
    func updateShift(shift: Shift) {
        try! realm.write{
            realm.create(Shift.self, value: shift, update: .modified)
        }
    }
    
    func deleteShift(_ shift: Shift) {
        do {
            try realm.write{
                realm.delete(shift)
            }
        } catch {
            print("Error deleting shift, \(error)")
        }
    }
    
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
    
    mutating func groupByMonth() {
        shiftDates = (shifts?.reduce(into: [Date](), { (results, currentShift) in
            let date = currentShift.startingDate
            
            let beginningOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 1))!
            
            let endOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 31))!
            
            if !results.contains(where: { addedDate-> Bool in
                return addedDate >= beginningOfMonth && addedDate <= endOfMonth
            }) {
                results.append(beginningOfMonth)
            }
        }))!
    }
    
    mutating func groupShiftWithMonth() {
        groupedShifts = shiftDates.reduce(into: [Date:Results<Shift>](), { (results, date) in
            
            let beginningOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 1))!

            let endOfMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: 31))!
            
            results[beginningOfMonth] = realm.objects(Shift.self).filter("startingDate >= %@ AND startingDate <= %@", beginningOfMonth, endOfMonth)
        })
    }
}

extension String {
    
    func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
}
