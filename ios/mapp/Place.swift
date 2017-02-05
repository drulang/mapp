//
//  Place.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation


enum ModelError : Error {
    case SerializationError
}


struct Category {
    let name:String
}


struct PlaceSerialization {
    static let CategoryName = "category_name"
    static let Latitude = "lat"
    static let Longitude = "lon"
    static let Name = "name"
}


//TODO: Use struct for place and create a PlaceAnnotation class to box Place and conforms to Annotation

class Place : NSObject, Annotation {
    let coordinate:LocationCoordinate2D
    let category:Category
    let name:String
    
    var title: String? {
        get {
            return name
        }
    }
    
    init(coordinate:LocationCoordinate2D, category:Category, name:String) {
        self.coordinate = coordinate
        self.category = category
        self.name = name
    }
    
    convenience init(withData data:[String:Any]) throws {
        guard let latitude = data[PlaceSerialization.Latitude] as? Double,
            let longitude = data[PlaceSerialization.Longitude] as? Double,
            let categoryRaw = data[PlaceSerialization.CategoryName] as? String,
            let name = data[PlaceSerialization.Name] as? String else {
                throw ModelError.SerializationError
        }

        let coordinate = LocationCoordinate2D(latitude: latitude, longitude: longitude)
        let category = Category(name: categoryRaw)
        
        self.init(coordinate:coordinate, category:category, name:name)
    }
}
