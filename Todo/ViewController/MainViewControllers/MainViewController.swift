//
//  ViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/09.
//

import UIKit
import FSCalendar
import JJFloatingActionButton
import Firebase
import FirebaseFirestoreSwift

class MainViewController: UIViewController {
    
    // MARK: - @IBOulet properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    var clickedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = String()
        date = formatter.string(from: Date())
        return date
    }()
    
    let actionButton: JJFloatingActionButton = {
        let button = JJFloatingActionButton()
        button.buttonColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let db = Firestore.firestore()
    
    var todoItemDic: Dictionary<String,[String]> = [:]
    var noteContent: Dictionary<String,String> = [:]
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController - viewDidLoad()")
        
        fetchData()
        
        calendarAppearance()
        self.tableView.addSubview(actionButton)
        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        
        onActionBtnClicked()
        actionButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        actionButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
    }
    
    // MARK:- function
    /// 파이어스토어 데이터를 읽어와 딕셔너리에 저장하고 테이블뷰를 리로드하는 메서드
    func fetchData() -> Void {
        print("MainViewController - fetchData()")
        DispatchQueue.main.async {
            
            // todoItem 데이터 읽기
            self.db.collection("events").getDocuments { (snapshot, error) in
                if error == nil && snapshot != nil {
                    for document in snapshot!.documents {
                        let documentData = document.data()
                        self.todoItemDic[document.documentID] = documentData["todoItem"] as? [String]
                        self.noteContent[document.documentID] = documentData["noteContent"] as? String
                        
                    }
                    print("todoItemDic : \(self.todoItemDic)")
                    print("noteContent : \(self.noteContent)")
                    
                    self.tableView.reloadData()
                    self.calendar.reloadData()
                    
                    
                } else {
                    print("값이 없음")
                    
                }
            }
            
        }
    }
    /// 캘린더 설정하는 메서드
    func calendarAppearance() {
        print("MainViewController - calendarAppearance()")
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .darkGray
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        
    }
    
    // MARK: - ActionButton : add todoItem complete, have to fix note
    /// 액션버튼 클릭시 2가지 아이템이 나오고 각 아이템별로 데이터를 파이어스토어에 저장하는 메서드
    func onActionBtnClicked() {
        print("MainViewController - onActionBtnClicked()")
        actionButton.addItem(title: "todo", image: UIImage(systemName: "checkmark.rectangle")?.withRenderingMode(.alwaysTemplate)) { item in
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
                    
                    // textField.text 를 firestore에 추가
                    self.db.collection("events").document(self.clickedDate).setData(["todoItem":FieldValue.arrayUnion([textField.text!])],merge: true)
                    self.addTodoItemDic(todoItem: textField.text!, date: self.clickedDate)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.calendar.reloadData()
                    }
                    print("todoItemDicAppend : \(self.todoItemDic[self.clickedDate]!)")
                    
                }
            })
            alertController.addAction(submitBtnAction)
            self.present(alertController, animated: true, completion: nil)
        }
        actionButton.addItem(title: "memo", image: UIImage(systemName: "square.and.pencil")?.withRenderingMode(.alwaysTemplate)) { item in
            
            let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
            noteVC.completeDelegate = self
            self.present(noteVC, animated: true, completion: nil)
        }
    }
    
    /// noteContent Dictionary value값이 nil이 아니면 true 리턴, nil이면 false 리턴
    func noteContentStatus() -> Bool {
        print("MainViewController - noteContentStatus()")
        if noteContent[clickedDate] != "" {
            return true
        } else {
            return false
        }
    }
    
    /// dictionaty value인 array에  값 추가
    func addTodoItemDic(todoItem: String, date: String) {
        print("MainViewController - addTodoItemDic()")
        if var value = todoItemDic[date] {
            value.append(todoItem)
            todoItemDic[date] = value
        } else {
            todoItemDic[date] = [todoItem]
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

// MARK: - CompleteDelegate
/// NoteViewController에서 값을 가져오기 위한 Delegate
extension MainViewController: CompleteDelegate {
    func onCompleteButtonClicked(noteData: String) {
        print("CompleteDelegate - onCompleteButtonClicked() called / noteData : \(noteData)")
        self.db.collection("events").document(self.clickedDate).setData(["noteContent":noteData],merge: true)
        noteContent[self.clickedDate] = noteData
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.calendar.reloadData()
        }
        
    }
    
    
}
