//
//  ViewController.swift
//  NoteAnything
//
//  Created by Rekeningku on 29/04/22.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var notes : [Notes] = []
    
    lazy var collectionList: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let uiCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        uiCollectionView.register(NoteCollectionCell.self, forCellWithReuseIdentifier: NoteCollectionCell.identifier)
        uiCollectionView.backgroundColor = ColorApp.background
        return uiCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorApp.background
        
        setupLayout()
        setupNavigationBar()
        setupListCollection()
        fectchNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fectchNotes()
    }
    
    private func setupLayout(){
        view.addSubview(collectionList)
    }

    private func setupNavigationBar(){
        setNeedsStatusBarAppearanceUpdate()
        navigationItem.title = "Semua Catatan"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigateToEditView(_:)) )
    }
    
    func setupListCollection(){
        collectionList.dataSource = self
        collectionList.delegate = self
    }
    
    @objc func navigateToEditView(_ sender: Any?){
        navigationController?.pushViewController(EditViewController(), animated: true)
    }
    
    @objc func navigateToEditViewWithObjectID(_ objectID: NSManagedObjectID?){
        let controller = EditViewController()
        controller.objectID = objectID
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func fectchNotes(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            notes = try context.fetch(Notes.fetchRequest())
            DispatchQueue.main.async {
                self.collectionList.reloadData()
            }
        }catch{}
    }
    
    
}


extension HomeViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionCell.identifier, for: indexPath) as! NoteCollectionCell
        let note = notes[indexPath.row]
        cell.note = note
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: (width / 2) - 24, height: (width / 2) - 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        navigateToEditViewWithObjectID(note.objectID)
    }
    
}

class NoteCollectionCell : UICollectionViewCell {
    
    static let identifier = "NoteCollectionCell"
    
    var note: Notes! {
        didSet {
            if let title = note.title {
                labelTitle.text = title
            }
            if let date = note.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MM yyyy"
                labelDate.text = formatter.string(from: date)
            }
            if let note = note.note {
                labelNote.text = note
            }
          
        }
    }
    
    lazy var labelTitle: UILabel = {
        let labelTitle = UILabel()
        labelTitle.font = UIFont.boldSystemFont(ofSize: 14)
        labelTitle.textColor = ColorApp.primaryText
        labelTitle.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
        return labelTitle
    }()
    
    lazy var labelDate: UILabel = {
        let labelDate = UILabel()
        labelDate.font = UIFont.systemFont(ofSize: 12)
        labelDate.textColor = ColorApp.secondaryText
        labelDate.setContentHuggingPriority(UILayoutPriority(998), for: .vertical)
        return labelDate
    }()
    
    lazy var labelNote: UILabel = {
        let labelNote = UILabel()
        labelNote.numberOfLines = 0
        labelNote.font = UIFont.systemFont(ofSize: 14)
        labelNote.textColor = ColorApp.primaryText
        labelNote.setContentHuggingPriority(.defaultLow, for: .vertical)
        return labelNote
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorApp.boxColor
        layer.cornerRadius = 20
        clipsToBounds = true
        
        setupLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupLayout(){
        
        let content = UIStackView()
        content.axis = .vertical
        content.translatesAutoresizingMaskIntoConstraints = false
        
        content.addArrangedSubview(labelTitle)
        content.addArrangedSubview(labelDate)
        content.addArrangedSubview(labelNote)
        
        contentView.addSubview(content)
        
        let constraint = [
            content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ]
        
        NSLayoutConstraint.activate(constraint)
        
    }
    
}

