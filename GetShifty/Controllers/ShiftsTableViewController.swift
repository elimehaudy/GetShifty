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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        shiftManager.loadShifts()
        shiftManager.groupByMonth()
        shiftManager.groupShiftWithMonth()
    }
    
    //MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! EditorViewController
                destinationVC.selectedShift = shiftManager.groupedShifts[shiftManager.shiftDates[indexPath.section]]?.sorted(byKeyPath: "startingDate", ascending: true)[indexPath.row]
        }
    }

    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.shiftManager.loadShifts()
                self.shiftManager.groupByMonth()
                self.shiftManager.groupShiftWithMonth()
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
        return shiftManager.shiftDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = shiftManager.formatDate(shiftManager.shiftDates[section], format: "MMMM yyyy")
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftManager.groupedShifts[shiftManager.shiftDates[section]]?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reusableCell")
        cell.backgroundColor = #colorLiteral(red: 0.9572464824, green: 0.9103800654, blue: 0.8337891698, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 0.4243257344, green: 0.1549946964, blue: 0.04855654389, alpha: 1)
        let dates = shiftManager.groupedShifts[shiftManager.shiftDates[indexPath.section]]?.sorted(byKeyPath: "startingDate")
        let date = dates?[indexPath.row].startingDate
        let cellText = shiftManager.formatDate(date, format: "EEEE, MMM d, HH:mm")
        cell.textLabel?.text = cellText ?? "No shifts added yet"
        
        return cell
    }
}
