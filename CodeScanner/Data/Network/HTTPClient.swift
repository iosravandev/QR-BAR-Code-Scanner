//
//  HTTPClient.swift
//  CodeScanner
//
//  Created by Ravan on 15.10.25.
//

import Foundation

protocol HTTPClient {
    func get(url: URL) async throws -> (Data, URLResponse)
}

struct URLSessionHTTPClient: HTTPClient {
    func get(url: URL) async throws -> (Data, URLResponse) {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}
