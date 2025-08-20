//
//  HashableCoordinate.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-07-13.
//

import CoreLocation

struct HashableCoordinate: Hashable {
    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
