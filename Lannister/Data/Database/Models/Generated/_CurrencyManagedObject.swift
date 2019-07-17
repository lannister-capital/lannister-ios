// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CurrencyManagedObject.swift instead.

import Foundation
import CoreData

public enum CurrencyManagedObjectAttributes: String {
    case code = "code"
    case euro_rate = "euro_rate"
    case name = "name"
    case symbol = "symbol"
}

public enum CurrencyManagedObjectRelationships: String {
    case holdings = "holdings"
}

public enum CurrencyManagedObjectUserInfo: String {
    case identityAttributes = "identityAttributes"
}

open class _CurrencyManagedObject: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "CurrencyManagedObject"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<CurrencyManagedObject> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _CurrencyManagedObject.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var code: String!

    @NSManaged open
    var euro_rate: Double // Optional scalars not supported

    @NSManaged open
    var name: String!

    @NSManaged open
    var symbol: String!

    // MARK: - Relationships

    @NSManaged open
    var holdings: NSSet

    open func holdingsSet() -> NSMutableSet {
        return self.holdings.mutableCopy() as! NSMutableSet
    }

}

extension _CurrencyManagedObject {

    open func addHoldings(_ objects: NSSet) {
        let mutable = self.holdings.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.holdings = mutable.copy() as! NSSet
    }

    open func removeHoldings(_ objects: NSSet) {
        let mutable = self.holdings.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.holdings = mutable.copy() as! NSSet
    }

    open func addHoldingsObject(_ value: HoldingManagedObject) {
        let mutable = self.holdings.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.holdings = mutable.copy() as! NSSet
    }

    open func removeHoldingsObject(_ value: HoldingManagedObject) {
        let mutable = self.holdings.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.holdings = mutable.copy() as! NSSet
    }

}

