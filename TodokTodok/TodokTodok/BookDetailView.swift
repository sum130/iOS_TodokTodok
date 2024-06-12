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
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    
    var book : Book?
    var libraryViewController : LibraryViewController!
    var selectedBook: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 책 정보 업데이트
        if let book = book {
            titleLabel.text = book.name
            coverImageView.image = UIImage(named: book.imageName)
            contentLabel.text = "author: " + book.writer + "\ndescription: " + book.description + "\nstate: " + book.state
            
            // 상태 버튼의 초기 선택 상태 설정
            let selectedState: String
            switch book.state {
            case "completed":
                selectedState = "completed"
            case "reading":
                selectedState = "reading"
            case "wanna":
                selectedState = "wanna"
            default:
                selectedState = ""
            }
            stateBtn.setTitle(selectedState.capitalized, for: .normal)// 상태 버튼의 제목 업데이트

        }
        
        // stateBtn 메뉴 설정
        setupStateButtonMenu()
           
    }
    
    func setupStateButtonMenu() {
        // 기본 선택 요소 설정
        var defaultStateTitle: String?
        if let book = book {
            switch book.state {
            case "completed":
                defaultStateTitle = "completed"
            case "reading":
                defaultStateTitle = "reading"
            case "wanna":
                defaultStateTitle = "wanna"
            default:
                defaultStateTitle = nil
            }
        }
        
        let completedAction = UIAction(title: "completed", handler: { [weak self] _ in
            self?.updateBookState(to: "completed")
        })
        let readingAction = UIAction(title: "reading", handler: { [weak self] _ in
            self?.updateBookState(to: "reading")
        })
        let wannaAction = UIAction(title: "wanna", handler: { [weak self] _ in
            self?.updateBookState(to: "wanna")
        })
        
        let menu = UIMenu(title: "Change State", children: [completedAction, readingAction, wannaAction])
        stateBtn.menu = menu
        stateBtn.showsMenuAsPrimaryAction = true
        
        // 기본 선택 요소에 따라 버튼의 타이틀을 설정
        if let defaultStateTitle = defaultStateTitle {
            stateBtn.setTitle(defaultStateTitle, for: .normal)
        }
    }

    
    
    func updateBookState(to newState: String) {
        if var book = book {
            book.state = newState
            
            // 변경된 상태를 contentTextView에 업데이트
            contentLabel.text = "author: " + book.writer + "\ndescription: " + book.description + "\nstate: " + book.state
            
            // libraryViewController에도 변경 사항을 반영
            if let index = selectedBook {
                libraryViewController?.books[index] = book
                libraryViewController?.filteredBooks[index] = book
                libraryViewController?.libraryTableView.reloadData()
            }
            // 메뉴 업데이트
            setupStateButtonMenu()
            stateBtn.setTitle(newState.capitalized, for: .normal)// 상태 버튼의 제목 업데이트
        }
    }
    
    
    @objc func stateBtnPressed(_ sender: UIButton) {
        print("stateBtn pressed")
        
        // book 객체의 상태 변경
        if var book = book {
            if book.state == "completed" {
                book.state = "reading"
            } else if book.state == "reading" {
                book.state = "wanna"
            } else {
                book.state = "completed"
            }
            
            // 변경된 상태를 contentTextView에 업데이트
            contentLabel.text = "author: " + book.writer + "\ndescription: " + book.description + "\nstate: " + book.state
            
            // libraryViewController에도 변경 사항을 반영
            if let index = selectedBook {
                libraryViewController?.books[index] = book
                libraryViewController?.filteredBooks[index] = book
                libraryViewController?.libraryTableView.reloadData()
            }
            
        }
    }


}

