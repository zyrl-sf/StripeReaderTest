//
//  ConsoleViewController.swift
//  StripeReaderTest
//
//  Created by Максим on 28.08.2024.
//

import UIKit


class ConsoleViewController: BaseViewController {
    
    lazy var console: UITextView = {
        $0.isEditable = false
        return $0
    }(UITextView())
    
    override init() {
        super.init()
        view.backgroundColor = .systemBackground
        view.addSubview(console)
        console.snp.makeConstraints({
            $0.top.equalTo(view.snp.topMargin)
            $0.left.right.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.snp.bottomMargin)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushLogs(message: String?) {
        DispatchQueue.main.async {
            message.map({ self.console.insertText($0) })
            self.scrollTextViewToBottom(textView: self.console)
        }
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        DispatchQueue.main.async {
            if textView.text.count > 0 {
                let location = textView.text.count - 1
                let bottom = NSMakeRange(location, 1)
                textView.scrollRangeToVisible(bottom)
            }
        }
    }
}
