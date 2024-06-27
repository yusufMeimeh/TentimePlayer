//
//  Database.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 14/09/2023.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlayerItem")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

class PlayerDatabaseManager {
    
    static let shared = PlayerDatabaseManager()

    func createRecord(id: String, seekTime: CGFloat, image: String) {
           let context = CoreDataManager.shared.managedObjectContext
           let newRecord = PlayerItem(context: context)
           newRecord.id = id
           newRecord.seekTime = Float(seekTime)
           newRecord.image = image
           do {
               try context.save()
           } catch {
               print("Error saving record: \(error.localizedDescription)")
           }
    }
    
    func fetchRecords() -> [PlayerItem] {
           let context = CoreDataManager.shared.managedObjectContext
           let fetchRequest: NSFetchRequest<PlayerItem> = PlayerItem.fetchRequest()

           do {
               let records = try context.fetch(fetchRequest)
               return records
           } catch {
               print("Error fetching records: \(error.localizedDescription)")
               return []
           }
       }
    
    func cleanData() {
         let managedObjectContext = CoreDataManager.shared.managedObjectContext
          // Create a fetch request for each entity you want to delete data from
         let fetchRequest: NSFetchRequest<PlayerItem> =  PlayerItem.fetchRequest()

          // Perform deletions in a transaction
          managedObjectContext.perform {
              do {
                  // Fetch and delete data for the first entity
                  let entities1 = try managedObjectContext.fetch(fetchRequest)
                  for entity1 in entities1 {
                     managedObjectContext.delete(entity1)
                  }

                  // Save changes to persist the deletions
                  try  managedObjectContext.save()
              } catch {
                  print("Failed to clean data: \(error)")
              }
          }
      }

      func trimData(uniqueID: String? = nil) {
          let managedObjectContext = CoreDataManager.shared.managedObjectContext
          // Perform trimming data in the background context
          managedObjectContext.perform {
              if let uniqueID = uniqueID, !uniqueID.isEmpty {
                  self.deleteContentInfo(uniqueID: uniqueID)
              }
          }
      }

      private func deleteContentInfo(uniqueID: String) {
          let managedObjectContext = CoreDataManager.shared.managedObjectContext
           // Create a fetch request for each entity you want to delete data from
          let fetchRequest: NSFetchRequest<PlayerItem> =  PlayerItem.fetchRequest()
          fetchRequest.predicate = NSPredicate(format: "id == %@", uniqueID)
          do {
              let matchingEntities = try managedObjectContext.fetch(fetchRequest)
              for entity in matchingEntities {
                  managedObjectContext.delete(entity)
              }
              try managedObjectContext.save()
          } catch {
              print("Failed to trim data: \(error)")
          }
      }
    
    func getRecords(byID id: String) -> [PlayerItem] {
        let context = CoreDataManager.shared.managedObjectContext
        let fetchRequest: NSFetchRequest<PlayerItem> = PlayerItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let records = try context.fetch(fetchRequest)
            // Since id should be unique, there should be at most one matching record
            return records
        } catch {
            print("Error fetching record by ID: \(error.localizedDescription)")
            return [  ]
        }
    }

}

