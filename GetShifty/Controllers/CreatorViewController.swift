//
//  ViewController.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 10/11/2020.
//

import UIKit

class CreatorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var startingDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    @IBOutlet weak var salaryPerHourTextField: UITextField!
    @IBOutlet weak var tipsTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var shiftManager = ShiftManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        salaryPerHourTextField.delegate = self
        tipsTextField.delegate = self
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if checkDates(startingDate: startingDatePicker.date, endingDate: endingDatePicker.date) {
            shiftManager.calculateTotalHours(between: startingDatePicker.date, endingDatePicker.date)
            shiftManager.calculateTotalSalary(salaryPerHour: Double(salaryPerHourTextField.text!) ?? 0, tips: Double(tipsTextField.text!) ?? 0)
            
            let newShift = shiftManager.createNewShift(startingDate: startingDatePicker.date, endingDate: endingDatePicker.date, shiftTotalHours: shiftManager.totalHours, salaryPerHour: Double(salaryPerHourTextField.text!) ?? 0, totalSalary: shiftManager.totalSalary, tips: Double(tipsTextField.text!) ?? 0)
            shiftManager.saveShift(newShift)
            
            performSegue(withIdentifier: "goBack2", sender: self)
        }
        
    }
    
    func checkDates(startingDate: Date, endingDate: Date) -> Bool{
        var datesAreCorrect = true
        if startingDate >= endingDate {
            datesAreCorrect = false
            let alert = UIAlertController(title: "", message: "Starting date can't be equal or later than ending date", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        return datesAreCorrect
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return limitDecimalPoint(string, textField)
    }
}

