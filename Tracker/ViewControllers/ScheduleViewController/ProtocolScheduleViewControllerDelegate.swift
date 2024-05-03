import Foundation

protocol ScheduleViewControllerDelegate: AnyObject {
    var selectWeekDays: [Weekday] { get set }
    func didSelectDays()
}
