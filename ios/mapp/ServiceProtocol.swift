//
//  ServiceProtocol.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation

struct LocationQuery {
    var coordinate:LocationCoordinate2D
    var query:String
    var radius = 20
    var zoom = 15
    var count = 10
}


enum LocationSearchError: Error {
    case SerializationError
    case NetworkError
}


protocol LoctionSearchProtocol {
    
    func placeSearch(query:LocationQuery, completion:@escaping ([Place]?, LocationSearchError?)->Void)
    
}
