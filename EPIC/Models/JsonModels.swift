//
//  JsonModels.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Foundation

struct JsonDate: Decodable, Hashable {
    let date:String
}

struct CentroidCoordinates: Decodable, Hashable {
    let lat:Double
    let lon:Double
}

struct J2000Position: Decodable, Hashable{
    let x:Double
    let y:Double
    let z:Double
}

struct AttitudeQuaternions: Decodable, Hashable {
    let q0:Double
    let q1:Double
    let q2:Double
    let q3:Double
}

struct Coords: Decodable, Hashable {
    let centroid_coordinates:CentroidCoordinates
    let dscovr_j2000_position:J2000Position
    let lunar_j2000_position:J2000Position
    let sun_j2000_position:J2000Position
    let attitude_quaternions:AttitudeQuaternions
    
    func structText()->[String] {
        return ["\(centroid_coordinates)","\(dscovr_j2000_position)","\(lunar_j2000_position)","\(sun_j2000_position)","\(attitude_quaternions)"]
    }
}

struct DayImageInfo: Decodable, Hashable {
    let identifier:String
    let caption:String
    let image:String
    let version:String
    let date:String
    let coords:Coords
}
