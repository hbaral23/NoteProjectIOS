//
//  Note.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import Foundation

public class Note {
    var id: Int?
    var title: String?
    var content: String?
    var pictures: [String]?
    var date: Date
    
    init(id: Int?, title: String?, content: String?, pictures: [String]?, date: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.pictures = pictures
        self.date = date
    }
}
