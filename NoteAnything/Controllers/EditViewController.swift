//
//  EditViewController.swift
//  NoteAnything
//
//  Created by Rekeningku on 30/04/22.
//

import UIKit
import CoreData

class EditViewController: UIViewController {
    
    var objectID: NSManagedObjectID? {
        didSet {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do{
                let note = try context.existingObject(with: objectID!) as? Notes
                if let note = note {
                    DispatchQueue.main.async {
                        if let note = note.note {
                            self.textfield.text = note
                            self.note = note
                            self.saveButton.isEnabled = true
                        }
                        if let title = note.title {
                            self.searchBar.text = title
                            self.titleNote = title
                        }
                    }
                }
                
            }catch{}
        }
    }
    
    var note: String?
    var titleNote: String?
    
    lazy var editTextfiledDelegate: EditNotefieldDelegate  = {
        return EditNotefieldDelegate(callBack: {[weak self] value in self?.onChangeEditNote(value)})
    }()
    
    lazy var editTitlefieldDelegate: EditTitlefieldDelegate = {
        return EditTitlefieldDelegate(callback:{[weak self] value in self?.onChangeEditTitle(value)})
    }()
    
    func onChangeEditNote(_ value: String){
        note = value
        if value.isEmpty == self.saveButton.isEnabled {
            DispatchQueue.main.async {
                self.saveButton.isEnabled = !value.isEmpty
            }
        }
    }
    
    func onChangeEditTitle(_ value: String){
        titleNote = value
    }
    
    lazy var saveButton: UIButton = {
        let saveButton = UIButton.init(type: .system)
        saveButton.setTitle("Simpan", for: .normal)
        saveButton.setContentHuggingPriority(.required, for: .horizontal)
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(onSaveNote(_:)), for: .touchUpInside)
        return saveButton
    }()
    
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton.init(type: .system)
        deleteButton.setTitle("Hapus", for: .normal)
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        deleteButton.addTarget(self, action: #selector(onDeleteNote(_:)), for: .touchUpInside)
        if objectID == nil {
            deleteButton.isEnabled = false
        }
        return deleteButton
    }()
    
    lazy var searchBar: UISearchBar  = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Judul"
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.searchTextField.textColor = ColorApp.primaryText
        searchBar.delegate = editTitlefieldDelegate
        return searchBar
    }()
    
    lazy var rowTextfield: UIView = {
        let uiView = UIStackView()
        uiView.axis = .horizontal
        uiView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        uiView.isLayoutMarginsRelativeArrangement = true
        
        let backButton = UIButton.init(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(onBack(_:)), for: .touchUpInside)
        
        
        
        let paddingSaveButton = UIStackView()
        paddingSaveButton.isLayoutMarginsRelativeArrangement = true
        paddingSaveButton.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 0)
        paddingSaveButton.addArrangedSubview(saveButton)
        
        uiView.addArrangedSubview(backButton)
        uiView.addArrangedSubview(searchBar)
        uiView.addArrangedSubview(deleteButton)
        uiView.addArrangedSubview(paddingSaveButton)
        return uiView
    }()
    
    lazy var textfield: UITextView = {
        let textfield = UITextView()
        textfield.backgroundColor = .white
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = .systemFont(ofSize: 16)
        textfield.textContainerInset = .init(top: 16, left:16, bottom: 16, right: 16)
        textfield.becomeFirstResponder()
        textfield.textColor = ColorApp.primaryText
        textfield.delegate = editTextfiledDelegate
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        super.viewDidDisappear(animated)
    }
    
    
    @objc func onBack(_ sender: Any?){
        navigationController?.popViewController(animated: true)
    }
    
    func setupLayout(){
        
        let columnContent = UIStackView()
        columnContent.axis = .vertical
        columnContent.translatesAutoresizingMaskIntoConstraints = false
        
        rowTextfield.setContentHuggingPriority(.required, for: .vertical)
        
        columnContent.addArrangedSubview(rowTextfield)
        columnContent.addArrangedSubview(textfield)
        
        view.addSubview(columnContent)
        
        let constraint = [
            columnContent.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            columnContent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            columnContent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            columnContent.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraint)
        
    }
    
    @objc func onSaveNote(_ sender: Any?){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            if let noteString = note {
                if let objectID = self.objectID {
                    let note = try context.existingObject(with: objectID) as? Notes
                    note?.title = titleNote
                    note?.note = noteString
                    note?.date = Date()
                    try context.save()
                    
                }else{
                    let savedNoted = Notes(context: context)
                    savedNoted.note = noteString
                    savedNoted.date = Date()
                    savedNoted.title = titleNote
                    try context.save()
                }
                navigationController?.popViewController(animated: true)
            }
        }catch{}
        
    }
    
    @objc func onDeleteNote(_ sender: Any){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let callback: () -> () = {
            do {
                if let objectID = self.objectID {
                    let note = try context.existingObject(with: objectID) as? Notes
                    if let note = note {
                        context.delete(note)
                    }
                    try context.save()
                    self.navigationController?.popViewController(animated: true)
                }
            }catch{}
        }
        let alert = UIAlertController(title: "Hapus Catatan", message: "Apakan anda yakin untuk mengapus", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            callback()
        }))
        alert.addAction(UIAlertAction(title: "Batal", style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}


class EditNotefieldDelegate: NSObject, UITextViewDelegate{
    
    let callBack: (String) -> ()
    
    init(callBack : @escaping (String) -> ()) {
        self.callBack = callBack
        super.init()
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            callBack(text)
        }
    }
    
}

class EditTitlefieldDelegate: NSObject, UISearchBarDelegate{
    
    let callback: (String) -> ()
    
    init(callback: @escaping (String) -> ()) {
        self.callback = callback
        super.init()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        callback(searchText)
    }
    
}
