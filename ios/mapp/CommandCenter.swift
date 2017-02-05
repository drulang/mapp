//
//  CommandCenter.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation

class CommandCenter {
    
    let shared = CommandCenter()
    
    fileprivate let primaryLocationSearch = CityMapAPI()
    
}


extension CommandCenter : LoctionSearchProtocol {

    func placeSearch(query: LocationQuery, completion: @escaping ([Place]?, LocationSearchError?) -> Void) {
        primaryLocationSearch.placeSearch(query: query, completion: completion)
    }

}
