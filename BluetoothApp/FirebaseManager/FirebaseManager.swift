//
//  FirebaseManager.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 23/09/22.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

final public class FirebaseManager {

    static let shared = FirebaseManager()
    
    private init() { /* empty init */ }

    /// Update location in firebase database.
    func updateLocation(
        longitude: String,
        latitude: String,
        country: String,
        city: String,
        street: String,
        areasOfInterest: [String?],
        subLocality: String
    ) {
        let ref = Database.database().reference().child("CurrentLocation")
        let currentLocationModel = [
            "city": "\(city)",
            "country": "\(country)",
            "latitude": "\(latitude)",
            "longitude": "\(longitude)",
            "street": "\(street)",
            "areasOfInterest": areasOfInterest,
            "subLocality": subLocality,
        ] as [String : Any]
        ref.setValue(currentLocationModel)
    }
}
