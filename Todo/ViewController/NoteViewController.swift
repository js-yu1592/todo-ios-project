//
//  NoteViewController.swift
//  Todo
//
//  Created by 유준상 on 2021/02/12.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var completeDelegate: CompleteDelegate?
    
    @IBOutlet weak var noteCompleteBtn: UIButton!
    
    var stringHolder: String = ""
    
    @IBOutlet weak var noteDateLabel: UILabel!
    
    var noteDateString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NoteViewController - viewDidLoad() called")
        
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        noteTextView.delegate = self
        noteTextView.text = "Add notes"
        noteTextView.textColor = UIColor.lightGray
        
        noteCompleteBtn.tag = 1
        
        if stringHolder != "" {
            noteTextView.textColor = UIColor.black
            noteTextView.text = stringHolder
            stringHolder = ""
        }
        
        
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let btnDoneBar = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneBtnClicked))
        toolBarKeyboard.items = [btnDoneBar]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        noteTextView.inputAccessoryView = toolBarKeyboard
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        noteDateLabel.text = noteDateString
        
    }
    
    @objc fileprivate func doneBtnClicked() {
        self.noteTextView.endEditing(true)
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    @IBAction func onCloseBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompleteBtnClicked(_ sender: UIButton) {
        print(noteTextView.text!)
        self.dismiss(animated: true, completion: nil)
        
        completeDelegate?.onCompleteButtonClicked(noteData: noteTextView.text, date: noteDateString, sender: noteCompleteBtn)
    }
    
    
}

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Add notes" && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
            
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Add notes"
            textView.textColor = .lightGray
            
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text! == "" {
            noteCompleteBtn.isEnabled = false
            noteCompleteBtn.alpha = 0.5
        } else {
            noteCompleteBtn.isEnabled = true
            noteCompleteBtn.alpha = 1.0
        }
    }
    
}
