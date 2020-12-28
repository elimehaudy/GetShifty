//
//  ShiftsTableViewController.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 10/11/2020.
//

import UIKit

class ShiftsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var shiftManager = ShiftManager()
    var calculator = Calculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        shiftManager.loadShifts()
        calculator.groupByMonth(shifts: shiftManager.shifts)
        calculator.groupShiftWithMonth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! EditorViewController
            destinationVC.selectedShift = calculator.groupedShifts?[(calculator.months?[indexPath.section])!]?.sorted(byKeyPath: "startingDate", ascending: true)[indexPath.row]
        }
    }

    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.shiftManager.loadShifts()
                self.calculator.groupByMonth(shifts: self.shiftManager.shifts)
                self.calculator.groupShiftWithMonth()
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - UITableVIew Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditor", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - UITableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return calculator.months?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = calculator.formatDate(calculator.months?[section], format: "MMMM yyyy")
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculator.groupedShifts?[(calculator.months?[section])!]?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reusableCell")
        cell.backgroundColor = #colorLiteral(red: 0.9572464824, green: 0.9103800654, blue: 0.8337891698, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 0.4243257344, green: 0.1549946964, blue: 0.04855654389, alpha: 1)
        let dates = calculator.groupedShifts?[(calculator.months?[indexPath.section])!]?.sorted(byKeyPath: "startingDate")
        let date = dates?[indexPath.row].startingDate
        let cellText = calculator.formatDate(date, format: "EEEE, MMM d, HH:mm")
        cell.textLabel?.text = cellText ?? "No shifts added yet"
        
        return cell
    }
}
