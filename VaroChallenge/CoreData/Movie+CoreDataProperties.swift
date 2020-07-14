//
//  Movie+CoreDataProperties.swift
//  VaroChallenge
//
//  Created by Hakim Joseph on 2/10/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie: MovieModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var imageLocation: URL
    @NSManaged public var title: String

}
