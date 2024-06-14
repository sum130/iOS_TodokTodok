//
//  writeMemoView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/13/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class writeMemoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    var book: Book?
    var libraryViewController : LibraryViewController!
    var saveMemo: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if var book = book {
            titleLabel.text = book.name.isEmpty ? "No Title" : book.name
            if let image = UIImage(named: book.imageName) {
                coverImageView.image = image
            } else {
                coverImageView.image = UIImage(named: "papa")
            }
            memoTextView.text = book.memo.isEmpty ? "No Memo" : book.memo
            
        }
        if(libraryViewController?.dbFirebase==nil){
            print("없어")
        }
    }
    
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        print("btnTapped")
        saveMemo?(memoTextView.text)
        guard let newMemo = memoTextView.text, var book = book else {
            print("Failed to get new memo text or book is nil")
            return
        }
        
        book.memo = newMemo
        let bookId = book.id
        let booksCollection = Firestore.firestore().collection("books")
        print("Updated Memo:", book.memo)
        print("Book ID:", bookId)
        
        // book.id로 문서를 조회
        booksCollection.whereField("id", isEqualTo: bookId).getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found")
                return
            }
            
            // 첫 번째 문서 가져오기
            let document = documents[0]
            let documentId = document.documentID
            let dict = Book.toDict(book: book)
            let operation: DbAction = document.exists ? .modify : .add
            
            print("Document ID:", documentId)
            print("Document Data:", dict)
     ////
                    
            booksCollection.document(documentId).setData(dict) { error in
                   if let error = error {
                       print("Error updating document: \(error.localizedDescription)")
                   } else {
                       print("Document successfully updated")
                   }
               }
        }
    }
}

