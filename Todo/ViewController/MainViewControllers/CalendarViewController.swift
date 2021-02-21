//
//  CalendarViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/21.
//

import UIKit
import FSCalendar

// MARK:- FSCalendarDelegate, FSCalendarDataSource
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    /// clickedDate을 키값으로 정해 tableView를 reload
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        clickedDate = dateFormatter.string(from: date)
        print("clickedDate : \(clickedDate)")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let keyTodoItemDic = Set(todoItemDic.keys)
        let keyNoteContent = Set(noteContent.keys)
        
        let intersectionKey = keyTodoItemDic.intersection(keyNoteContent)
        let exclusiveOrKey = (keyTodoItemDic.subtracting(keyNoteContent)).union(keyNoteContent.subtracting(keyTodoItemDic))
        
        if intersectionKey.contains(dateFormatter.string(from: date)) {
            return 2
        } else if exclusiveOrKey.contains(dateFormatter.string(from: date)){
            return 1
        } else {
            return 0
        }
    }
}
