//
//  TableViewModelType.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/29.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

protocol TableViewModelType: class {
    
    associatedtype Model: Mappable
    
    var loadTriger: PublishSubject<Void>{get}
    var refreshTriger: PublishSubject<Void>{get}
    var loadMoreTriger: PublishSubject<Void>{get}
    
    var elements: Variable<[Model]>{get}
    var page: Variable<Int>{get}
    var hasNextPage: Variable<Bool>{get}
    
    var refreshing: Variable<Bool>{get}
    var loading: Variable<Bool>{get}
}
