//
//  TechViewModel.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa

class TechViewModel {
    
    let elements = Variable([GankModel]())
    let page = Variable(1)
    
    let refreshing = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let category = Variable<GankCategory>(.iOS)
    
    let loadTriger = PublishSubject<Void>()
    let refreshTriger = PublishSubject<Void>()
    let loadMoreTriger = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(
        input: (
        refreshTriger: Observable<Void>,
        loadMoreTriger: Observable<Void>,
        categoryChangeTriger: Observable<GankCategory>
        )
        ) {
        
        input.refreshTriger
            .bindTo(refreshTriger)
            .addDisposableTo(disposeBag)
        
        input.loadMoreTriger
            .bindTo(loadMoreTriger)
            .addDisposableTo(disposeBag)
        
        input.categoryChangeTriger
            .bindTo(category)
            .addDisposableTo(disposeBag)
        
        let categoryChange = category.asObservable().shareReplay(1)
        
        categoryChange.map { _ in [] }
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        categoryChange.map { _ in 1 }
            .bindTo(page)
            .addDisposableTo(disposeBag)
        
        let categoryRequest = categoryChange.map { (category: $0, page: 1) }
            .shareReplay(1)
        
        let categoryData = categoryRequest.flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)) }
            .mapArray(GankModel)
            .shareReplay(1)
        
        let refreshRequest = refreshTriger
            .map {1}
            .shareReplay(1)
        
        let refreshData = refreshRequest.map { [unowned self] in (category: self.category.value, page: $0) }
            .flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)) }
            .mapArray(GankModel)
            .shareReplay(1)
        
        let loadMoreRequest = [loadMoreTriger, loadTriger].toObservable()
            .merge()
            .withLatestFrom(page.asObservable())
        
        let loadMoreData = loadMoreRequest.map { [unowned self] in (category: self.category.value, page: $0) }
            .flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)) }
            .mapArray(GankModel)
            .shareReplay(1)
        
        [categoryRequest.map { _ in true }, categoryData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        [refreshRequest.map { _ in true }, refreshData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(refreshing)
            .addDisposableTo(disposeBag)
        
        [refreshData.map { _ in true }, loadMoreData.map { _ in false }]
            .toObservable()
            .merge()
            .scan(page.value) { $1 ? 2 : $0 + 1 }
            .bindTo(page)
            .addDisposableTo(disposeBag)
        
        [loadMoreRequest.map { _ in true }, loadMoreData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        [refreshData.map { ($0, true) }, loadMoreData.map { ($0, false) }, categoryData.map { ($0, true) }]
            .toObservable()
            .merge()
            .scan(elements.value) { $1.1 ? $1.0 : $0 + $1.0 }
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
    }
    
}
