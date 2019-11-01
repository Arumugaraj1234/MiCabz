//
//  RideHistoryVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-04.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class RideHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getRideHistory()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getRideHistory() {
        AuthService.instance.ridesHistory.removeAll()
        AuthService.instance.getRideHistory(riderid: AuthService.instance.userId) { (status) in
            if status == 1 {
                self.tableView.reloadData()
            } else {
                print("Something went erong in getting ride History")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthService.instance.ridesHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? HistoryCell {
            let history = AuthService.instance.ridesHistory[indexPath.row]
            cell.configureCell(history: history)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        performSegue(withIdentifier: TO_RIDE_DETAILS_VC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let rideDetailVc = segue.destination as! RideDetailsVC
        rideDetailVc.selectedIndex = self.selectedIndex!
    }
    



}
