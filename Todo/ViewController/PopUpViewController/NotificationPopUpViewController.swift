//
//  NotificationPopUpViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/03/06.
//

import Foundation
import UIKit

class NotificationPopUpViewController: UIViewController {
    @IBOutlet weak var notiContainerView: UIView!
    
    var pickerDate: Date = Date()
    
    var notiDateClosure: ((_ date: Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NotificationPopUpViewController - viewDidLoad() called")
        
        notiContainerView.layer.cornerRadius = 10
    }
    
    @IBAction func onBgBtnClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancelBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCompleteBtnClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
        if let notiDateClosure = notiDateClosure {
            notiDateClosure(pickerDate)
        }
    }
    
    @IBAction func changedDatePickerValue(_ sender: UIDatePicker) {
        
        pickerDate = sender.date
    }
}
