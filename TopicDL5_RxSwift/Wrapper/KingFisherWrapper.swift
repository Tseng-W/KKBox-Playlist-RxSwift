//
//  KingFisherWrapper.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/6.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(url: String) {
        self.kf.setImage(
            with: URL(string: url),
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
}
