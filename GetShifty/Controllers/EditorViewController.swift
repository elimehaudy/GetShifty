//
//  EditorViewController.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 11/11/2020.
//

import UIKit

class EditorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var startingDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    @IBOutlet weak var salaryPerHourTextField: UITextField!
    @IBOutlet weak var tipsTextField: UITextField!
    @IBOutlet weak var totalHoursLabel: UILabel!
    @IBOutlet weak var totalSalaryLabel: UILabel!
    
    var calculator = Calculator()
    var shiftManager = ShiftManager()
    var selectedShift: Shift?
    
    var key = String()
    var value: Any?
    var valueChanged = false
    
    override func viewDidLoad() {
        initView()
    }
    
    func initView() {
        salaryPerHourTextField.delegate = self
        tipsTextField.delegate = self
        addTargetsToControls()
        showShiftDetails()
    }
    
    func addTargetsToControls() {
        startingDatePicker.addTarget(self, action: #selector(controlDidChange(_:)), for: .valueChanged)
        startingDatePicker.addTarget(self, action: #selector(checkDatePicker), for: .editingDidEnd)
        endingDatePicker.addTarget(self, action: #selector(controlDidChange(_:)), for: .valueChanged)
        endingDatePicker.addTarget(self, action: #selector(checkDatePicker), for: .editingDidEnd)
        salaryPerHourTextField.addTarget(self, action: #selector(controlDidChange(_:)), for: .editingChanged)
        tipsTextField.addTarget(self, action: #selector(controlDidChange(_:)), for: .editingChanged)
    }
    
    func showShiftDetails() {
        if let safeShift = selectedShift {
            startingDatePicker.date = safeShift.startingDate
            endingDatePicker.date = safeShift.endingDate
            salaryPerHourTextField.text = String(safeShift.salaryPerHour)
            tipsTextField.text = String(safeShift.tips)
            totalHoursLabel.text = String(safeShift.totalHours)
            totalSalaryLabel.text = String(safeShift.totalSalary)
        }
    }
    //MARK: - UIButton actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Shift", message: "Are you sure you want to delete this shift?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.shiftManager.deleteShift(self.selectedShift!)
            self.performSegue(withIdentifier: "goBack", sender: self)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIControl Related Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return limitDecimalPoint(string, textField)
    }
    
    @objc func controlDidChange(_ control: UIControl) {
        switch control.tag {
        case 1:
            key = "startingDate"
            value = startingDatePicker.date
        case 2:
            key = "endingDate"
            value = endingDatePicker.date
        case 3:
            key = "salaryPerHour"
            value = Double(salaryPerHourTextField.text!) ?? 0
        case 4:
            key = "tips"
            value = Double(tipsTextField.text!) ?? 0
        default:
            -1
        }
        valueChanged = true
    }
    
    @objc func checkDatePicker() {
        if valueChanged {
            let datesAreCorrect = calculator.checkDates(startingDate: startingDatePicker.date, endingDate: endingDatePicker.date)
            if datesAreCorrect {
                shiftManager.updateShift(shift: selectedShift!, changedValue: value!, forKey: key)
                calculateUpdatedHours()
                valueChanged = false
            }
            else {
                let alert = UIAlertController(title: "", message: "Starting date can't be equal or later than ending date", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if valueChanged {
            shiftManager.updateShift(shift: selectedShift!, changedValue: value!, forKey: key)
            calculateUpdatedSalary()
            valueChanged = false
        }
    }
    
    //MARK: - Shift Update Methods
    
    func calculateUpdatedHours() {
        calculator.calculateTotalHours(between: startingDatePicker.date, endingDatePicker.date)
        totalHoursLabel.text = calculator.totalHoursString
        shiftManager.updateShift(shift: selectedShift!, changedValue: calculator.totalHours, forKey: "totalHours")
        calculateUpdatedSalary()
    }
    
    func calculateUpdatedSalary() {
        calculator.totalHours = Double(totalHoursLabel.text!)!
        calculator.calculateTotalSalary(salaryPerHour: selectedShift?.salaryPerHour ?? 0, tips: selectedShift?.tips ?? 0)
        totalSalaryLabel.text = calculator.totalSalaryString
        shiftManager.updateShift(shift: selectedShift!, changedValue: calculator.totalSalary, forKey: "totalSalary")
    }
}
