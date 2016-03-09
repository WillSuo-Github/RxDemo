//
//  GankModel.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import ObjectMapper

struct DayModel {
    var category: [String]!
    var results: [String: [GankModel]]!
}

struct GankModel {
    var _id: String!
    var _ns: String!
    var createdAt: String!
    var desc: String!
    var publishedAt: String!
    var type: GankCategory!
    var url: String!
    var used: Bool!
    var who: String!
}

extension DayModel: Mappable {
    init?(_ map: Map) { }
    
    mutating func mapping(map: Map) {
        category <- map["category"]
        results <- map["results"]
    }
}

extension GankModel: Mappable {
    init?(_ map: Map) { }
    
    internal mutating func mapping(map: Map) {
        _id <- map["_id"]
        _ns <- map["_ns"]
        createdAt <- map["createdAt"]
        desc <- map["desc"]
        publishedAt <- map["publishedAt"]
        type <- map["type"]
        url <- map["url"]
        used <- map["used"]
        who <- map["who"]
    }
}

extension GankModel: Hashable {
    var hashValue: Int {
        return _id.hashValue
    }
}

func ==(lhs: GankModel, rhs: GankModel) -> Bool {
    return lhs._id == rhs._id
}
