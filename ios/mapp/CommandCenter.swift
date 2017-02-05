//
//  CommandCenter.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation

class CommandCenter {
    
    static let shared = CommandCenter()
    
    fileprivate let primaryLocationSearch = CityMapAPI()
}


extension CommandCenter : LoctionSearchProtocol {

    /*
     Eventuall this abstraction can be used to pull data from other sources
     besides the CityMapAPI. (i.e a local store)
     */
    func placeSearch(query: LocationQuery, completion: @escaping ([Place]?, LocationSearchError?) -> Void) {
        primaryLocationSearch.placeSearch(query: query, completion: completion)
    }

}
