//
//  CustomTableViewCell.swift
//  timerswift
//
//  Created by David Lang on 6/2/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    //@IBOutlet weak var theResultView: ResultsView!
    //var goalRateLabel: UILabel = UILabel()
    //var maxHRLabel: UILabel = UILabel()
    //var tTTGLabel: UILabel = UILabel()
    
    @IBOutlet weak var goalRateLabel: UILabel!
    @IBOutlet weak var maxHRLabel: UILabel!
    @IBOutlet weak var tTTGLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setCell(maxHR: Int, timeTG: Int, goalHR: Int, hIRates: [Int]) {
        maxHRLabel.text = "Maximum heart rate: " + String(maxHR) + "(bpm)"
        goalRateLabel.text = "Goal heart rate: " + String(goalHR) + "(bpm)"
        tTTGLabel.text = "Time to goal: " + String(timeTG) + "(sec)"
        //theResultView.setRates(hIRates)
        
    }
    
}
