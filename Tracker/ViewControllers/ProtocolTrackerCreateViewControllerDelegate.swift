import UIKit

protocol TrackerCreateViewControllerDelegate: AnyObject {
    func passingTracker(_ tracker: Tracker, _ category: String)
}
