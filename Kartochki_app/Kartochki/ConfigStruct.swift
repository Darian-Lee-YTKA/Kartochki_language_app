//
//  ConfigStruct.swift
//  Kartochki
//
//  Created by Darian Lee on 7/22/24.
//

import Foundation

struct Config {
    static var googleAPIKey: String {
        guard let filePath = Bundle.main.path(forResource: "config", ofType: "plist") else {
            fatalError("Couldn't find file 'config.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "GoogleAPIKey") as? String else {
            fatalError("Couldn't find key 'GoogleAPIKey' in 'config.plist'.")
        }
        return value
    }
}
