import Foundation

protocol CreateTypeTrackerDelegate: AnyObject {
    func plusTracker(_ tracker: Tracker, _ category: String, from: CreateTypeTrackerViewController)
}
