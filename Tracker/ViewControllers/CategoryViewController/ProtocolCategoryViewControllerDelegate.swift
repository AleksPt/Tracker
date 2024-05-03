import Foundation

protocol CategoryViewControllerDelegate: AnyObject {
    var selectedCategory: String { get set }
    func didSelectCategory()
}
