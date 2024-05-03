import UIKit

final class CategoryViewModel: NSObject {
    //MARK: - Delegate
    weak var delegate: CategoryViewControllerDelegate?
    //MARK: - Public Properties
    var onChange: (() -> Void)?
    //MARK: - Private Properties
    private var selectedCategory: String = ""
    private let categoryStore = TrackerCategoryStore.shared
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onChange?()
        }
    }
    func categoriesNumber() -> Int {
        categories.count
    }
    
    func didSelectCategory() {
        delegate?.selectedCategory = selectedCategory
        delegate?.didSelectCategory()
    }
    
    func setTextLabel(cell: UITableViewCell) {
        selectedCategory = cell.textLabel?.text ?? ""
    }
    
    func initSelectedCategory() {
        selectedCategory = delegate?.selectedCategory ?? ""
    }
    func checkTextSelectedCategory(cell: UITableViewCell) -> Bool {
        if selectedCategory == cell.textLabel?.text ?? "" {
            return true
        } else {
            return false
        }
    }
    // MARK: - Initializers
    override init() {
        super.init()
        categoryStore.delegate = self
        trackerCategoryDidUpdate()
    }
}
//MARK: - TrackerCategoryDelegate
extension CategoryViewModel: TrackerCategoryDelegate {
    func trackerCategoryDidUpdate() {
        categories = categoryStore.categories
    }
}


