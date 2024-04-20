import UIKit
import CoreData

private enum TrackerRecordStoreError: Error {
    case failedCreateNewRecord
    case failedFetchRecords
}

final class TrackerRecordStore: NSObject {
    // MARK: - Identifer
    static let shared = TrackerRecordStore()
    // MARK: - Public Properties
    var records: [TrackerRecord]? {
        try? getTrackerRecords() ?? []
    }
    // MARK: - Private Properties
    private var context: NSManagedObjectContext
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
    }
    // MARK: - Public Methods
    func createCoreDataTrackerRecord(from record: TrackerRecord) -> TrackerRecordCoreData {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.date = record.date
        newTrackerRecord.identifer = record.id
        return newTrackerRecord
    }
    
    func removeRecordCoreData(_ id: UUID, with date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        let trackerRecords = try context.fetch(request)
        let filterRecord = trackerRecords.first {
            $0.identifer == id && $0.date == date
        }
        if let trackerRecordCoreData = filterRecord {
            context.delete(trackerRecordCoreData)
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
    
    private func getTrackerRecords() throws -> [TrackerRecord]? {
        let request = TrackerRecordCoreData.fetchRequest()
        let objects = try context.fetch(request)
        let records = try objects.map { try self.createNewRecord($0) }
        return records
    }
    
    private func createNewRecord(_ recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let identifer = recordCoreData.identifer,
            let date = recordCoreData.date else {
            throw TrackerRecordStoreError.failedCreateNewRecord
        }
        let trackerRecord = TrackerRecord(id: identifer, date: date)
        return trackerRecord
    }
}


