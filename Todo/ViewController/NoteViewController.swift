//
//  NoteViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/12.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NoteViewController - viewDidLoad() called")
        
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}
