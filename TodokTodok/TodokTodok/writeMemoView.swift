//
//  writeMemoView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/13/24.
//

import UIKit

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
            titleLabel.text = book.name
            coverImageView.image = UIImage(named: book.imageName)
            memoTextView.text = book.memo
        }
    }
    
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        saveMemo?(memoTextView.text)
        guard let newMemo = memoTextView.text, let book = book else {
            print("Failed to get new memo text or book is nil")
            return
        }
        
        // Firebase에 메모 업데이트
                dbFirebase?.updateMemo(bookId: String(book.id), newMemo: newMemo) { [weak self] error in
                    if let error = error {
                        print("Failed to update memo in Firebase: \(error)")
                        // 실패 시 오류 처리 로직을 추가할 수 있습니다.
                    } else {
                        // 성공 시 클로저 호출하여 UI 업데이트
                        self?.saveMemo?(newMemo)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
    }
}
