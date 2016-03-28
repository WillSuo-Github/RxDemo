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
    
    init(input: (day: Observable<NSDate>, d: 没卵用)) { // 这个 d 并没有什么用，就是占个坑
        
        input.day
            .bindTo(day)
            .addDisposableTo(disposeBag)
        
        let request = day.asObservable()
            .shareReplay(1)
        
        let data = request
            .flatMapLatest { GankProvider.request(.Day($0)) }
            .mapObject(DayModel)
            .shareReplay(1)
            
        data.map { $0.results.map { ContentSectionModel(model: $0.0, items: $0.1) } }
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        let imageRequest = data.map { $0.results["福利"]?.first?.url }.filterNil()
            .map { NSURL(string: $0) }.filterNil()
            .map { NSURLRequest(URL: $0) }
            .shareReplay(1)
        
        imageRequest
            .flatMapLatest { NSURLSession.sharedSession().rx_data($0) }
            .map { UIImage(data: $0) }
            .bindTo(image)
            .addDisposableTo(disposeBag)
        
        [request.map { _ in true }, data.map { _ in false }]
            .toObservable()
            .merge()
            .bindTo(loadTriger)
            .addDisposableTo(disposeBag)
        
        [imageRequest.map { _ in true }, image.asObservable().map { _ in false}]
            .toObservable()
            .merge()
            .bindTo(imageLoading)
            .addDisposableTo(disposeBag)

    }
    
}
