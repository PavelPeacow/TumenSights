//
//  JsonDecoder.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import Foundation

enum DecoderError: Error {
    case badUrl
    case canNotGetData
    case canNotDecodeData
}

class JsonConstant {
    static let fileURL = Bundle.main.url(forResource:"SightCollection", withExtension: "json")
}

class JsonDecoder {

    func getJsonData(with url: URL?) throws -> [Sight] {
        guard let fileURL = url else { throw DecoderError.badUrl }
        
        guard let data = try? Data(contentsOf: fileURL) else { throw DecoderError.canNotGetData }
        
        guard let result = try? JSONDecoder().decode([Sight].self, from: data) else { throw DecoderError.canNotDecodeData }
        
        return result
    }
}
