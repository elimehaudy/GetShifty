//
//  EditorViewController.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 11/11/2020.
//

import UIKit
import RealmSwift

class EditorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var startingDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    @IBOutlet weak var salaryPerHourTextField: UITextField!
    @IBOutlet weak var tipsTextField: UITextField!
    @IBOutlet weak var totalHoursLabel: UILabel!
    @IBOutlet weak var totalSalaryLabel: UILabel!
    
    let realm = try! Realm()
    var controlWasChanged = false
    var didRecalculateHours = false
    var changedKey: String?
    var changedValue: Any?
    
    var calculator = Calculator()
    var shiftManager = ShiftManager()
    var selectedShift: Shift? {
        didSet {
            DispatchQueue.main.async {
                self.showShiftDetails()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        salaryPerHourTextField.delegate = self
        tipsTextField.delegate = self
        startingDatePicker.addTarget(self, action: #selector(controlDidChange(_:)), for: .valueChanged)
        endingDatePicker.addTarget(self, action: #selector(controlDidChange(_:)), for: .valueChanged)
        salaryPerHourTextField.addTarget(self, action: #selector(controlDidChange(_:)), for: .editingChanged)
        tipsTextField.addTarget(self, action: #selector(controlDidChange(_:)), for: .editingChanged)
        
        let backItem = UIBarButtonItem(title: "Custom", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    func showShiftDetails() {
        if let selectedShiftUnwrapped = selectedShift {
            matchViewWithData(view: startingDatePicker, data: selectedShiftUnwrapped.startingDate)
            matchViewWithData(view: endingDatePicker, data: selectedShiftUnwrapped.endingDate)
            matchViewWithData(view: salaryPerHourTextField, data: String(selectedShiftUnwrapped.salaryPerHour))
            matchViewWithData(view: tipsTextField, data: String(selectedShiftUnwrapped.tips))
            matchViewWithData(view: totalHoursLabel, data: String(selectedShiftUnwrapped.totalHours))
            matchViewWithData(view: totalSalaryLabel, data: String(selectedShiftUnwrapped.totalSalary))
        }
    }
    
    func matchViewWithData(view: UIView, data: Any?) {
        if let datePicker = view as? UIDatePicker {
            datePicker.date = data as! Date
        } else if let textField = view as? UITextField{
            textField.text = (data as! String)
        } else if let label = view as? UILabel {
            label.text = (data as! String)
        }
    }
    //MARK: - UIButton actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if controlWasChanged {
            recalculateSalary()
            try! realm.write{
                if didRecalculateHours {
                    selectedShift!.totalHours = Double(totalHoursLabel.text!)!
                }
                selectedShift!.totalSalary = Double(totalSalaryLabel.text!)!
            }
            shiftManager.updateShift(shift: selectedShift!)
        }
        performSegue(withIdentifier: "goBack", sender: self)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Shift", message: "Are you sure you want to delete this shift?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.shiftManager.deleteShift(self.selectedShift!)
            self.performSegue(withIdentifier: "goBack", sender: self)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return limitDecimalPoint(string, textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if controlWasChanged {
            recalculateSalary()
        }
    }
    
    @objc func controlDidChange(_ control: UIControl) {
        let datesAreCorrect = calculator.checkDates(startingDate: startingDatePicker.date, endingDate: endingDatePicker.date)
        if datesAreCorrect {
            controlWasChanged = true
            try! realm.write{
                if control.isKind(of: UIDatePicker.self) {
                    if control.tag == 1 {
                        selectedShift!.startingDate = startingDatePicker.date
                    } else if control.tag == 2 {
                        selectedShift!.endingDate = endingDatePicker.date
                    }
                    recalculateHours()
                } else if control.isKind(of: UITextField.self) {
                    if control.tag == 3 {
                        selectedShift!.salaryPerHour = Double(salaryPerHourTextField.text!) ?? 0
                    } else if control.tag == 4 {
                        selectedShift!.tips = Double(tipsTextField.text!) ?? 0
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "", message: "Starting date can't be equal or later than ending date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func recalculateHours(){
        didRecalculateHours = true
        calculator.calculateTotalHours(between: startingDatePicker.date, endingDatePicker.date)
        totalHoursLabel.text = calculator.totalHoursString
    }
    
    func recalculateSalary() {
        calculator.totalHours = Double(totalHoursLabel.text!)!
        calculator.calculateTotalSalary(salaryPerHour: selectedShift!.salaryPerHour, tips: selectedShift!.tips)
        totalSalaryLabel.text = String(calculator.totalSalary)
    }
}
