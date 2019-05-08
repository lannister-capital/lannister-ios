// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TransactionManagedObject.swift instead.

import Foundation
import CoreData

public enum TransactionManagedObjectAttributes: String {
    case identifier = "identifier"
    case name = "name"
    case type = "type"
    case value = "value"
}

public enum TransactionManagedObjectRelationships: String {
    case holding = "holding"
}

open class _TransactionManagedObject: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "TransactionManagedObject"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<TransactionManagedObject> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TransactionManagedObject.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var identifier: String!

    @NSManaged open
    var name: String!

    @NSManaged open
    var type: String!

    @NSManaged open
    var value: Double

    // MARK: - Relationships

    @NSManaged open
    var holding: HoldingManagedObject

}

