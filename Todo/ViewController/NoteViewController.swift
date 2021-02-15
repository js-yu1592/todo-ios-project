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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("NoteViewController - viewDidLoad() called")
        
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        noteTextView.delegate = self
        noteTextView.text = "Add notes"
        noteTextView.textColor = UIColor.lightGray
        
    }
    
    @IBAction func onCloseBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompleteBtnClicked(_ sender: UIButton) {
        if noteTextView.text == "" {
            self.dismiss(animated: true, completion: nil)
        } else {
            print(noteTextView.text!)
            self.dismiss(animated: true, completion: nil)
            completeDelegate?.onCompleteButtonClicked(noteData: noteTextView.text)
            
        }
        
    }
    
    
}

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add notes"
            textView.textColor = UIColor.lightGray
        }
    }
}
