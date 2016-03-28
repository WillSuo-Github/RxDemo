//
//  GirlViewModel.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa

class GirlViewModel {
    
    let elements = Variable([GankModel]())
    let page = Variable(1)
    
    let refreshing = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    
    let loadTriger = PublishSubject<Void>()
    let refreshTriger = PublishSubject<Void>()
    let loadMoreTriger = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(
        input: (
        refreshTriger: Observable<Void>,
        loadMoreTriger: Observable<Void>
        )
        ) {
        
        input.refreshTriger
            .bindTo(refreshTriger)
            .addDisposableTo(disposeBag)
        
        input.loadMoreTriger
            .bindTo(loadMoreTriger)
            .addDisposableTo(disposeBag)
        
        let refreshRequest = refreshTriger
            .map {1}
            .shareReplay(1)
        
        let refreshData = refreshRequest
            .flatMapLatest { GankProvider.request(.Category(.福利, Config.Load.pages, $0)) }
            .mapArray(GankModel)
            .shareReplay(1)
        
        let loadMoreRequest = [loadMoreTriger, loadTriger].toObservable()
            .merge()
            .withLatestFrom(page.asObservable())
        
        
        let loadMoreData = loadMoreRequest
            .flatMapLatest { GankProvider.request(.Category(.福利, Config.Load.pages, $0)) }
            .mapArray(GankModel)
            .shareReplay(1)
        
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
        
        [refreshData.map { ($0, true) },
        loadMoreData.map { ($0, false) }]
            .toObservable()
            .merge()
            .scan(elements.value) { $1.1 ? $1.0 : $0 + $1.0 }
            .bindTo(elements).addDisposableTo(disposeBag)
        
    }
    
}
