//
//  TableViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/21.
//

import UIKit
import Firebase

// MARK:- UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if noteContentStatus() == false {
            return nil
        }
        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 2))
        sectionHeader.layer.cornerRadius = 8
        
        sectionHeader.backgroundColor = .darkGray
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt : \(indexPath.row)")
        
        cellClickedIndex = indexPath.row
        
        if indexPath.section == 0 {
            let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
            // noteVC의 뷰를 바로 바꾸려하면 바뀌지 않음, 뷰가 아직 생기지 않았기때문에 nil 에러
            noteVC.stringHolder = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
            noteVC.noteDateString = clickedDateLabelString
            noteVC.completeDelegate = self
            self.present(noteVC, animated: true, completion: nil)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! TodoItemCell
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailVC.stringHolder = cell.todoItemLabel.text!
            detailVC.detailDateString = clickedDateLabelString
            detailVC.completeDelegate = self
            
            detailVC.deSelectDelegate = self
            
            // 뷰를 클릭했을때 백그라운드 색을 지정함, 지정했다가 다시 없애야하기 때문에 delegate패턴을 통해 없애줌
            let selectView = UIView()
            selectView.backgroundColor = UIColor.systemGray5
            cell.selectedBackgroundView = selectView
            self.deSelectIndexPath = indexPath
            
            self.present(detailVC, animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 섹션이 0, 즉 노트의 셀은 오토레이아웃으로 설정
        if indexPath.section == 0 {
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 100
            return self.tableView.rowHeight
        } else {
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    // 섹션간의 거리를 없앰
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    
}

// MARK:- UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noteContentStatus() == true && todoItemDic[clickedDate] != nil {
            return [1,todoItemDic[clickedDate]!.count][section]
        } else if noteContentStatus() == false && todoItemDic[clickedDate] != nil {
            return [0,todoItemDic[clickedDate]!.count][section]
        } else if noteContentStatus() == true && todoItemDic[clickedDate] == nil {
            return [1,0][section]
        } else {
            return [0,0][section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell")!
            cell.textLabel?.text = noteContentDic[clickedDate]
            cell.textLabel?.numberOfLines = 0
            cell.layer.cornerRadius = 8
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell",for: indexPath) as! TodoItemCell
            cell.todoItemLabel.text = todoItemDic[clickedDate]![indexPath.row]
            
            // 버튼의 이미지 변경 -> 알고리즘 : status값에 따라
            switch todoStatusDic[clickedDate]![indexPath.row] {
            case labelArr[0]:
                cell.todoItemBtn.setImage(UIImage(systemName: imageArr[0]), for: .normal)
            case labelArr[1]:
                cell.todoItemBtn.setImage(UIImage(systemName: imageArr[1]), for: .normal)
            case labelArr[2]:
                cell.todoItemBtn.setImage(UIImage(systemName: imageArr[2]), for: .normal)
            case labelArr[3]:
                cell.todoItemBtn.setImage(UIImage(systemName: imageArr[3]), for: .normal)
            default:
                print("todoItemBtn imag is wrong")
            }
            
            cell.todoItemBtn.tag = indexPath.row
            cell.todoItemBtn.addTarget(self, action: #selector(cellBtnTapped(_:)), for: .touchUpInside)
            cell.layer.cornerRadius = 8
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.section == 0 {
                noteContentDic.removeValue(forKey: clickedDate)
                db.collection("events").document(self.clickedDate).updateData(["noteContent":FieldValue.delete()])
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                // 삭제한 셀의 내용과 status를 같이 삭제, 둘의 복합 쿼리를 통해 찾아내고 그것을 삭제........
                // 필요한것 도큐먼트 아이디, 삭제할 값, indexpath.row
                
                // 중복되는 값이 있으면 삭제됨,,,,,,,,,해결 방안을 구해야함 예를 들어 index를 찾아 삭제하는 방법
                self.db.collection("events").document(self.clickedDate).collection("todo").document(todoIndexPathDic[clickedDate]![indexPath.row]).getDocument { (document, error) in
                    if error == nil && document != nil {
                        if let document = document {
                            self.db.collection("events").document(self.clickedDate).collection("todo").document(document.documentID).delete()
                        }
                    }
                }
                
                todoItemDic[clickedDate]!.remove(at: indexPath.row)
                todoStatusDic[clickedDate]!.remove(at: indexPath.row)
                todoIndexPathDic[clickedDate]!.remove(at: indexPath.row)
                
                if todoItemDic[clickedDate]! == [] && todoStatusDic[clickedDate]! == [] && todoIndexPathDic[clickedDate]! == [] {
                    todoItemDic[clickedDate] = nil
                    todoStatusDic[clickedDate] = nil
                    todoIndexPathDic[clickedDate] = nil
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            
        }
    }
    
    
}

