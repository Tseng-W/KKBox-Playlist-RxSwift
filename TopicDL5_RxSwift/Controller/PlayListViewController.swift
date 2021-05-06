//
//  ViewController.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/4.
//

import UIKit
import RxSwift
import Moya

class PlayListViewController: UIViewController {
    
    let bag = DisposeBag()

    @IBOutlet var playListView: PlayListView!
    
    var songList: [Song] = []
    
    var nextPaging: Int? = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        KKBoxProviderManager.shared.fetchAccesToken()
        
        KKBoxProviderManager.shared.hitsSubject
            .subscribe { [self] songs in
                self.songList += songs.element!
                self.playListView.bindTableView(songs: songList)
            }.disposed(by: bag)
        
        
        KKBoxProviderManager.shared.nextPagingSubject
            .subscribe { next in
                self.nextPaging = next
                if next == nil {
                    self.playListView.reloadingSubject.onNext(.noMore)
                } else {
                    self.playListView.reloadingSubject.onNext(.wait)
                }
            } onDisposed: {
                print("nextPagingSubject disposed")
            }.disposed(by: bag)

        
        playListView.reloadingSubject
            .subscribe { status in
                if status.element == .loading {
                    KKBoxProviderManager.shared.fetchHits(nextPaging: self.nextPaging)
                }
            }.disposed(by: bag)
    }
}
