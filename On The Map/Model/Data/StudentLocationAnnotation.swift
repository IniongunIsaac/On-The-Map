//
//  StudentLocationAnnotation.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation
import MapKit

final class StudentLocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}
