//
//  ResultsTable.swift
//  timerswift
//
//  Created by David Lang on 6/2/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import Foundation
import UIKit

class ResultsTable: NSObject, UITableViewDataSource , UITableViewDelegate {
    
    var theWorkout = Workout()
    
    init(displayWorkout: Workout){
        super.init()
            theWorkout = displayWorkout
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        _ = UITableViewCell()
        return "Results"
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return theWorkout.timesToGoal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CustomTableViewCell
        cell.setCell(maxHR: theWorkout.maxALLSets[indexPath.row], timeTG: theWorkout.timesToGoal[indexPath.row], goalHR: theWorkout.completedHRGoals[indexPath.row], hIRates: theWorkout.abovePeakRateSets[indexPath.row])
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        
        return cell
    }
}
