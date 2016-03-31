//
//  Response+ObjectMapper.swift
//  PalmCivet
//
//  Created by DianQK on 16/2/4.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import Moya
import ObjectMapper

public struct GankError: ErrorType {
    let message: String?
}

public enum GankResult<T> {
    case Success(T)
    case Failure(GankError)
}

public extension Response {
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: Mappable>() throws -> GankResult<T> {
        guard let json = try mapJSON() as? [String: AnyObject] else {
            throw Error.JSONMapping(self)
//            return .Failure(GankError(message: "解析 JSON 错误"))
        }
        guard let object = Mapper<T>().map(json) else {
            throw Error.Data(self)
//            return .Failure(GankError(message: "解析 Model 错误"))
        }
        return .Success(object)
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: Mappable>() throws -> GankResult<[T]> {
        guard let json = try mapJSON() as? [String: AnyObject] else {
            throw Error.JSONMapping(self)
//            return .Failure(GankError(message: "解析 JSON 错误"))
        }
        guard let object = Mapper<T>().mapArray(json["results"]) else {
            throw Error.Data(self)
//            return .Failure(GankError(message: "解析 Model 错误"))
        }
        return .Success(object)
    }
    
}