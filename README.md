# KKBox-Playlist-RxSwift
> 透過 RxSwift 架構串接 KKBox API 撈取熱門播放清單並逐筆顯示

### KKBox API 串接
以 Moya 格式定義`取得 Token`與`取得播放清單`請求內容
```swift
enum KKBox {
    struct GetAccessToken: KKBoxAccountTargetType {
        
        typealias ResponseType = AccessTokenResponse
        
        var path: String { return "/oauth2/token" }
        
        var method: Moya.Method { return .post }
        
        var task: Task { return .requestParameters(parameters: data, encoding: URLEncoding.default) }
        
        private var data: [String: String] = [:]
        
        init(id: String, secret: String) {
            data["grant_type"] = "client_credentials"
            data["client_id"] = id
            data["client_secret"] = secret
        }
    }
...
}

class KKBoxProviderManager {
  private let tokenProvider = MoyaProvider<KKBox.GetAccessToken>(plugins: [VerbosePlugin(verbose: false)])
    
  private let hitsProvider = MoyaProvider<KKBox.GetNewHits>(plugins: [VerbosePlugin(verbose: true)])
}
```

透過`tokenProvider`取得 token
```swift
tokenProvider.rx.request(accessRequest)
  .filterSuccessfulStatusCodes()
  .map(AccessTokenResponse.self)
  .subscribe { token in
    self.accessTokenSubject.onNext("\(token.tokenType) \(token.accessToken)")
  } onError: { error in
    print(error)
  }.disposed(by: bag)
```

並撰寫播放清單抓取函式，一次抓取 20 首歌
```swift
func fetchHits(nextPaging: Int? = 0) {
  ...
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
```

### Table 資料匹配

於 ViewController 內`subscribe hitsSubject`，將`[Song]`傳入 UIView 中
```swift
KKBoxProviderManager.shared.hitsSubject
  .subscribe { [self] songs in
    self.songList += songs.element!
    self.playListView.bindTableView(songs: songList)
}.disposed(by: bag)
```

同時`subscribe nextPagingSubject`以追蹤是否尚有 nextPaging 可繼續撈取
```swift
KKBoxProviderManager.shared.nextPagingSubject
  .subscribe { next in
    self.nextPaging = next
    if next == nil {
      self.playListView.reloadingSubject.onNext(.noMore)
    } else {
      self.playListView.reloadingSubject.onNext(.wait)
    }
  } onDisposed: {
    ...
}.disposed(by: bag)
```

於 UIView 中則對`tableView`綁定傳入的`[Song]`資料進行顯示
```swift
Observable.of(data)
  .bind(to: tableView.rx.items) { [self] (tableView, row, element) in
    if row == 0 {
      ...
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlayListTableViewCell.self)) as! PlayListTableViewCell
      cell.songImage.setImage(url: element.album.images.first!.url)
      cell.songNameLabel.text = element.name
      cell.isFavorited = favorites.contains(element.id)
      cell.favoriteButton.rx.tap.asObservable()
        .subscribe {
        ...
        } onDisposed: {
        }.disposed(by: cell.bag)
      return cell
    }
  }.disposed(by: bag)
  }
```

<img src="/TopicDL5_RxSwift/ScreenShots/list.gif" width="200" height="400"/>


### 封面特效

將`tableView ccontentOffset`視為`Observer`進行`subscribe`以即時更新畫面
```swift
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
```

<img src="/TopicDL5_RxSwift/ScreenShots/header.gif" width="200" height="400"/>

---

### 三方套件

* RxSwift
* RxCocoa
* Alamofire
* Moya/RxSwift
* Kingfisher
* MJRefresh

---

## 環境需求
* Xcode 12.4 
* iOS 13.4

---

## 聯繫資訊

Wun Tseng / twayne0618@gmail.com