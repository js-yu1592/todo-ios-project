//
//  SecondTablePopUpViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/03/03.
//

import Foundation
import UIKit

class SecondTablePopUpViewController: UIViewController {
    
    var cellLabel: Array<String> = ["Next day","Next week","Select Date"]
    
    @IBOutlet weak var secondPopUpTableView: UITableView!
    
    @IBOutlet weak var secondPopUpContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SecondTablePopUpViewController - viewDidLoad() called")
        
        secondPopUpTableView.layer.cornerRadius = 10
        secondPopUpContainerView.layer.cornerRadius = 10
        
        let secondPopUpCellNib = UINib(nibName: "SecondPopUpCellNib", bundle: nil)
        secondPopUpTableView.register(secondPopUpCellNib, forCellReuseIdentifier: "secondPopUpCell")
        
        secondPopUpTableView.delegate = self
        secondPopUpTableView.dataSource = self
    }
    @IBAction func onBgBtnClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindBgClicked", sender: self)
    }
}

extension SecondTablePopUpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "secondPopUpCell", for: indexPath) as! SecondPopUpCell
        cell.secondPopUpCellLabel.text = cellLabel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.secondPopUpTableView.frame.height/CGFloat(cellLabel.count)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        // 0 is nextday, 필요한것 : clickedDate, firestore의 데이터를 옮기기 다른날짜에 생성하고 원래날짜 삭제
        case 0:
            print("nextday clicked")
            performSegue(withIdentifier: "unwindSecondND", sender: self)
            
        // 1 is nextweek
        case 1:
            print("nextweek clicked")
            
            performSegue(withIdentifier: "unwindSecondNW", sender: self)
            
        // 2 is selectDate
        case 2:
            let calendarPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CalendarPopUpViewController") as! CalendarPopUpViewController
            calendarPopUpVC.modalTransitionStyle = .crossDissolve
            calendarPopUpVC.modalPresentationStyle = .overCurrentContext
            self.present(calendarPopUpVC, animated: true, completion: nil)
            secondPopUpContainerView.isHidden = true
        default:
            print("default")
        }
        
    }
    
}
