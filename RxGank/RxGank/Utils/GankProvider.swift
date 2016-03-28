//
// GankProvider.swift
//  RxGank
//
//  Created by DianQK on 16/2/23.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import Moya
import SwiftDate

#if DEBUG
let host = "http://gank.avosapps.com"
#else
let host = "http://gank.io"
#endif

public enum GankCategory: String {
    case 福利 = "福利"
    case Android = "Android"
    case iOS = "iOS"
    case 休息视频 = "休息视频"
    case 拓展资源 = "拓展资源"
    case 前端 = "前端"
    case all = "all"
}

extension GankCategory: RawRepresentable {
    
}

let GankProvider = RxMoyaProvider<GankAPI>(plugins: [NetworkLoggerPlugin()])

public enum GankAPI {
    case Category(GankCategory, Int, Int)
    case Day(NSDate)
    case Random(GankCategory, Int)
}

extension GankAPI: TargetType {
    public var baseURL: NSURL { return NSURL(string: host)! }
    public var path: String {
        switch self {
        case let .Category(type, count, page):
            return "/api/data/\(type.rawValue)/\(count)/\(page)"
        case let .Day(date):
            return "/api/day/" + date.toString(DateFormat.Custom("yyyy/MM/dd"))!
        case let .Random(type, count):
            return "/api/random/data/\(type.rawValue)/\(count)"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters: [String: AnyObject]? {
        return nil
    }
    
    public var sampleData: NSData {
        return "".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
