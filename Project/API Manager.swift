//
//  API Helper.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 08/09/23.
//

import Foundation
import UIKit

protocol AlertPresentable {
    func showAlert(title: String, message: String)
}


/// An enumeration HTTPMethod is defined to represent common HTTP request methods (GET, POST, PUT, DELETE). This makes it easier to specify the desired method when making requests.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    // Add other HTTP methods as needed
}


/// The APIManager class is designed as a singleton, which means there can be only one instance of this class in your application.
/// The private init() method ensures that no external code can create instances of APIManager
class APIManager{
    static let shared = APIManager()
    var viewController: AlertPresentable?
    
    private init() {}
    
    
    /// This method is the core of the API manager and is used to make HTTP requests
    /// - Parameters:
    ///   - url: The URL for the HTTP request.
    ///   - params:  A dictionary of query parameters to be included in the URL.
    ///   - method: The HTTP request method fro the above enum
    ///   - headers: An optional dictionary of HTTP headers to include in the request.
    ///   - requestBody: An optional data object representing the request body.
    ///   - completion: A closure (callback) that is called when the request is complete, passing a Result object that can contain either the response data or an error.
    func APIHelper(url: String,params: [String:Any], method: HTTPMethod , headers: [String:String]?, requestBody: Data?, completion: @escaping (Result<Data, Error>) -> Void){
        
        //        This line initializes an empty array called queryItems to store URL query items. Query items are key-value pairs that are used to pass parameters in the URL.
        var queryItems : [URLQueryItem] = []
        
        // dict from the apihelper method (param) is converted into the urlqueryitem and appended into the queryitems
        for parameter in params{
            let queryItem = URLQueryItem(name: parameter.key, value: parameter.value as? String)
            queryItems.append(queryItem)
        }
        
        
        var urlComponents = URLComponents(string: url )
        // This line sets the queryItems array as the query items of the urlComponents
        urlComponents?.queryItems = queryItems
        
        //         A URLRequest is created with the URL generated from urlComponents. This sets up the initial request with the base URL and the query parameters.
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = method.rawValue
        request.httpBody = requestBody
        
        //This code block checks if any HTTP headers are provided in the headers parameter. If headers are provided, they are added to the request using the request.setValue(value, forHTTPHeaderField: key) method.
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        //print(urlComponents?.url! ?? "default url")
        
        // creating a URLSession instance using the .shared static property. URLSession is part of the Foundation framework and is responsible for making network requests
        let session = URLSession.shared
        
        //You're creating a data task with the given request. A data task is used to fetch data from a specified URL. The task is asynchronous, meaning it won't block the main thread while fetching data. The task takes a closure that's called when the task completes.
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            
            if let httpResponse = response as? HTTPURLResponse  {
                let responseStatusCode = httpResponse.statusCode
                if responseStatusCode == 503{
                    DispatchQueue.main.async {
                        self.viewController?.showAlert(title: "Alert", message: "Server is Busy")
                    }
                }
                print("Statuscode :\(httpResponse.statusCode)")
            }
            
            do {
                if let data = data{
                    
                    var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    //                    print("the json:\(json)")
                    completion(.success(data))
                }else {
                    let error = NSError(domain: "InvalidData", code: 0, userInfo: nil)
                    completion(.failure(error))
                }
            }catch {
                completion(.failure(error))
            }
        }
        
        dataTask.resume()
    }
    
}
