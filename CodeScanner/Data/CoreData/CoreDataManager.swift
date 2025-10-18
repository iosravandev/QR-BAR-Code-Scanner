//
//  CoreDataManager.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()
    
    private init() {}

    private var context: NSManagedObjectContext { PersistenceController.shared.container.viewContext }

    // MARK: - Read

    func fetchAll() throws -> [ScannedCode] {
        let request = NSFetchRequest<ScannedCodeEntity>(entityName: "ScannedCodeEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        var result: [ScannedCode] = []
        var thrownError: Error?

        context.performAndWait {
            do {
                result = try context.fetch(request).map(ScannedCode.init(entity:))
            } catch {
                thrownError = error
            }
        }

        if let e = thrownError { throw e }
        return result
    }

    func find(rawValue: String, type: CodeType) throws -> ScannedCode? {
        let request = NSFetchRequest<ScannedCodeEntity>(entityName: "ScannedCodeEntity")
        request.predicate = NSPredicate(format: "rawValue == %@ AND typeRaw == %@", rawValue, type.raw)
        request.fetchLimit = 1

        var found: ScannedCode?
        var thrownError: Error?

        context.performAndWait {
            do {
                found = try context.fetch(request).first.map(ScannedCode.init(entity:))
            } catch {
                thrownError = error
            }
        }

        if let e = thrownError { throw e }
        return found
    }

    // MARK: - Write

    func save(_ code: ScannedCode) throws {
        var thrownError: Error?

        context.performAndWait {
            do {
                if let _ = try self._find(rawValue: code.rawValue, type: code.type) {
                    return
                }
                let obj = ScannedCodeEntity(context: context)
                obj.id = code.id
                obj.rawValue = code.rawValue
                obj.typeRaw = code.type.raw
                obj.customTitle = code.customTitle
                obj.content = code.content
                obj.productName = code.productInfo?.name
                obj.brand = code.productInfo?.brand
                obj.ingredients = code.productInfo?.ingredients
                obj.nutriScore = code.productInfo?.nutriScore
                obj.createdAt = code.createdAt

                try context.save()
            } catch {
                thrownError = error
            }
        }

        if let e = thrownError { throw e }
    }

    func updateTitle(id: UUID, title: String?) throws {
        let request = NSFetchRequest<ScannedCodeEntity>(entityName: "ScannedCodeEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        var thrownError: Error?

        context.performAndWait {
            do {
                if let obj = try context.fetch(request).first {
                    obj.customTitle = title
                    try context.save()
                }
            } catch {
                thrownError = error
            }
        }

        if let e = thrownError { throw e }
    }

    // MARK: - Private helpers
    private func _find(rawValue: String, type: CodeType) throws -> ScannedCodeEntity? {
        let request = NSFetchRequest<ScannedCodeEntity>(entityName: "ScannedCodeEntity")
        request.predicate = NSPredicate(format: "rawValue == %@ AND typeRaw == %@", rawValue, type.raw)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
