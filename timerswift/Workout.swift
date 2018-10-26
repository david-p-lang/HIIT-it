import Foundation
import UIKit

class Workout : NSObject {
    var runningNow = false
    var restTime = 50
    var intervalCount = 40
    var intervalCompleteCount = 0
    var workoutLength = 0
    var cooldownTime = 180
    var warmupTime = 20
    
    var heartRateGoal = 165
    var reachedTargetHeartRate = false
    
    var timerCount = 0
    var recoveryTimerCount = 0
    var timer = Timer()
    var recoveryTimer = Timer()
    var minutes = 0
    var seconds = 0
    var displayMinutes: String = "00"
    var displaySeconds: String = "00"
    
    var phase:[String]=["Warmup"]
    var alertMessage = ""
    var phaseIndex = 0
    var defaults = UserDefaults.standard
    var workoutPlan = [0,0,0,0,0]
    
    // =========== WORKOUT ANALYSIS VARIABLES ============
    var timesToGoal = [Int]()
    var completedHRGoals = [Int]()
    var abovePeakRates = [Int]()
    var abovePeakRatesToGoal = [Int]()
    var abovePeakRatesToGoalSets = [Array<Int>]()
    var abovePeakRateSets = [Array<Int>]()
    var maxALLSets = [Int]()
    
    override init() {
        
        print("workout initialization")
        if let workoutPlan = defaults.array(forKey: "DefaultWorkout") as? [Int] {
            if (workoutPlan[0] as Int >= 60) && (Int(workoutPlan[0]) <= 220) {
                heartRateGoal = workoutPlan[0]
            } else {
                print(alertMessage = "Heart rate range error")
            }
            if workoutPlan[1] > 0 {
                intervalCount = workoutPlan[1]
            } else {
                alertMessage = "At least 1 interval required"
            }
            if  workoutPlan[2] > 4 {
                restTime = workoutPlan[2]
            } else {
                alertMessage = "Rest time must be at least 5 seconds"
            }
            if workoutPlan[3] > 0 {
                warmupTime = workoutPlan[3]
            } else {
                alertMessage = "Warmup time must be greater than zero"
            }
            
            if workoutPlan[4] > 0 {
                cooldownTime = workoutPlan[4]
            } else {
                alertMessage = "Cooldown time must be greater than zero"
            }
        } else {
            print("workout initialization failure")
            workoutPlan[0] = heartRateGoal
            workoutPlan[1] = intervalCount
            workoutPlan[2] = restTime
            workoutPlan[3] = warmupTime
            workoutPlan[4] = cooldownTime
            
        }
        
        var count = intervalCount + 1
        
        for index in 0...count {
            if index == 0 {
                phase[index] = "Warmup"
            } else if (index > 0 && index != count) {
                phase.append("High Intensity")
                phase.append("Rest")
            } else {
                phase.append("Cooldown")
                phase.append("Complete")
            }
        }
        
    }
    /*func startTimer () -> Timer{
       intTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: "counting", userInfo: nil, repeats: true)
        return intTimer
    }*/
    // ======= RESET THE TIMER STATE AT PHASE CHANGE =======
    func phaseUpdate () -> String {
        self.phaseIndex = self.phaseIndex + 1
        if phaseIndex < phase.count {
            print("phaseindex: \(phaseIndex) and \(phase.count) and \(phase)")
            switch self.phase[phaseIndex] {
            case "Warmup":
                self.timerCount = self.warmupTime
            case "Cooldown":
                self.timerCount = self.cooldownTime
            case "Rest":
                completedHRGoals.append(heartRateGoal)
                peakSetHR()
                abovePeakRateSets.append(abovePeakRates)
                abovePeakRatesToGoalSets.append(abovePeakRatesToGoal)
                
                self.timerCount = self.restTime
                print(timerCount)
            case "High Intensity":
                
                self.timerCount = 0
            default:
                //self.timerCount = 999
                timer.invalidate()
            }
            return self.phase[phaseIndex]
        }
        return "Complete"
    }
    // =========== UPDATE THE TIMER ==========
    func counting() -> String {
        
        if self.timerCount < 10 {
            self.seconds = self.timerCount
            self.minutes = 0
            self.displaySeconds = "0" + "\(seconds)"
            self.displayMinutes = "00"
            
        }
        if self.timerCount >= 10 {
            self.minutes = self.timerCount / 60
            if self.minutes > 0 {
                self.seconds = self.timerCount - (minutes * 60)
            } else {
                self.seconds = self.timerCount
            }
            if self.seconds < 10 {
                self.displaySeconds = "0"+"\(self.seconds)"
            } else {
                self.displaySeconds = "\(self.seconds)"
            }
            self.displayMinutes = "0" + "\(self.minutes)"
        }
        
        //=========== C O N T R O L  O F  P H A S E U P D A T E ( ) ==========
        if self.phase[phaseIndex] == "High Intensity" {
            self.timerCount += 1
        } else {
            self.timerCount -= 1
            if self.timerCount == -1 {
                phaseUpdate()
            }
        }
        return self.displayMinutes + ":" + self.displaySeconds
        
    }
    
    //=============== USED FOR INITIALLY DISPLAYING THE COUNT =================
    func displayCount() -> String {
        
        if self.timerCount < 10 {
            seconds = self.timerCount
            minutes = 0
            displaySeconds = "0" + "\(seconds)"
            displayMinutes = "00"
            
        }
        if self.timerCount >= 10 {
            minutes = self.timerCount / 60
            if minutes > 0 {
                seconds = self.timerCount - (minutes * 60)
            } else {
                seconds = self.timerCount
            }
            if seconds < 10 {
                displaySeconds = "0"+"\(seconds)"
            } else {
                displaySeconds = "\(seconds)"
            }
            displayMinutes = "0" + "\(minutes)"
        }
        return self.displayMinutes + ":" + self.displaySeconds
    }
    func saveWorkoutItems() {
        workoutPlan[0] = heartRateGoal
        workoutPlan[1] = intervalCount
        workoutPlan[2] = restTime
        workoutPlan[3] = warmupTime
        workoutPlan[4] = cooldownTime
        defaults.setValue(workoutPlan, forKey: "DefaultWorkout")
    }
    func getWorkoutPlan() -> Array<Int> {
        workoutPlan[0] = heartRateGoal
        workoutPlan[1] = intervalCount
        workoutPlan[2] = restTime
        workoutPlan[3] = warmupTime
        workoutPlan[4] = cooldownTime
        return workoutPlan
    }
    func peakSetHR() {
        if abovePeakRates.count > 0 {
            var theMaxHr = abovePeakRates[0]
            for i in 1...abovePeakRates.count - 1 {
                if abovePeakRates[i] > theMaxHr {
                    theMaxHr = abovePeakRates[i]
                }
            }
            maxALLSets.append(theMaxHr)
        } else {
            
        }
    }
}

