//
//  ListController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit
import SQLite3

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var notesTableView: UITableView!
    
    var db: OpaquePointer?
    
    var notes: [Note]?
    
    let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    var searchBarIsOpen = false;
        
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var searchBar = UISearchBar()
    
    var keyword = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDB()
        
        notes = []
        
        for i in 1...10{
            notes?.append(Note(id: i, title: "note\(i)" , content: "Contenu note\(i)", pictures: [], date: Date()))
        }
        
        searchBar.delegate = self
        
        getData()
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        notesTableView.reloadData()
    }
       
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        keyword = searchText
        getData()
        notesTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let firstSubview = searchBar.subviews.first else { return }

        firstSubview.subviews.forEach {
            ($0 as? UITextField)?.clearButtonMode = .never
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let label = UILabel()
        label.text = "Notes"
        navigationItem.titleView = label
        
        searchButton.width = 0.01;
        searchBarIsOpen = false
    }
    
    @IBAction func openSearchBar() {
        if(searchBarIsOpen == false){
            
            searchBar.placeholder = "Search"

            navigationItem.titleView = searchBar
            
            searchButton.image = UIImage(systemName: "xmark")
            
            searchBarIsOpen = true
        }else {
            let label = UILabel()
            label.text = "Notes"
            navigationItem.titleView = label
            
            searchButton.image = UIImage(systemName: "magnifyingglass")
            
            searchBarIsOpen = false
        }
    }

    func initDB(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("NotesDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,content TEXT, date DATE)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func getData(){
        notes?.removeAll()
        
        let queryString = "SELECT * FROM Notes WHERE title LIKE '%\(keyword)%' OR content LIKE '%\(keyword)%' ORDER BY date DESC"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        let dateFormatter: DateFormatter = {
            let _formatter = DateFormatter()
            _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
            _formatter.locale = Locale(identifier: "FR-fr")
            return _formatter
        }()
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let content = String(cString: sqlite3_column_text(stmt, 2))
            let stringDate = String(cString: sqlite3_column_text(stmt, 3))
            let date = dateFormatter.date(from: stringDate);
            
            notes?.append(Note(id: Int(id), title: String(describing: title), content: content, pictures: [], date: date!))
        }
    }
    
    @IBAction func addNewNote(){
        /*var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Notes (title, content, date) VALUES (?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        let title = ""
        let content = ""
        
        let dateFormatter: DateFormatter = {
            let _formatter = DateFormatter()
            _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
            _formatter.locale = Locale(identifier: "FR-fr")
            return _formatter
        }()
        
        let date = dateFormatter.string(from: Date())
        
        let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
        
        if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding title: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, content, -1, SQLITE_TRANSIENT ) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding content: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, date, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding date: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting notes: \(errmsg)")
            return
        }
        
        let queryString2 = "SELECT * WHERE id=(SELECT MAX(id) FROM Notes) FROM Notes"
        
        var stmt2:OpaquePointer?
        
        if sqlite3_prepare(db, queryString2, -1, &stmt2, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        let dateFormatter2: DateFormatter = {
            let _formatter = DateFormatter()
            _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
            _formatter.locale = Locale(identifier: "FR-fr")
            return _formatter
        }()
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let newId = sqlite3_column_int(stmt, 0)
            let newTitle = String(cString: sqlite3_column_text(stmt, 1))
            let newContent = String(cString: sqlite3_column_text(stmt, 2))
            let newStringDate = String(cString: sqlite3_column_text(stmt, 3))
            let newDate = dateFormatter2.date(from: newStringDate);
            
            let newNote: Note = Note(id: Int(newId), title: newTitle, content: newContent, pictures: [], date: newDate!)
            
            let NoteController = mainStoryboard.instantiateViewController(withIdentifier: "NoteController") as! NoteController
            
            NoteController.note = newNote
            
            self.navigationController?.pushViewController(NoteController, animated: true)
        }*/
        
        let newNote = Note(id: nil, title: "", content: "", pictures: [], date: Date())
        
        let NoteController = mainStoryboard.instantiateViewController(withIdentifier: "NoteController") as! NoteController
        
        NoteController.note = newNote
        
        self.navigationController?.pushViewController(NoteController, animated: true)
    }
    
    func addTestData(){
    
        for i in 1...10{
            //creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "INSERT INTO Notes (title, content, date) VALUES (?,?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let title = "note\(i)"
            let content = "contenu\(i)"
            
            let dateFormatter: DateFormatter = {
                let _formatter = DateFormatter()
                _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
                _formatter.locale = Locale(identifier: "FR-fr")
                return _formatter
            }()
            
            let date = dateFormatter.string(from: Date())
            
            let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
            
            if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding title: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, content, -1, SQLITE_TRANSIENT ) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding content: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, date, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding date: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting notes: \(errmsg)")
                return
            }
                
        }
        
        print("notes saved successfully")
    }
    
    func deleteAllNotes(){
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "DELETE FROM Notes"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
    }
    
    func deleteNote(id: Int) {
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "DELETE FROM Notes WHERE id = \(id)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as! NoteTableViewCell
        
        let note = notes![indexPath.row]
        cell.configure(note: note)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let NoteController = mainStoryboard.instantiateViewController(withIdentifier: "NoteController") as! NoteController
        
        NoteController.note = self.notes?[indexPath.row]
        
        self.navigationController?.pushViewController(NoteController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        return swipeConfig
    }
    
    func contextualToggleFlagAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let note = notes![indexPath.row];
        let id = note.id
        
        let action = UIContextualAction(style: .normal,title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
            self.deleteNote(id: id!)
            self.notes?.remove(at: indexPath.row)
            
            self.notesTableView.reloadData();
        }
        
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor =  UIColor.red
        return action
    }
}
