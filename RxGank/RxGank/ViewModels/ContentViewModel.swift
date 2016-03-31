//
//  ContentViewModel.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxOptional

typealias ContentSectionModel = AnimatableSectionModel<String, GankModel>

typealias 没卵用 = Int

class ContentViewModel {
    
    let elements = Variable([ContentSectionModel]())
    let image = Variable<UIImage?>(nil)
    
    let loading = Variable<Bool>(false)
    let imageLoading = Variable<Bool>(false)
    
    let day = Variable<NSDate>(NSDate())
    
    let loadTriger = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(inputDay: Driver<NSDate>) { // 这个 d 并没有什么用，就是占个坑
        
        let data = inputDay
            .flatMapLatest { GankProvider.request(.Day($0)).mapObject(DayModel) }
        
        data.driveNext {
            if case let .Success(data) = $0 {
                self.elements.value = data.results.map { ContentSectionModel(model: $0.0, items: $0.1) }
            }
        }.addDisposableTo(disposeBag)
        
        data.flatMapLatest { result -> Driver<NSURLRequest> in
            if case let .Success(data) = result {
                return Driver.just(NSURLRequest(URL: NSURL(string: data.results["福利"]!.first!.url)!))
            } else {
                return Driver.empty()
            }
            }.flatMapLatest { NSURLSession.sharedSession().rx_data($0).map { UIImage(data: $0) }.asDriver(onErrorJustReturn: nil) }
            .driveNext {
                self.image.value = $0
            }
            .addDisposableTo(disposeBag)
        
        [inputDay.map { _ in true }, data.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loadTriger)
            .addDisposableTo(disposeBag)
        
        [data.asObservable().map { _ in true }, image.asObservable().map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(imageLoading)
            .addDisposableTo(disposeBag)

    }
    
}
