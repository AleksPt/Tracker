import Foundation

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [Weekday])
}
