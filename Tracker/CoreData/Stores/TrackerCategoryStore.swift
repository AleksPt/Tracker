import UIKit
import CoreData

private enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidTrackers
    case failedFetchTrackerCategory
    case failedGetCategories
    case failedCreateRequest
}

final class TrackerCategoryStore: NSObject {
    // MARK: - Identifer
    static let shared = TrackerCategoryStore()
    //MARK: - Delegate
    weak var delegate: TrackerCategoryDelegate?
    // MARK: - Public Properties
    var categories: [TrackerCategory] {
            let categories = try? getListCategories().map { try self.convertToTrackerCategory($0) }
            return categories ?? []
        }
    // MARK: - Private Properties
    private let trackerStore = TrackerStore.shared
    private let context: NSManagedObjectContext
    private var categoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    // MARK: - Initializers:
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        self.categoryFetchedResultsController = controller
        try? controller.performFetch()
    }
    // MARK: - Public Methods
    func createCategoryCoreData(with name: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        category.trackers = []
        try saveContext()
    }
    
    func convertToTrackerCategory(_ model: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let trackers = model.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        guard let name = model.name else {
            throw TrackerCategoryStoreError.decodingErrorInvalidName
        }
        
        let category = TrackerCategory(
            headerName: name,
            trackerArray: trackers.compactMap { coreDataTracker -> Tracker? in
                if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                    return try? trackerStore.convertTrackerFromCoreData(coreDataTracker)
                } else {
                    return nil
                }
            })
        return category
    }
    
    func fetchTrackerCategoryCoreData(title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.name), title)
        guard let category = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.failedFetchTrackerCategory
        }
        return category
    }
    
    func getListCategories() throws -> [TrackerCategoryCoreData] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        var list: [TrackerCategoryCoreData]?
        do {
            list = try context.fetch(request)
        } catch {
            throw TrackerCategoryStoreError.failedGetCategories
        }
        guard let categories = list else { fatalError("\(TrackerCategoryStoreError.failedCreateRequest)")}
        return categories
    }
    // MARK: - Private Methods
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryDidUpdate()
    }
}
