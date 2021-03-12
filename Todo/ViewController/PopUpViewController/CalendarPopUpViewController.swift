//
//  CalendarPopUpViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/03/02.
//

import Foundation
import FSCalendar

class CalendarPopUpViewController: UIViewController {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var popUpCalendar: FSCalendar!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var calendarDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CalendarPopUpViewController - viewDidLoad() called")
        
        containerView.layer.cornerRadius = 10
        popUpCalendar.layer.cornerRadius = 10
        
        calendarAppearance()
        popUpCalendar.delegate = self
        popUpCalendar.dataSource = self
    }
    
    /// 캘린더 설정하는 메서드
    func calendarAppearance() {
        print("MainViewController - calendarAppearance()")
        popUpCalendar.appearance.headerMinimumDissolvedAlpha = 0.0
        popUpCalendar.appearance.todayColor = .white
        popUpCalendar.appearance.titleTodayColor = .black
        popUpCalendar.appearance.selectionColor = .darkGray
        popUpCalendar.appearance.headerTitleColor = .black
        popUpCalendar.appearance.weekdayTextColor = .black
        popUpCalendar.appearance.titleTodayColor = .red
        
    }
    
    @IBAction func onBgBtnClicked(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindBgClicked", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MainViewController
        destination.popUpCalendarDate = calendarDate
    }
}

extension CalendarPopUpViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("select popUpCalendar date : \(dateFormatter.string(from: date))")
        
        calendarDate = dateFormatter.string(from: date)
        
        performSegue(withIdentifier: "unwindCalendar", sender: self)
    }
}
