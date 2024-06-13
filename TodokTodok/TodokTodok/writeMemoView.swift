//
//  writeMemoView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/13/24.
//

import UIKit
import Firebase

class writeMemoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    var book: Book?
    
    var dbFirebase : DbFirebase?
    
    var saveMemo: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let book = book {
                    titleLabel.text = book.name.isEmpty ? "No Title" : book.name
                    if let image = UIImage(named: book.imageName) {
                        coverImageView.image = image
                    } else {
                        coverImageView.image = UIImage(named: "papa")
                    }
                    memoTextView.text = book.memo.isEmpty ? "No Memo" : book.memo
                }
    }
    
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        print("btnTapped")
        saveMemo?(memoTextView.text)
        guard let newMemo = memoTextView.text, let book = book else {
            print("Failed to get new memo text or book is nil")
            return
        }
        //firebase에 저장
        Firestore.firestore().collection("teseㅇㅇㅇㅇ").document("id").setData(["id": 1,"name":"name","writer":"writer", "description":"hi","imageName":"papa"])
        
        let bookId = String(book.id)
        let docRef = Firestore.firestore().collection("books").document(bookId)
        
        print(bookId)
        print(docRef)
                
        // Firebase에 메모 업데이트

        docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // 문서가 존재할 때 업데이트를 수행
                        self.dbFirebase?.updateMemo(bookId: bookId, newMemo: newMemo) { [weak self] error in
                            if let error = error {
                                print("Failed to update memo in Firebase: \(error.localizedDescription)")
                                // 실패 시 오류 처리 로직을 추가할 수 있습니다.
                            } else {
                                print("Memo updated successfully")
                                
                                // 변경 사항 저장
                                self?.dbFirebase?.saveChange(key: bookId, object: Book.toDict(book: book), action: .modify)

                                    // 모든 작업이 완료되면 화면을 닫습니다.
                                    DispatchQueue.main.async {
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        }
                    else {
                        print("Document does not exist")
                        // 존재하지 않는 문서 처리 로직 추가
                    }
                }
        
    }
}
