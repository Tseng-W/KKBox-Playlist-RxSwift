//
//  PlayListTableViewCell.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/6.
//

import UIKit
import RxSwift

class PlayListTableViewCell: UITableViewCell {
    
    enum Favorite: String {
        case T = "heart.fill"
        case F = "heart"
    }
    
    @IBOutlet var songImage: UIImageView!
    
    @IBOutlet var songNameLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    
    var isFavorited: Bool = false {
        didSet {
            let newImageName = isFavorited ? Favorite.T.rawValue : Favorite.F.rawValue
            favoriteButton.setImage(UIImage(systemName: newImageName), for: .normal)
        }
    }
    
    var bag = DisposeBag()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
        
        alpha = 0
        layoutIfNeeded()
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .allowAnimatedContent) {
            self.alpha = 1
            self.layoutIfNeeded()
        }
    }
}
