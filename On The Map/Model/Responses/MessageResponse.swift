//
//  MessageResponse.swift
//  On The Map
//
//  Created by Isaac Iniongun on 05/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation

struct MessageResponse: Codable {
    let status: Int
    let error: String
}

extension MessageResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
