import UIKit
import CoreData

private enum TrackeryStoreError: Error {
    case decodingErrorInvalidModel
}

final class TrackerStore: NSObject  {
    // MARK: - Identifer
    static let shared = TrackerStore()
    // MARK: - Delegate
    weak var delegate: TrackerStoreDelegate?
    // MARK: - Private Properties
    private var trackers: [Tracker] {
        guard
            let objects = self.trackersFetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try convertTrackerFromCoreData($0) }) else {
            return []
        }
        return trackers
    }
    
    private let recordStore = TrackerRecordStore.shared
    private let uiColorMarshalling = UIColorMarshalling()
    private var context: NSManagedObjectContext
    private var trackersFetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    // MARK: - Initializers
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.trackersFetchedResultsController = controller
        try? controller.performFetch()
    }
    
    // MARK: - Public Methods
    func addCoreDataTracker(_ tracker: Tracker, with category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.identifer = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = category
        try saveContext()
    }
    
    func convertTrackerFromCoreData(_ modelCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = modelCoreData.identifer,
            let name = modelCoreData.name,
            let colorString = modelCoreData.color,
            let emoji = modelCoreData.emoji,
            let schedule = modelCoreData.schedule as? [Weekday] else {
            throw TrackeryStoreError.decodingErrorInvalidModel
        }
        let color = uiColorMarshalling.color(from: colorString)
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule)
    }
    
    func trackerUpdate(_ record: TrackerRecord) throws {
        let newRecord = recordStore.createCoreDataTrackerRecord(from: record)
        let request = TrackerCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.identifer), record.id as CVarArg)
        
        guard let trackers = try? context.fetch(request) else { return }
        if let trackerCoreData = trackers.first {
            trackerCoreData.addToRecord(newRecord)
            try saveContext()
        }
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
//MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}

