//
//  ResultsViewController.swift
//  timerswift
//
//  Created by David Lang on 6/8/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var theMonitor:HeartRateLEMonitor!
    var theWorkout:Workout!
    @IBOutlet weak var resultsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(theWorkout.timesToGoal)
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            print("the results section times to goal \(theWorkout.timesToGoal.count)")
            return theWorkout.timesToGoal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.setCell(maxHR: theWorkout.maxALLSets[indexPath.row], timeTG: theWorkout.timesToGoal[indexPath.row], goalHR: theWorkout.completedHRGoals[indexPath.row], hIRates: theWorkout.abovePeakRateSets[indexPath.row])
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        
        return cell
    }
    @IBAction func resetProgram(sender: AnyObject) {
        theWorkout.runningNow = false
        theWorkout.restTime = 50
        theWorkout.intervalCount = 40
        theWorkout.intervalCompleteCount = 0
        theWorkout.workoutLength = 0
        theWorkout.cooldownTime = 180
        theWorkout.warmupTime = 20
        
        theWorkout.heartRateGoal = 165
        theWorkout.reachedTargetHeartRate = false
        
        theWorkout.timerCount = 0
        theWorkout.recoveryTimerCount = 0
        theWorkout.timer = Timer()
        theWorkout.recoveryTimer = Timer()
        theWorkout.minutes = 0
        theWorkout.seconds = 0
        theWorkout.displayMinutes = "00"
        theWorkout.displaySeconds = "00"
        
        theWorkout.phase = ["Warmup"]
        theWorkout.alertMessage = ""
        theWorkout.phaseIndex = 0
        theWorkout.workoutPlan = [0,0,0,0,0]
        
        // =========== WORKOUT ANALYSIS VARIABLES ============
        theWorkout.timesToGoal = [Int]()
        theWorkout.completedHRGoals = [Int]()
        theWorkout.abovePeakRates = [Int]()
        theWorkout.abovePeakRatesToGoal = [Int]()
        theWorkout.abovePeakRatesToGoalSets = [Array<Int>]()
        theWorkout.abovePeakRateSets = [Array<Int>]()
        theWorkout.maxALLSets = [Int]()
        
        theWorkout = Workout()
    }
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "homeSegue" {
            let  vc = segue.destination as!  ViewController
            vc.theMonitor = theMonitor
            
        }
    } */

}
