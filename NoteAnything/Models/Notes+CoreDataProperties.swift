//
//  Notes+CoreDataProperties.swift
//  NoteAnything
//
//  Created by Rekeningku on 01/05/22.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var note: String?

}

extension Notes : Identifiable {

}
