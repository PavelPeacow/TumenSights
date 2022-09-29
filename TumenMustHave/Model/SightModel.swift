//
//  SightModel.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import Foundation

struct Sight: Codable {
    let xid: String
    let name: String
    let rate: Int
    let wikidata: String
    let kinds: String
    
    let point: Points
}

struct Points: Codable {
    let lon: Double
    let lat: Double
}
