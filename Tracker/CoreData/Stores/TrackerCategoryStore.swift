import UIKit
import CoreData

private enum TrackeryCategoryStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidTrackers
    case failedFetchTrackerCategory
    case failedGetCategories
    case failedCreateRequest
}

final class TrackerCategoryStore: NSObject {
    // MARK: - Identifer
    static let shared = TrackerCategoryStore()
    // MARK: - Public Properties
    var categories: [TrackerCategory] {
            let categories = try? getListCategories().map { try self.convertToTrackerCategory($0) }
            return categories ?? []
    }
    // MARK: - Private Properties
    private let trackerStore = TrackerStore.shared
    private let context: NSManagedObjectContext
    
    private var categoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
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
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
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
            throw TrackeryCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        guard let name = model.name else {
            throw TrackeryCategoryStoreError.decodingErrorInvalidName
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
        let request = categoryFetchedResultsController.fetchRequest
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.name), title)
        guard let category = try context.fetch(request).first else {
            throw TrackeryCategoryStoreError.failedFetchTrackerCategory
        }
        return category
    }
    
    func getListCategoriesCoreData() throws -> [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        var list: [String] = []
        do {
            let objects = try context.fetch(request)
            list = objects.compactMap { try? convertToTrackerCategory($0)}.map { $0.headerName }
        } catch {
            throw TrackeryCategoryStoreError.failedGetCategories
        }
        return list
    }
    
    func getListCategories() throws -> [TrackerCategoryCoreData] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        var list: [TrackerCategoryCoreData]?
        do {
            list = try context.fetch(request)
        } catch {
            throw TrackeryCategoryStoreError.failedGetCategories
        }
        guard let categories = list else { fatalError("\(TrackeryCategoryStoreError.failedCreateRequest)")}
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

