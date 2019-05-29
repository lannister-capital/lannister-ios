// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HoldingManagedObject.swift instead.

import Foundation
import CoreData

public enum HoldingManagedObjectAttributes: String {
    case hex_color = "hex_color"
    case id = "id"
    case name = "name"
    case value = "value"
}

public enum HoldingManagedObjectRelationships: String {
    case currency = "currency"
    case transactions = "transactions"
}

open class _HoldingManagedObject: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "HoldingManagedObject"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<HoldingManagedObject> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _HoldingManagedObject.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var hex_color: String?

    @NSManaged open
    var id: String?

    @NSManaged open
    var name: String!

    @NSManaged open
    var value: Double // Optional scalars not supported

    // MARK: - Relationships

    @NSManaged open
    var currency: CurrencyManagedObject

    @NSManaged open
    var transactions: NSSet

    open func transactionsSet() -> NSMutableSet {
        return self.transactions.mutableCopy() as! NSMutableSet
    }

}

extension _HoldingManagedObject {

    open func addTransactions(_ objects: NSSet) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.transactions = mutable.copy() as! NSSet
    }

    open func removeTransactions(_ objects: NSSet) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.transactions = mutable.copy() as! NSSet
    }

    open func addTransactionsObject(_ value: TransactionManagedObject) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.transactions = mutable.copy() as! NSSet
    }

    open func removeTransactionsObject(_ value: TransactionManagedObject) {
        let mutable = self.transactions.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.transactions = mutable.copy() as! NSSet
    }

}

