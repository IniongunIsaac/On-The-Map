//
//  PostStudentLocationRequest.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
// "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}"

import Foundation

struct PostStudentLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude, longitude: Double
}
