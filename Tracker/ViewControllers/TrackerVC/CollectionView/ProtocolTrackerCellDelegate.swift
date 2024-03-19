import Foundation

protocol TrackerCellDelegate: AnyObject {
    func trackerCompleted(for id: UUID, at indexPath: IndexPath)
}
