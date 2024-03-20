import Foundation

protocol ScheduleCellDelegate: AnyObject {
    func switchButtonClicked(to isSelected: Bool, of weekDay: Weekday)
}
