//
//  DetailCalendarPopUpViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/03/05.
//

import Foundation
import FSCalendar

class DetailCalendarPopUpViewController: UIViewController {
    
    @IBOutlet weak var detailContainerView: UIView!
    
    @IBOutlet weak var detailPopUpCalendar: FSCalendar!
    
    var completionClosure: ((_ clicked: Date) -> Void)?
    
  
    var clickedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailCalendarPopUpViewController - viewDidLoad() called")
        detailContainerView.layer.cornerRadius = 10
        detailPopUpCalendar.layer.cornerRadius = 10
        
        calendarAppearance()
        
        detailPopUpCalendar.delegate = self
        detailPopUpCalendar.dataSource = self
    }
    
    /// 캘린더 설정하는 메서드
    func calendarAppearance() {
        print("MainViewController - calendarAppearance()")
        detailPopUpCalendar.appearance.headerMinimumDissolvedAlpha = 0.0
        detailPopUpCalendar.appearance.todayColor = .white
        detailPopUpCalendar.appearance.titleTodayColor = .black
        detailPopUpCalendar.appearance.selectionColor = .darkGray
        detailPopUpCalendar.appearance.headerTitleColor = .black
        detailPopUpCalendar.appearance.weekdayTextColor = .black
        detailPopUpCalendar.appearance.titleTodayColor = .red
        
    }
    @IBAction func onBgBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension DetailCalendarPopUpViewController: FSCalendarDelegate,FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
     
        
        self.dismiss(animated: true, completion: nil)
        
        if let completionClosure = completionClosure {
            completionClosure(date)
        }
    }
}
