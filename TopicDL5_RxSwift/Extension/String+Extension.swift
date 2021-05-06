//
//  String+Extension.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/5.
//

import Foundation

extension String {
    
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
