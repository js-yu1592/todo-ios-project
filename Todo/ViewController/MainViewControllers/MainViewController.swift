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
    
    lazy var dateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM dd, yyyy"
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
    
    var nextDayDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = String()
        date = formatter.string(from: Calendar.current.date(byAdding: .day, value : 1,to: Date())!)
        return date
    }()
    
    var nextWeekDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = String()
        date = formatter.string(from: Calendar.current.date(byAdding: .day, value : 7,to: Date())!)
        return date
    }()
    
    var popUpCalendarDate = ""
    
    var clickedDateLabelString: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM dd, yyyy"
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
    
    var todoItemDic: Dictionary<String,[String]> = [:] {
        didSet {
            print("todoItemDic : \(self.todoItemDic)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    var noteContentDic: Dictionary<String,String> = [:] {
        didSet {
            print("noteContentDic : \(self.noteContentDic)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    var todoStatusDic: Dictionary<String,[String]> = [:] {
        didSet {
            print("todoStatusDic : \(self.todoStatusDic)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    var todoIndexPathDic: Dictionary<String,[String]> = [:] {
        didSet {
            print("todoIndexPathDic : \(self.todoIndexPathDic)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    
    var cellClickedIndex: Int = 0
    
    var deSelectIndexPath = IndexPath()
    
    var cellBtnClickedIndex: Int = 0
    
    var labelArr: Array<String> = ["Incomplete", "Postpone", "In progress", "Complete"]
    var imageArr: Array<String> = ["xmark", "arrow.right", "triangle", "circle"]
    
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
        
        let todoItemCellNib = UINib(nibName: "TodoItemCellNib", bundle: nil)
        self.tableView.register(todoItemCellNib, forCellReuseIdentifier: "todoItemCell")
        
        let userUid = UUID.init()
        print("user uuid : \(userUid.uuidString)")
    }
    
    // MARK:- function
    //    /// clckedDate의 정보를  읽어와 딕셔너리에 저장하고 테이블뷰를 리로드하는 메서드, 초기화면, 날짜를 바꿀때마다 호출해야함
    func fetchData() {
        print("MainViewController - fetchData()")
        DispatchQueue.global(qos: .utility).async {
            
            self.db.collection("events").getDocuments { (snapshot, error) in
                if error == nil && snapshot != nil {
                    
                    for dateDocument in snapshot!.documents {
                        
                        let documentData = dateDocument.data()
                        
                        self.noteContentDic[dateDocument.documentID] = documentData["noteContent"] as? String
                        //                        self.db.collection("events").document(dateDocument.documentID).collection("todo").order(by: "timeStamp")
                        self.db.collection("events").document(dateDocument.documentID).collection("todo").order(by: "timeStamp").getDocuments { (snapshot, error) in
                            if error == nil && snapshot != nil {
                                for document in snapshot!.documents {
                                    let documentData = document.data()
                                    
                                    self.db.collection("events").document("events").collection("todo").order(by: document.documentID)
                                    
                                    if let todoItem = documentData["todoItem"] as? String {
                                        self.todoItemDic = self.add(dict: self.todoItemDic, string: todoItem, key: dateDocument.documentID)
                                    }
                                    
                                    if let todoStatus = documentData["todoStatus"] as? String {
                                        self.todoStatusDic = self.add(dict: self.todoStatusDic, string: todoStatus, key: dateDocument.documentID)
                                    }
                                    
                                    self.todoIndexPathDic = self.add(dict: self.todoIndexPathDic, string: document.documentID, key: dateDocument.documentID)
                                    
                                    
                                }
                            } else {
                                print("fetch fail")
                            }
                        }
                    }
                    
                } else {
                    print("fetch fail")
                }
                
            }
            
        }
        
    }
    
    /// 딕셔너리에 값을 추가하는 메서드
    func add(dict:Dictionary<String,[String]>, string:String, key:String) ->  Dictionary<String,[String]>{
        var mutatedDict = dict
        if var value = mutatedDict[key] {
            // if an array exist, append to it
            value.append(string)
            mutatedDict[key] = value
            return mutatedDict
        } else {
            // create a new array since there is nothing here
            mutatedDict[key] = [string]
            return mutatedDict
        }
    }
    
    
    /// 캘린더 설정하는 메서드
    func calendarAppearance() {
        print("MainViewController - calendarAppearance()")
        calendar.appearance.headerMinimumDissolvedAlpha = 0.3
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .darkGray
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.titleTodayColor = .red
        
    }
    
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
                    
                    // 중복 추가를 허용하기 위해 addDocument() 사용, setData는 덮어쓰기, 값 추가밖에 못함
                    var ref: DocumentReference? = nil
                    
                    ref = self.db.collection("events").document(self.clickedDate).collection("todo").addDocument(data: [
                        "todoItem" : textField.text!,
                        // 처음에는 Incomplete로 시작
                        "todoStatus" : "Incomplete",
                        "timeStamp" : FieldValue.serverTimestamp()
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            if self.todoIndexPathDic[self.clickedDate] == nil {
                                self.todoIndexPathDic[self.clickedDate] = []
                            }
                            self.todoIndexPathDic[self.clickedDate]!.append(ref!.documentID)
                        }
                    }
                    //document안 필드에 아무 값이 없으면 '존재하지 않는 문서이며 쿼리나 스냅샷에 표시되지 않습니다.' 가 뜸, 임시로 아무 값을 넣음 어차피 읽지 않으면 상관없음
                    self.db.collection("events").document(self.clickedDate).setData(["documentExsist" : "exist"], merge: true)
                    
                    self.todoItemDic = self.add(dict: self.todoItemDic, string: textField.text!, key: self.clickedDate)
                    self.todoStatusDic = self.add(dict: self.todoStatusDic, string: "Incomplete", key: self.clickedDate)
                    
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
        
        actionButton.addItem(title: "All delete", image: UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)) { item in
            
            self.db.collection("events").getDocuments { (snapshot, error) in
                if error == nil && snapshot != nil {
                    for dateDocument in snapshot!.documents {
                        
                        self.db.collection("events").document(dateDocument.documentID).collection("todo").getDocuments { (snapshot, error) in
                            if error == nil && snapshot != nil {
                                for document in snapshot!.documents {
                                    self.db.collection("events").document(dateDocument.documentID).collection("todo").document(document.documentID).delete()
                                    
                                }
                            }
                        }
                        self.db.collection("events").document(dateDocument.documentID).delete()
                    }
                } else { print("fail!") }
            }
            self.noteContentDic = [:]
            self.todoItemDic = [:]
            self.todoStatusDic = [:]
            self.todoIndexPathDic = [:]
        }
    }
    
    /// noteContent Dictionary value값이 nil이 아니면 true 리턴, nil이면 false 리턴
    func noteContentStatus() -> Bool {
        if noteContentDic[clickedDate] != nil {
            return true
        } else {
            return false
        }
    }
    
    
    /// cell Tapped function : 셀의 버튼 클릭시 팝업 뷰컨트롤러 present
    @objc func cellBtnTapped(_ sender: UIButton) {
        cellBtnClickedIndex = sender.tag
        print("cellBtnClickedIndex test : \(cellBtnClickedIndex)")
        let tablePopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "TablePopUpViewController") as! TablePopUpViewController
        tablePopUpVC.changeItemStatusDelegate = self
        // 뷰 컨트롤러가 보여지는 스타일
        tablePopUpVC.modalPresentationStyle = .overCurrentContext
        // 뷰 컨트롤러가 사라지는 스타일
        tablePopUpVC.modalTransitionStyle = .crossDissolve
        
        self.present(tablePopUpVC, animated: true, completion: nil)
    }
    
    @IBAction func unwindBgClickedVC(segue : UIStoryboardSegue) {
        print("MainViewController - unwindBgClickedVC() called / segue: \(segue.identifier!)")
        
        
    }
    
    @IBAction func unwindSecondVC(segue : UIStoryboardSegue) {
        print("MainViewController - unwindSecondVC() called / segue : \(segue.identifier!)")
        
        
        if segue.identifier == "unwindSecondND" {
            changeDate(date: self.nextDayDate)
            
            
        } else if segue.identifier == "unwindSecondNW" {
            changeDate(date: self.nextWeekDate)
            
            
        } else if segue.identifier == "unwindCalendar" {
            changeDate(date: self.popUpCalendarDate)
            
        } else {
            print("fail!")
            
        }
        
        
    }
    func changeDate(date: String) {
        print("MainViewController - changeDate() called")
        db.collection("events").document(clickedDate).collection("todo").document(todoIndexPathDic[clickedDate]![cellBtnClickedIndex]).getDocument { (document, error) in
            if error == nil && document != nil {
                if let document = document {
                    
                    if let documentData = document.data() {
                        
                        self.db.collection("events").document(date).setData(["documentExsist" : "exist"], merge: true)
                        self.db.collection("events").document(date).collection("todo").document(document.documentID).setData(["todoItem": documentData["todoItem"] as! String], merge: true)
                        self.db.collection("events").document(date).collection("todo").document(document.documentID).setData(["todoStatus": documentData["todoStatus"] as! String], merge: true)
                        self.db.collection("events").document(date).collection("todo").document(document.documentID).setData(["timeStamp": FieldValue.serverTimestamp()], merge: true)
                        
                        self.db.collection("events").document(self.clickedDate).collection("todo").document(document.documentID).delete()
                        
                        
                        let changeTodoItemValue = self.todoItemDic[self.clickedDate]!.remove(at: self.cellBtnClickedIndex)
                        let changeTodoStatusValue = self.todoStatusDic[self.clickedDate]!.remove(at: self.cellBtnClickedIndex)
                        let changeTodoIndexPathValue = self.todoIndexPathDic[self.clickedDate]!.remove(at: self.cellBtnClickedIndex)
                        
                        if self.todoItemDic[self.clickedDate]! == [] && self.todoItemDic[self.clickedDate]! == [] && self.todoIndexPathDic[self.clickedDate]! == [] {
                            self.todoItemDic[self.clickedDate] = nil
                            self.todoStatusDic[self.clickedDate] = nil
                            self.todoIndexPathDic[self.clickedDate] = nil
                        }
                        
                        if self.todoItemDic[date] == nil && self.todoStatusDic[date] == nil && self.todoIndexPathDic[date] == nil{
                            self.todoItemDic[date] = []
                            self.todoStatusDic[date] = []
                            self.todoIndexPathDic[date] = []
                        }
                        
                        self.todoItemDic[date]!.append(changeTodoItemValue)
                        self.todoStatusDic[date]!.append(changeTodoStatusValue)
                        self.todoIndexPathDic[date]!.append(changeTodoIndexPathValue)
                    }
                }
            }
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
    func onCompleteButtonClicked(noteData: String, date: String, sender: UIButton) {
        print("CompleteDelegate - onCompleteButtonClicked() called / noteData : \(noteData), date : \(type(of: date)), sender : \(sender.tag)")
        
        // noteVC complete btn tag is 1, DetailVC complete btn tag is 2
        switch sender.tag {
        case 1:
            self.db.collection("events").document(self.clickedDate).setData(["noteContent":noteData],merge: true)
            noteContentDic[self.clickedDate] = noteData
        case 2:
            db.collection("events").document(clickedDate).collection("todo").document(todoIndexPathDic[clickedDate]![cellClickedIndex]).getDocument { (document, error) in
                if error == nil && document != nil {
                    if let document = document{
                        print("documentID : \(document.documentID)")
                        print("test todoIndex : \(self.todoIndexPathDic[self.clickedDate]!)")
                        
                        self.db.collection("events").document(self.clickedDate).collection("todo").document(document.documentID).updateData(["todoItem":noteData])
                        
    
                        self.todoItemDic[self.clickedDate]![self.cellClickedIndex] = noteData
                        
                        if date != "" {
                            print("clickedDate : \(self.clickedDate), date : \(date)")
                            self.changeDate(date: date)
                        }
                        
                    }
                } else {
                    print("fail")
                }
            }
            
            
        default:
            print("sender.tag is not exist")
        }
        

        
        
    }
    
    
}
extension MainViewController: DeSelectDelegate {
    func deSelectBgColor() {
        print("MainViewController - deSelectBgColor() called")
        let deSelectView = UIView()
        deSelectView.backgroundColor = UIColor.clear
        let deSelectCell: UITableViewCell = tableView.cellForRow(at: deSelectIndexPath)!
        deSelectCell.selectedBackgroundView = deSelectView
    }
    
    
}

extension MainViewController: ChangeItemStatusDelegate {
    func changeItemStatus(status: String, image: String) {
        print("MainViewController - ChangeItemStatusDelegate")
        
        self.todoStatusDic[clickedDate]![cellBtnClickedIndex] = status
        
        // 파이어스토어 Status값 변경
        self.db.collection("events").document(self.clickedDate).collection("todo").document(todoIndexPathDic[clickedDate]![cellBtnClickedIndex]).getDocument { (document, error) in
            if error == nil && document != nil {
                if let document = document{
                        self.db.collection("events").document(self.clickedDate).collection("todo").document(document.documentID).updateData(["todoStatus":self.todoStatusDic[self.clickedDate]![self.cellBtnClickedIndex]])
                    }
            } else {
                print("fail")
            }
        }
        
        
    }
    
}
