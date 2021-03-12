//
//  TablePopUpViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/27.
//

import Foundation
import UIKit
import FSCalendar

class TablePopUpViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var popUpTableView: UITableView!
    
    var labelArr: Array<String> = ["Incomplete", "Postpone", "In progress", "Complete"]
    var imageArr: Array<String> = ["xmark", "arrow.right", "triangle", "circle"]
    var postponeLabel: Array<String> = ["Next day", "Next week", "SelectDate"]
    
    var changeItemStatusDelegate: ChangeItemStatusDelegate?
    
    override func viewDidLoad() {
        print("TablePopUpViewController - viewDidLoad() called")
        super.viewDidLoad()
        
        
        
        containerView.layer.cornerRadius = 10
        popUpTableView.layer.cornerRadius = 10
        
        let popUpCellNib = UINib(nibName: "PopUpCellNib", bundle: nil)
        popUpTableView.register(popUpCellNib, forCellReuseIdentifier: "popUpCell")
        
        popUpTableView.delegate = self
        popUpTableView.dataSource = self
        
    }
    @IBAction func onBgBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension TablePopUpViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popUpCell") as! PopUpCell
        
        cell.popUpLabel.text = labelArr[indexPath.row]
        cell.popUpBtn.setImage(UIImage(systemName: imageArr[indexPath.row]), for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.frame.height/CGFloat(labelArr.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TablePopUpViewController - didSelectRowAt")
        if indexPath.row == 1 {
            
            let secondTablePopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SecondTablePopUpViewController") as! SecondTablePopUpViewController
            secondTablePopUpVC.modalTransitionStyle = .crossDissolve
            secondTablePopUpVC.modalPresentationStyle = .overCurrentContext
            self.present(secondTablePopUpVC, animated: true, completion: nil)
            containerView.isHidden = true
            
        }else {
            changeItemStatusDelegate?.changeItemStatus(status: labelArr[indexPath.row], image: imageArr[indexPath.row])
            
            self.dismiss(animated: true, completion: nil)
        }
            
      
    }
    
    
}
