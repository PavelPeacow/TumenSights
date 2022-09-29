//
//  APICaller.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    func fetchTumenSights(onCompletion: @escaping ([Sight]) -> Void) {
        
        guard let url = URL(string: "\(APIConstants.baseURL)/places/bbox?lon_min=65.411385&lon_max=65.738442&lat_min=57.076540&lat_max=57.249303&src_geom=wikidata&src_attr=wikidata&format=json&apikey=\(APIConstants.apiKey)") else {
            print("invalid url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard data == data, error == nil else {
                print("error")
                return
            }
            
            guard let results = try? JSONDecoder().decode([Sight].self, from: data!) else {
                print("loh")
                return
            }
            
//            print(results)
            
            onCompletion(results)
        }
        task.resume()
        
    }
    
}
