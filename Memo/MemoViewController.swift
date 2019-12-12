//
//  MemoView.swift
//  Memo
//
//  Created by Hugo Baral on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import Foundation
import UIKit

class MemoViewController: UIViewController {
    
    @IBOutlet weak var te: UILabel!
    @IBOutlet weak var textView: UITextView!
    
          override func viewDidLoad() {
          super.viewDidLoad()
        let date = Date()
          var calendar = Calendar.current
          
          let hour = calendar.component(.hour, from: date)
          let minute = calendar.component(.minute, from: date)
          let second = calendar.component(.second, from: date)
          te.text = "test123"

        
    }
}
