//
//  Quake.swift
//  Quakes
//
//  Created by Dimitri Bouniol Lambda on 1/22/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation
import MapKit

struct QuakeResults: Decodable {
    let features: [Quake]
}

class Quake: NSObject, Decodable {
    
    let magnitude: Double
    let place: String
    let time: Date
    let latitude: Double
    let longitude: Double
    let identifier: String
    
    
//    internal init(magnitude: Double, place: String, time: Date, latitude: Double, longitude: Double) {
//        self.magnitude = magnitude
//        self.place = place
//        self.time = time
//        self.latitude = latitude
//        self.longitude = longitude
//    }
    
    enum QuakeCodingKeys: String, CodingKey {
        case id
        
        case properties
        case mag
        case place
        case time
        case geometry
        case coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QuakeCodingKeys.self)
        
        self.identifier = try container.decode(String.self, forKey: .id)
        
        let properties = try container.nestedContainer(keyedBy: QuakeCodingKeys.self, forKey: .properties)
        
        self.magnitude = (try? properties.decode(Double.self, forKey: .mag)) ?? -1
        self.place = try properties.decode(String.self, forKey: .place)
        self.time = try properties.decode(Date.self, forKey: .time)
        
        let geometry = try container.nestedContainer(keyedBy: QuakeCodingKeys.self, forKey: .geometry)
        
        var coordinates = try geometry.nestedUnkeyedContainer(forKey: .coordinates)
        
        self.longitude = try coordinates.decode(Double.self)
        self.latitude = try coordinates.decode(Double.self)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Quake else { return false }
        
        return self.identifier == object.identifier
    }
    
    override var hash: Int {
        identifier.hashValue
    }
}

extension Quake: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { place }
    
    var subtitle: String? { "Magnitude: \(magnitude)" }
}
