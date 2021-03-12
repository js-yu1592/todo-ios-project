//
//  DetailViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/13.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var dateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM dd, yyyy"
        return formatter
    }()
    
    lazy var notiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    @IBOutlet weak var detailCompleteBtn: UIButton!
    
    @IBOutlet weak var contentTF: UITextField!
    
    @IBOutlet weak var detailDateLabel: UILabel!
    
    @IBOutlet weak var addNotificationSwitch: UISwitch!
    
    @IBOutlet weak var notificationDateLabel: UILabel!
    
    @IBOutlet weak var notiContainerView: UIView!
    
    var stringHolder: String = ""
    var detailDateString = ""
    
    var completeDelegate: CompleteDelegate?
    var deSelectDelegate: DeSelectDelegate?
    
    
    var changeDate: String = ""
    var notificationDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailViewController - viewDidLoad() called")
        
        detailCompleteBtn.tag = 2
        
        contentTF.text = stringHolder
        
        contentTF.delegate = self
        
        detailDateLabel.text = detailDateString
        
        addNotificationSwitch.isOn = false
        
        notiContainerView.isHidden = true
    }
    
    

    @IBAction func onAddNotiSwitchClicked(_ sender: UISwitch) {
        print("DetailViewController - onAddNotiSwitchClicked() called")
        if sender.isOn == true {
            
            let notificationPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationPopUpViewController") as! NotificationPopUpViewController
            notificationPopUpVC.modalTransitionStyle = .crossDissolve
            notificationPopUpVC.modalPresentationStyle = .overCurrentContext
            notificationPopUpVC.notiDateClosure = { (date) in
                self.notificationDate = date
                self.notiContainerView.isHidden = false
                self.notificationDateLabel.text = self.notiDateFormatter.string(from: date)
            }
            self.present(notificationPopUpVC, animated: true, completion: nil)
        } else {
            
        }
    }
    
    @IBAction func onCloseBtnClicked(_ sender: UIButton) {
        deSelectDelegate?.deSelectBgColor()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompleteBtnClicked(_ sender: UIButton) {
        deSelectDelegate?.deSelectBgColor()
        self.dismiss(animated: true, completion: nil)
        
        completeDelegate?.onCompleteButtonClicked(noteData: contentTF.text!, date: changeDate, sender: detailCompleteBtn)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.showNotification(date: notificationDate, title: contentTF.text!)
    }
    
   
    @IBAction func onChangeDateBtnClicked(_ sender: UIButton) {
        let detailCalendarPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailCalendarPopUpViewController") as! DetailCalendarPopUpViewController
        detailCalendarPopUpVC.modalTransitionStyle = .crossDissolve
        detailCalendarPopUpVC.modalPresentationStyle = .overCurrentContext
        
        detailCalendarPopUpVC.completionClosure = { (date) in
            print("DetailViewController - completionClosure called")
            let clickedDate = self.dateLabelFormatter.string(from: date)
            self.detailDateLabel.text = clickedDate
            
            self.changeDate = self.dateFormatter.string(from: date)
        }
        self.present(detailCalendarPopUpVC, animated: true, completion: nil)
    }
    
    
}

extension DetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = (contentTF.text! as NSString).replacingCharacters(in: range, with: string)
    if text.isEmpty {
        detailCompleteBtn.isEnabled = false
        detailCompleteBtn.alpha = 0.5
    } else {
        detailCompleteBtn.isEnabled = true
        detailCompleteBtn.alpha = 1.0
    }
     return true
    }
}
