//
//  PersistenceManager.swift
//  Todo
//
//  Created by 유준상 on 2021/02/13.
//

import Foundation
import CoreData

class PersistenceManager {
    
    static var shared: PersistenceManager = PersistenceManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "Todo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - 저장된 데이터를 fetch 하는 메소드
    /// - NSManagedObject의 class type은 Todo타입이지만  general하게 사용하기위해 generic으로 사용
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    // MARK: - 저장하는 메소드
    @discardableResult
    func insertItem(item: TodoItem) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "Todo", in: self.context)
        
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            
            managedObject.setValue(item.events, forKey: "events")
            
            do {
                try self.context.save()
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
    // MARK: - 특정 object를 삭제하는 메소드
    @discardableResult
    func delete(object: NSManagedObject) -> Bool {
        self.context.delete(object)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    // MARK: - 전체 삭제하는 메소드
    @discardableResult
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool {
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.context.execute(delete)
            return true
        } catch {
            return false
        }
    }
    // MARK: - 저장된 데이터 갯수를 리턴하는 메소드
    /// - fetchArr.count를 사용해도 되지만 메소드로 구현
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int? {
        do{
            let count = try self.context.count(for: request)
            return count
        } catch {
            return nil
        }
    }
}
