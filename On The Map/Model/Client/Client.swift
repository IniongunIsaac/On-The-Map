//
//  Client.swift
//  On The Map
//
//  Created by Isaac Iniongun on 04/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation

class Client {
    
    enum Endpoints {
        
        static let baseUrl = "https://onthemap-api.udacity.com/v1"
        
        case login
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.baseUrl + "/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
     fileprivate class func getRequestTask<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                runOnUIThread { completion(nil, error) }
                return
            }
            do {
                let responseObject = try ResponseType.mapFrom(data: data)
                runOnUIThread { completion(responseObject, nil) }
            } catch {
                runOnUIThread { completion(nil, error) }
            }
        }.resume()
    }
    
    fileprivate class func postRequestTask<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                runOnUIThread { completion(nil, error) }
                return
            }
            
            do {
                let responseObject = try ResponseType.mapFrom(data: data)
                runOnUIThread { completion(responseObject, nil) }
            } catch {
                
                do {
                    let res = try MessageResponse.mapFrom(data: data)
                    runOnUIThread { completion(nil, res) }
                } catch {
                    runOnUIThread { completion(nil, error) }
                }
                
            }
            
        }.resume()
    }
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: UdacityUserLoginCredentialsRequest(username: email, password: password))
        postRequestTask(url: Endpoints.login.url, responseType: LoginResponse.self, body: body) { response, error in
            completion(response != nil, error ?? nil)
        }
    }
    
}
