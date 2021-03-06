//
//  CityMapAPI.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate struct API {
    struct Config {
        static let Host = "https://coresearch.citymaps.com"
    }
    
    struct Parameters {
        static let Latitude  = "lat"
        static let Longitude = "lon"
        static let Radius    = "radius"
        static let Zoom      = "zoom"
        static let Count     = "businesses"
        static let Items     = "items"
        static let CategoryName = "category_name"
        static let Name = "name"
    }
    
    struct Path {
        static let Search = "/search"
    }
}

fileprivate enum Router : URLRequestConvertible {
    case search(LocationQuery)
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case let .search(query):
                let parameters = [
                    API.Parameters.Latitude : query.coordinate.latitude,
                    API.Parameters.Longitude : query.coordinate.longitude,
                    API.Parameters.Count : query.count,
                    API.Parameters.Radius : query.radius,
                ] as [String : Any]
                
                let path = "\(API.Path.Search)/\(query.query)"
                
                return (path, parameters)
            }
        }()
        
        let url = try API.Config.Host.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))

        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}

class CityMapAPI { }


//MARK: LoctionSearchProtocol
extension CityMapAPI : LoctionSearchProtocol {
    
    func placeSearch(query:LocationQuery, completion:@escaping ([Place]?, LocationSearchError?)->Void) {
        // TODO: edge cases
        
        let urlRequest = Router.search(query)
        log.debug("Requesting: \(urlRequest)")
        
        Alamofire.request(urlRequest).responseJSON { (response) in
            switch response.result {
                
            case .success(let value):
                var places:[Place] = []
                
                let json = JSON(value)
                

                for (_, itemSubJson):(String, JSON) in json[API.Parameters.Items] {
                    
                    do {
                        let categoryName = itemSubJson[API.Parameters.CategoryName].string ?? ""
                        let name = itemSubJson[API.Parameters.Name].string ?? ""
                        let lat = itemSubJson[API.Parameters.Latitude].double ?? 0.0
                        let lon = itemSubJson[API.Parameters.Longitude].double ?? 0.0
                        
                        let convertedData:[String:Any] = [
                            PlaceSerialization.CategoryName : categoryName,
                            PlaceSerialization.Name : name,
                            PlaceSerialization.Latitude : lat,
                            PlaceSerialization.Longitude : lon
                        ]
                        
                        let place = try Place(withData: convertedData)
                        
                        places.append(place)
                    } catch {
                        completion(nil, LocationSearchError.SerializationError)
                    }
                }
                
                completion(places, nil)
            case .failure(let error):
                log.error(error)
                completion(nil, LocationSearchError.NetworkError)

            }
        }
    }
    
}
