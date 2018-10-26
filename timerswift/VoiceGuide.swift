//
//  VoiceGuide.swift
//  timerswift
//
//  Created by David Lang on 5/28/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import Foundation
import AVFoundation

class VoiceGuide: NSObject {
    //let synth = AVSpeechSynthesizer()
    //var theUtterance = AVSpeechUtterance(string: "")
    
    func tellUser(guidance: String) {
        let synth = AVSpeechSynthesizer()
        let theUtterance = AVSpeechUtterance(string: guidance)
        theUtterance.rate = 0.22
        theUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-US")! as AVSpeechSynthesisVoice
        synth.speak(theUtterance)
        
    }
}
