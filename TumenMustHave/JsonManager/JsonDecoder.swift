//
//  JsonDecoder.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import Foundation

class JsonDecoder {
    static let shared = JsonDecoder()
    
    private let fileURL = Bundle.main.url(forResource:"SightCollection", withExtension: "json")
    
    func getJsonData() -> [Sight]? {
        guard let fileURL = fileURL else {
            print("loh1")
            return nil
        }
        guard let data = try? Data(contentsOf: fileURL) else { print("loh2"); return nil  }
        guard let result = try? JSONDecoder().decode([Sight].self, from: data) else {
            print("loh3")
            return nil
        }
        return result
    }
}
