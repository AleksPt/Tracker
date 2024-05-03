import Foundation

protocol CreateTypeTrackerDelegate: AnyObject {
    func createTracker(_ tracker: Tracker, with category: String)
}
