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


class Place : NSObject, Annotation {
    let coordinate:LocationCoordinate2D
    let category:Category
    let name:String
    
    init(coordinate:LocationCoordinate2D, category:Category, name:String) {
        self.coordinate = coordinate
        self.category = category
        self.name = name
    }
    
    convenience init(withData data:[String:Any]) throws {
        guard let latitude = data["lat"] as? Double,
            let longitude = data["lon"] as? Double,
            let categoryRaw = data["category"] as? String,
            let name = data["name"] as? String else {
                throw ModelError.SerializationError
        }

        let coordinate = LocationCoordinate2D(latitude: latitude, longitude: longitude)
        let category = Category(name: categoryRaw)
        
        self.init(coordinate:coordinate, category:category, name:name)
    }
}
