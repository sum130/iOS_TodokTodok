//
//  BookDetailView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/12/24.
//


import UIKit

class BookDetailViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var book : Book?
    
    
    var libraryViewController : LibraryViewController!
    var selectedBook: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 책 정보 업데이트
        if let book = book {
            titleLabel.text = book.name
            coverImageView.image = UIImage(named: book.imageName)
            contentTextView.text = book.description
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        // 검색바의 텍스트를 메인 텍스트 라벨에 설정
        // 키보드 내리기
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "BookSearch", sender: self)
    }


}

