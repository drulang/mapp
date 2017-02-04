//
//  ServiceProtocol.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation

struct LocationQuery {
    
}


enum LocationSearchError: Error {
    
}


protocol LoctionSearch {
    
    func placeSearch(query:LocationQuery, completion:([Place]?, LocationSearchError?)->Void)
    
}
