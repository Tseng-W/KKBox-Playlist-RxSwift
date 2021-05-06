//
//  TableView+Extension.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/6.
//

import UIKit

extension UITableView {
    
    func nib_registerCell(nibName: String, bundle: Bundle?) {
        register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: nibName)
    }
}
