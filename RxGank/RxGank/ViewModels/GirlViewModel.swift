//
//  GirlViewModel.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya

class GirlViewModel {
    
    let elements = Variable([GankModel]())
    let page = Variable(1)
    let hasNextPage = Variable(true)
    
    let refreshing = Variable(false)
    let loading = Variable(false)
    
    private let disposeBag = DisposeBag()
    
    init(
        input: (
        refreshTriger: Driver<Void>,
        loadMoreTriger: Driver<Void>
        )
        ) {
        
        
        let refreshRequest = input.refreshTriger
            .map {1}
        
        let refreshData = refreshRequest
            .flatMapLatest { GankProvider.request(.Category(.福利, Config.Girl.pages, $0)).mapArray(GankModel) }
        
        let loadMoreRequest = input.loadMoreTriger
            .withLatestFrom(page.asDriver())
        
        let loadMoreData = loadMoreRequest
            .flatMapLatest { GankProvider.request(.Category(.福利, Config.Girl.pages, $0)).mapArray(GankModel) }
        
        refreshData.driveNext {
            if case let .Success(data) = $0 {
                self.page.value = 2
                self.elements.value = data
            }
            }.addDisposableTo(disposeBag)
        
        loadMoreData.driveNext {
            if case let .Success(data) = $0 {
                self.page.value += 1
                self.elements.value += data
                if data.isEmpty {
                    self.hasNextPage.value = false
                }
            }
            }.addDisposableTo(disposeBag)
        
        [refreshRequest.map { _ in true }, refreshData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(refreshing)
            .addDisposableTo(disposeBag)
        
        [loadMoreRequest.map { _ in true }, loadMoreData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        
    }
    
}
