//
//  CompleteDelegate.swift
//  Todo
//
//  Created by 유준상 on 2021/02/14.
//

import Foundation
import UIKit

protocol CompleteDelegate {
    func onCompleteButtonClicked(noteData: String, date: String, sender: UIButton)
}
