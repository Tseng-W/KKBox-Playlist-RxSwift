//
//  KKBoxProvider.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/5.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

struct VerbosePlugin: PluginType {
    let verbose: Bool

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        #if DEBUG
        if let body = request.httpBody,
           let str = String(data: body, encoding: .utf8) {
            print("request to send: \(str))")
        }
        #endif
        return request
    }
}

class KKBoxProviderManager {
    
    static let shared = KKBoxProviderManager()
    
    var hitsSubject = PublishSubject<[Song]>()
    
    var nextPagingSubject = PublishSubject<Int?>()
    
    private let bag = DisposeBag()
        
    private var accessTokenSubject = PublishSubject<String>()
    
    private var songs: [Song]?
    
    private var accessToken: String?
    
    private var hitsRequest: KKBox.GetNewHits?
    
    private let accessRequest = KKBox.GetAccessToken(
        id: "570231f7f0ce67aca46350c841e1a8c9",
        secret: "399baeaab68d7d8d03b3df99ccaea5b5")
    
    private let tokenProvider = MoyaProvider<KKBox.GetAccessToken>(plugins: [VerbosePlugin(verbose: false)])
    
    private let hitsProvider = MoyaProvider<KKBox.GetNewHits>(plugins: [VerbosePlugin(verbose: true)])
    
    func fetchAccesToken() {
        
        accessTokenSubject
            .subscribe { token in
                self.accessToken = token.element!
                self.fetchHits()
            }.disposed(by: bag)
        
        tokenProvider.rx.request(accessRequest)
            .filterSuccessfulStatusCodes()
            .map(AccessTokenResponse.self)
            .subscribe { token in
                self.accessTokenSubject.onNext("\(token.tokenType) \(token.accessToken)")
            } onError: { error in
                print(error)
            }.disposed(by: bag)
    }
    
    func fetchHits(nextPaging: Int? = 0) {
        
        guard let token = accessToken,
              let nextPaging = nextPaging else { return }
        
        let hits = KKBox.GetNewHits(token: token, offset: nextPaging)

        hitsProvider.rx.request(hits)
            .filterSuccessfulStatusCodes()
            .map(HitsResponse.self)
            .subscribe { response in
                if response.paging.next != nil {
                    self.nextPagingSubject.onNext(nextPaging + 20)
                } else {
                    self.nextPagingSubject.onNext(nil)
                }
                
                self.hitsSubject.onNext(response.data)
            } onError: { error in
                print(error)
            }.disposed(by: bag)
    }
}
