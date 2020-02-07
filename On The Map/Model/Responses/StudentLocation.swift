//
//  StudentLocation.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation

struct StudentLocation: Codable {
    let firstName, lastName: String
    let latitude, longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId, uniqueKey: String
    let createdAt, updatedAt: String
}

extension StudentLocation {
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
