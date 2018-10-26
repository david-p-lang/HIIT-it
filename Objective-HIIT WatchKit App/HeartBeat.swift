import UIKit

struct BeatPattern {
    var icon = ""
    var description = "Mid-range"
    var bpm = 80
    var duration: Double {
        return 60.0 / Double(bpm)
    }
}