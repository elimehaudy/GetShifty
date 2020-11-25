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
}
