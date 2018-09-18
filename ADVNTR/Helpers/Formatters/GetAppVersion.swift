//
//  GetAppVersion.swift
//  ADVNTR
//
//  Created by Owen Henley on 9/18/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation

class GetAppVersion {
    
    static let kVersion = "CFBundleShortVersionString"
    static let kBuildNumber = "CFBundleVersion"
    
    static func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        let build = dictionary[kBuildNumber] as! String
        print(version + build)
        return "\(version)"
    }
}
