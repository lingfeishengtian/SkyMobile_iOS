//
//  DownloadUtility.swift
//  SkyMobile
//
//  Created by Hunter Han on 4/24/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import Foundation

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

class LatestVersionChecker{
    static func isUpdateAvailable(completion: @escaping (String?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        print(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
