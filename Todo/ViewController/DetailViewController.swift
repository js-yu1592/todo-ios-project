//
//  DetailViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/13.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var noteContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailViewController - viewDidLoad() called")
        
        
    }
    
    @IBAction func onCloseBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompleteBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    
    }
    
}
