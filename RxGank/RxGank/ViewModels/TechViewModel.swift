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
    let hasNextPage = Variable(true)
    
    private let disposeBag = DisposeBag()
    
    init(
        input: (
        refreshTriger: Driver<Void>,
        loadMoreTriger: Driver<Void>,
        categoryChangeTriger: Driver<GankCategory>
        )
        ) {
        
        input.categoryChangeTriger.driveNext {  [unowned self] category in
            self.category.value = category
            self.elements.value = []
            self.page.value = 1
        }.addDisposableTo(disposeBag)
        
        
        let categoryRequest = input.categoryChangeTriger.map { (category: $0, page: 1) }
        
        let categoryData = categoryRequest.flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)).mapArray(GankModel) }
        
        let refreshRequest = input.refreshTriger
            .map {1}
        
        let refreshData = refreshRequest.map { [unowned self] in (category: self.category.value, page: $0) }
            .flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)).mapArray(GankModel) }
        
        
        let loadMoreRequest = input.loadMoreTriger
            .withLatestFrom(page.asDriver())
        
        let loadMoreData = loadMoreRequest.map { [unowned self] in (category: self.category.value, page: $0) }
            .flatMapLatest { GankProvider.request(.Category($0.category, Config.Tech.pages, $0.page)).mapArray(GankModel) }
        
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
        
        [loadMoreRequest.map { _ in true }, loadMoreData.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        refreshData.driveNext { [unowned self] in
            if case let .Success(data) = $0 {
                self.page.value = 2
                self.elements.value = data
                if data.isEmpty {
                    self.hasNextPage.value = false
                }
            }
            }.addDisposableTo(disposeBag)
        
        loadMoreData.driveNext { [unowned self] in
            if case let .Success(data) = $0 {
                self.page.value += 1
                self.elements.value += data
                if data.isEmpty {
                    self.hasNextPage.value = false
                }
            }
            }.addDisposableTo(disposeBag)
        
        categoryData.driveNext { [unowned self] in
            if case let .Success(data) = $0 {
                self.page.value = 2
                self.elements.value = data
                if data.isEmpty {
                    self.hasNextPage.value = false
                }
            }
            }.addDisposableTo(disposeBag)
        
    }
    
}
