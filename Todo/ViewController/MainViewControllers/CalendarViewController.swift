//
//  CalendarViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/21.
//

import UIKit
import FSCalendar

// MARK:- FSCalendarDelegate, FSCalendarDataSource
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    /// clickedDate을 키값으로 정해 tableView를 reload
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        clickedDate = dateFormatter.string(from: date)
        clickedDateLabelString = dateLabelFormatter.string(from: date)
        
        nextDayDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value : 1,to: date)!)
        nextWeekDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value : 7,to: date)!)
        
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
      
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let stringDate = dateFormatter.string(from: date)

        if todoItemDic.keys.contains(stringDate) && noteContentDic.keys.contains(stringDate) {
            return 2
        } else if todoItemDic.keys.contains(stringDate) {
            return 1
        } else if noteContentDic.keys.contains(stringDate) {
            return 1
        } else {
            return 0
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance,eventDefaultColorsFor date: Date) -> [UIColor]?
    {
        let stringDate = dateFormatter.string(from: date)

        if todoItemDic.keys.contains(stringDate) && noteContentDic.keys.contains(stringDate) {
            
            return [UIColor.darkGray, UIColor.systemGray4]
        } else if todoItemDic.keys.contains(stringDate) {
            return [UIColor.systemGray4]
        } else if noteContentDic.keys.contains(stringDate) {
            return [UIColor.darkGray]
        } else {
            return [UIColor.clear]
        }

    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let stringDate = dateFormatter.string(from: date)

        if todoItemDic.keys.contains(stringDate) && noteContentDic.keys.contains(stringDate) {
            
            return [UIColor.darkGray, UIColor.systemGray4]
        } else if todoItemDic.keys.contains(stringDate) {
            return [UIColor.systemGray4]
        } else if noteContentDic.keys.contains(stringDate) {
            return [UIColor.darkGray]
        } else {
            return [UIColor.clear]
        }
    }
}
