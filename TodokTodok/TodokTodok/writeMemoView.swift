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
        navigationController?.popViewController(animated: true)
    }
    
}
