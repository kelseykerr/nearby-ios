//
//  AlamofireRequest+JSONSerializable.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/4/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol ResponseJSONObjectSerializable {
    init?(json: SwiftyJSON.JSON)
}

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

extension Alamofire.DataRequest {
    
    public func responseObject<T: ResponseJSONObjectSerializable>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let serializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Object could not be serialized because input data was nil."
//                let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: failureReason)
                let error = BackendError.dataSerialization(error: error!)
                return .failure(error)
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response,
                responseData, error)
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                if let errorMessage = json["message"].string {
//                    let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: errorMessage)
                    let error = BackendError.dataSerialization(error: error!)
                    return .failure(error)
                }
                guard let object = T(json: json) else {
//                    let failureReason = "Object could not be created from JSON."
//                    let error = Alamofire.Error.errorWithCode(.jsonSerializationFailed, failureReason: failureReason)
//                    let error = BackendError.jsonSerialization(error: error!)
                    let error2 = BackendError.jsonSerialization(error: error!)
                    return .failure(error2)
                }
                return .success(object)
            }
        }
        return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    public func responseArray<T: ResponseJSONObjectSerializable>(_ completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let serializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            guard let responseData = data else {
//                let failureReason = "Object could not be serialized because input data was nil."
//                let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: failureReason)
                let error = BackendError.dataSerialization(error: error!)
                return .failure(error)
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response,
                responseData, error)
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                
                print(json)
                
                
                if let errorMessage = json["message"].string {
//                    let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: errorMessage)
                    let error2 = BackendError.dataSerialization(error: error!)
                    return .failure(error2)
                }
                var objects: [T] = []
                for (_, item) in json {
                    if let object = T(json: item) {
                        objects.append(object)
                    }
                }
                return .success(objects)
            }
        }
        return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
}
