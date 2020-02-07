//
//  ApiClient.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import Foundation

class ApiClient {
    
    struct Auth {
        static var user: User?
        static var uniqueKey: String = ""
        static var shouldRefreshData = false
    }
    
    enum Endpoints {
        
        static let baseUrl = "https://onthemap-api.udacity.com/v1"
        
        case login
        case studentLocations(Int, String)
        case userData(String)
        case postStudentLocation
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.baseUrl + "/session"
            case .studentLocations(let limit, let order): return Endpoints.baseUrl + "/StudentLocation?limit=\(limit)&order=\(order)"
            case .userData(let userId): return Endpoints.baseUrl + "/users/\(userId)"
            case .postStudentLocation: return Endpoints.baseUrl + "/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    fileprivate class func getRequestTask<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, shouldSkip: Bool = true, completion: @escaping (ResponseType?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                runOnUIThread { completion(nil, error) }
                return
            }
            do {
                let responseObject = try ResponseType.mapFrom(data: data, shouldSkip: shouldSkip)
                runOnUIThread { completion(responseObject, nil) }
            } catch {
                runOnUIThread { completion(nil, error) }
            }
        }.resume()
    }
    
    fileprivate class func postRequestTask<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, shouldSkip: Bool = true, completion: @escaping (ResponseType?, Error?) -> Void) {
        
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
                let responseObject = try ResponseType.mapFrom(data: data, shouldSkip: shouldSkip)
                runOnUIThread { completion(responseObject, nil) }
            } catch {
                
                do {
                    let res = try MessageResponse.mapFrom(data: data, shouldSkip: shouldSkip)
                    runOnUIThread { completion(nil, res) }
                } catch {
                    runOnUIThread { completion(nil, error) }
                }
                
            }
            
        }.resume()
    }
    
    fileprivate class func deleteRequestTask<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
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
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        deleteRequestTask(url: Endpoints.login.url, responseType: SessionResponse.self) { response, error in
            
            if let _ = response {
                Auth.uniqueKey = ""
            }
            
            completion(response != nil, error ?? nil)
        }
    }
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: UdacityUserLoginCredentialsRequest(username: email, password: password))
        postRequestTask(url: Endpoints.login.url, responseType: LoginResponse.self, body: body) { response, error in
            
            if let response = response {
                Auth.uniqueKey = response.account.key
            }
            
            completion(response != nil, error ?? nil)
        }
    }
    
    class func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (Bool, Error?) -> Void) {
        let body = PostStudentLocationRequest(uniqueKey: Auth.uniqueKey, firstName: Auth.user!.firstName, lastName: Auth.user!.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        
        postRequestTask(url: Endpoints.postStudentLocation.url, responseType: PostStudentLocationResponse.self, body: body, shouldSkip: false) { response, error in
            if let _ = response {
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func getStudentLocations(limit: Int = 100, order: String = "-updatedAt", completionHandler: @escaping ([StudentLocation], Error?) -> Void) {
        getRequestTask(url: Endpoints.studentLocations(limit, order).url, responseType: StudentLocationResponse.self, shouldSkip: false) { response, error in
            if let response = response {
                completionHandler(response.results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    class func getUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        getRequestTask(url: Endpoints.userData(Auth.uniqueKey).url, responseType: User.self) { response, error in
            if let response = response {
                Auth.user = response
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
}
