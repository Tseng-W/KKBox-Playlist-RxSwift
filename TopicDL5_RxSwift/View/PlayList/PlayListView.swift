//
//  PlayListView.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/5.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class PlayListView: UIView {
    
    enum LoadingStatus {
        case wait
        case loading
        case noMore
    }
    
    var bag = DisposeBag()
    
    var reloadingSubject = BehaviorSubject<LoadingStatus>(value: .wait)
    
    let headerImageUrl = "https://i.kfs.io/playlist/global/26541395v266/cropresize/600x600.jpg"
    
    var data: [Song] = []
    
    var favorites: [String] = []
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.contentInsetAdjustmentBehavior = .never
            
            tableView.nib_registerCell(
                nibName: String(describing: PlayListTableViewCell.self),
                bundle: nil)
            tableView.nib_registerCell(
                nibName: String(describing: PlayListTableViewHeader.self),
                bundle: nil)
            
            tableView.mj_footer = MJRefreshAutoGifFooter(refreshingBlock: {
                self.tableView.mj_footer?.beginRefreshing()
                self.reloadingSubject.onNext(.loading)
            })
            
            reloadingSubject.subscribe { event in
                if event.element! == .wait {
                    self.tableView.mj_footer?.endRefreshing()
                } else if event.element! == .noMore {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }.disposed(by: bag)
            
            tableView.rx.contentOffset.asObservable()
                .subscribe { [self] offset in
                    let topcell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                    if offset.y < 0 {
                        topcell?.frame.size.height = 500 - offset.y
                        topcell?.frame.origin.y = offset.y
                    } else {
                        topcell?.alpha = (500 - offset.y) / 500
                    }
                }  onDisposed: {
                    print("tableView disposed")
                }.disposed(by: bag)
            
            tableView.rx.itemSelected
                .subscribe { indexPath in
                    self.tableView.cellForRow(at: indexPath)?.isSelected = false
                }  onDisposed: {
                    print("tableView disposed")
                }.disposed(by: bag)
        }
    }
    
    func bindTableView(songs: [Song]) {
        
        if data.count == 0 {
            data = songs
            data.insert(songs.first!, at: 0)
        } else {
            data += songs
        }
        
        tableView.dataSource = nil
        Observable.of(data)
            .bind(to: tableView.rx.items) { [self] (tableView, row, element) in
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlayListTableViewHeader.self)) as! PlayListTableViewHeader
                    cell.titleImage.setImage(url: headerImageUrl)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlayListTableViewCell.self)) as! PlayListTableViewCell
                    cell.songImage.setImage(url: element.album.images.first!.url)
                    cell.songNameLabel.text = element.name
                    cell.isFavorited = favorites.contains(element.id)
                    cell.favoriteButton.rx.tap.asObservable()
                        .subscribe {
                            if favorites.contains(element.id) {
                                favorites.remove(at: favorites.firstIndex(of: element.id)!)
                            } else {
                                favorites.append(element.id)
                            }
                            cell.isFavorited = favorites.contains(element.id)
                        } onDisposed: {
                        }.disposed(by: cell.bag)
                    return cell
                }
            }.disposed(by: bag)
    }
}


extension PlayListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 500
        }
        return 100
    }
}
