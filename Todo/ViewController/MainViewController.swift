//
//  ViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/09.
//

import UIKit
import FSCalendar
import JJFloatingActionButton
import CoreData

class MainViewController: UIViewController {

    // MARK: - @IBOulet properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - properties
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    let actionButton: JJFloatingActionButton = {
       let button = JJFloatingActionButton()
//        button.buttonColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let request: NSFetchRequest<Todo> = Todo.fetchRequest()
    

    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.addSubview(actionButton)
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        onActionBtnClicked()
        
        actionButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        actionButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
        calendarAppearance()
        
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- function
    
    func calendarAppearance() {
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .darkGray
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        
    }
    
    // 액션 버튼
    func onActionBtnClicked() {
        actionButton.addItem(title: "", image: UIImage(systemName: "square.and.pencil")?.withRenderingMode(.alwaysTemplate)) { item in
            print("item1 clicked")
            let alertController = UIAlertController(title: "작성", message: "작성해주세요!", preferredStyle: .alert)
            alertController.addTextField { (myTextField) in
                myTextField.placeholder = "오늘의 할일"
            }
            
            let submitBtnAction = UIAlertAction(title: "완료", style: .default, handler: { action in
                let textField = alertController.textFields![0]
                
                if textField.text == "" {
                    print("값이 없음")
                } else {
                    print(textField.text!)
                    /// CoreData에 저장할 객체
//                    let todoItem = TodoItem(content: textField.text!, date: self.dateFormatter.string(from: Date()))
                    let todoItem = TodoItem(
                    PersistenceManager.shared.insertItem(item: todoItem)
                    
                    // 동적으로 셀을 추가함
                    // 테이블뷰 전체를 리로드하기보다는 섹션만 리로드
                    self.tableView.reloadSections(IndexSet(1...1), with: UITableView.RowAnimation.automatic)
                }
            })
            alertController.addAction(submitBtnAction)
            self.present(alertController, animated: true, completion: nil)
        }
        actionButton.addItem(title: "", image: UIImage(systemName: "pencil.circle.fill")?.withRenderingMode(.alwaysTemplate)) { item in
            print("item2 clicked")
            
            let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
            noteVC.completeDelegate = self
            self.present(noteVC, animated: true, completion: nil)
        }
    }
    
}
    // MARK:- @IBAction function
    
//    @IBAction func toggleClicked(sender: AnyObject) {
//        if self.calendar.scope == .month {
//            self.calendar.setScope(.week, animated: self.animationSwitch.isOn)
//        } else {
//            self.calendar.setScope(.month, animated: self.animationSwitch.isOn)
//        }
//    }
//
//}

// MARK:- UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
            self.calendar.setScope(scope, animated: self.animationSwitch.isOn)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
}

// MARK:- UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1,(PersistenceManager.shared.count(request: request))!][section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = ["noteCell"][indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
            cell.textLabel?.text = "Today's note"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")!
            let fetchResult = PersistenceManager.shared.fetch(request: request)
            cell.textLabel?.text = fetchResult[indexPath.row].content
            return cell
        }
    }
}

// MARK:- UIGestureRecognizerDelegate
extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
}
// MARK:- FSCalendarDelegate, FSCalendarDataSource
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
}
// MARK: - CompleteDelegate
extension MainViewController: CompleteDelegate {
    func onCompleteButtonClicked(noteData: String) {
        print("CompleteDelegate - onCompleteButtonClicked() called / noteData : \(noteData)")
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text = noteData
        self.tableView.reloadSections(IndexSet(0...0), with: UITableView.RowAnimation.automatic)
    }
    
    
}
