//
//  SummaryViewController.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 20/11/2020.
//

import UIKit

class SummaryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var totalShiftsLabel: UILabel!
    @IBOutlet weak var totalHoursLabel: UILabel!
    @IBOutlet weak var totalTipsLabel: UILabel!
    @IBOutlet weak var totalSalaryLabel: UILabel!
    
    var shiftManager = ShiftManager()
    var calculator = Calculator()
    
    var stringDatesArray = [String]()
    var monthlyShiftCount = 0
    var monthlyHours = 0.0
    var monthlyTips = 0.0
    var monthlySalary = 0.0
    
    override func viewDidLoad() {
        shiftManager.loadShifts()
        calculator.groupByMonth(shifts: shiftManager.shifts)
        calculator.groupShiftWithMonth()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        calculateProperties()
        showData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("didAppear")
        shiftManager.loadShifts()
        calculator.groupByMonth(shifts: shiftManager.shifts)
        calculator.groupShiftWithMonth()
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        calculateProperties()
        showData()
    }
    
    func showData() {
        totalShiftsLabel.text = String(monthlyShiftCount)
        totalHoursLabel.text = String(format: "%.2f", monthlyHours)
        totalTipsLabel.text = String(format: "%.2f", monthlyTips)
        totalSalaryLabel.text = String(format: "%.2f", monthlySalary)
    }
    
    func calculateProperties() {
        resetProperties()
        let selectedTitle = pickerView.selectedRow(inComponent: 0)
        if let shifts = calculator.groupedShifts?[(calculator.months?[selectedTitle])!] {
            monthlyShiftCount = shifts.count
            for shift in shifts {
                monthlyHours += shift.totalHours
                monthlyTips += shift.tips
                monthlySalary += shift.totalSalary
            }
        }
    }
    
    func resetProperties() {
        monthlyHours = 0
        monthlyTips = 0
        monthlySalary = 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return calculator.groupedShifts?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let keys = calculator.groupedShifts?.keys.sorted() {
            for date in keys {
                let stringDate = calculator.formatDate(date, format: "MMMM yyyy")
                stringDatesArray.append(stringDate!)
            }
            return stringDatesArray[row]
        } else {
         return "No shifts added yet"
        }
    }
}
