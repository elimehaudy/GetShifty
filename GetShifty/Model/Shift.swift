//
//  Shift.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 10/11/2020.
//

import Foundation
import RealmSwift

class Shift: Object {
    @objc dynamic var startingDate = Date()
    @objc dynamic var endingDate = Date()
    @objc dynamic var totalHours = Double()
    @objc dynamic var salaryPerHour = Double()
    @objc dynamic var totalSalary = Double()
    @objc dynamic var tips = Double()
    @objc dynamic var shiftId = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "shiftId"
      }
}
