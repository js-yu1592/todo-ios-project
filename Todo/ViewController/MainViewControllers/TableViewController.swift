//
//  TableViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/21.
//

import UIKit

// MARK:- UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt : \(indexPath.row)")
        let DetailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        self.present(DetailVC, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
        
    }
}

// MARK:- UITableViewDataSource
// tableview 수정해야함
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = todoItemDic[clickedDate] else {
            return [1,0][section]
        }
        
        return [1,list.count][section]


    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt called")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell")!
            cell.textLabel?.text = noteContent[clickedDate]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")!
            cell.textLabel?.text = todoItemDic[clickedDate]![indexPath.row]
            return cell
            }
        }
    
   
}

