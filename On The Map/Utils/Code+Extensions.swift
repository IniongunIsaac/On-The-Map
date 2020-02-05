//
//  Code+Extensions.swift
//  On The Map
//
//  Created by Isaac Iniongun on 04/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation

func runOnUIThread(codeToExecute: @escaping () -> Void) {
    DispatchQueue.main.async {
        codeToExecute()
    }
}

extension Decodable {
    
    static func mapFrom(data: Data) throws -> Self? {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data.subdata(in: 5..<data.count))
    }
}
