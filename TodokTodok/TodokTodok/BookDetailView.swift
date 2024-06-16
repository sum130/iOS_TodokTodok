//
//  BookDetailView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/12/24.
//


import UIKit
import FirebaseFirestore

class BookDetailViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    var book : Book?
    var libraryViewController : LibraryViewController!
    var recordViewController : recordViewController!
    var bookSearchViewController: BookSearchViewController!
    var selectedBook: Int?
    
    let basicImage = UIImage(named: "Todok")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 책 정보 업데이트
        if let book = book {
            titleLabel.text = book.name
            //coverImageView.image = UIImage(named: book.imageName)
            coverImageView.loadImage(from: book.imageName, placeholder: basicImage)
            contentLabel.text = "<저자>\n" + book.writer + "\n\n<설명>\n" + book.description + "\n\n<읽기 상태>\n" + book.state
            if(book.memo==""){
                memoLabel.text = "<나의 기록>\n    없음."
            }else{
                memoLabel.text = "<나의 기록>\n" + book.memo
            }
            
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
                selectedState = "읽기 상태 선택"
                
            }
            stateBtn.setTitle(selectedState, for: .normal)// 상태 버튼의 제목 업데이트

        }
        
        // stateBtn 메뉴 설정
        setupStateButtonMenu()
           
        
        // memoLabel에 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(memoLabelTapped))
        memoLabel.isUserInteractionEnabled = true
        memoLabel.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func memoLabelTapped() {
        performSegue(withIdentifier: "showWriteMemo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWriteMemo", let memoVC = segue.destination as? writeMemoViewController {
            memoVC.book = book

            memoVC.saveMemo = { [weak self] newMemo in
                self?.book?.memo = newMemo
                self?.memoLabel.text = "<나의 기록>\n" + newMemo
                
                // libraryViewController에도 변경 사항을 반영
                if let index = self?.selectedBook {
                    if index < self?.libraryViewController?.books.count ?? 0 {
                        self?.libraryViewController?.books[index].memo = newMemo
                    }
                    if index < self?.libraryViewController?.filteredBooks.count ?? 0 {
                        self?.libraryViewController?.filteredBooks[index].memo = newMemo
                    }
                    self?.libraryViewController?.libraryTableView.reloadData()
                }
                
                // recordViewController에도 변경 사항을 반영
                if let index = self?.selectedBook {
                    if index < self?.recordViewController?.recordedBooks.count ?? 0 {
                        self?.recordViewController?.recordedBooks[index].memo = newMemo
                        self?.recordViewController?.recordTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    func setupStateButtonMenu() {
        // 기본 선택 요소 설정
        var defaultStateTitle: String?
        if let book = book {
            switch book.state {
            case "completed":
                defaultStateTitle = "읽기 완료"
            case "reading":
                defaultStateTitle = "읽는 중"
            case "wanna":
                defaultStateTitle = "읽고 싶음"
            default:
                defaultStateTitle = "읽기 상태 선택"
            }
        }
        
        let completedAction = UIAction(title: "완료", handler: { [weak self] _ in
            self?.updateBookState(to: "completed")
        })
        let readingAction = UIAction(title: "읽는 중", handler: { [weak self] _ in
            self?.updateBookState(to: "reading")
        })
        let wannaAction = UIAction(title: "읽고 싶음", handler: { [weak self] _ in
            self?.updateBookState(to: "wanna")
        })
        let noAction = UIAction(title: "읽기 상태 선택", handler: { [weak self] _ in
            self?.updateBookState(to: "")
        })
        
        let menu = UIMenu(title: "상태 변경", children: [completedAction, readingAction, wannaAction, noAction])
        stateBtn.menu = menu
        stateBtn.showsMenuAsPrimaryAction = true
        
        // 기본 선택 요소에 따라 버튼의 타이틀을 설정
        if let defaultStateTitle = defaultStateTitle {
            stateBtn.setTitle(defaultStateTitle, for: .normal)
        }
    }

    
    func updateBookState(to newState: String) {
        guard var book = self.book, let libraryViewController = self.libraryViewController, let selectedBookIndex = self.selectedBook else {
            return
        }
        // Remove book from libraryViewController's filteredBooks array if it exists
        if let filteredIndex = libraryViewController.books.firstIndex(where: { $0.id == book.id }) {/////////
            libraryViewController.books.remove(at: filteredIndex)
            print("removeee")
        }
        
        // Update book state
        book.state = newState
        
        // Update book in libraryViewController's books array
        if selectedBookIndex < libraryViewController.books.count {
            libraryViewController.books[selectedBookIndex] = book
        }
        
        // Update Firestore document
        updateFirestoreDocument(book: book)
        
        libraryViewController.updateFilteredBooks()
        
       // Reload library table view to reflect changes
       libraryViewController.libraryTableView.reloadData()
        // Dismiss or navigate back to previous view if needed
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func updateFirestoreDocument(book: Book) {
        let bookId = book.id
        let booksCollection = Firestore.firestore().collection("books")
        
        // Find the document with bookId
        booksCollection.whereField("id", isEqualTo: bookId).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to fetch documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found, adding new document")
                self.addBookToFirestore(book: book)
                return
            }
            
            // Update existing document
            let document = documents[0]
            let documentId = document.documentID
            let dict = Book.toDict(book: book)
            
            booksCollection.document(documentId).setData(dict) { error in
                if let error = error {
                    print("Error updating document: \(error.localizedDescription)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }

        
        
        func addBookToFirestore(book: Book) {
            let booksCollection = Firestore.firestore().collection("books")
            let dict = Book.toDict(book: book)
            
            booksCollection.addDocument(data: dict) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document successfully added")
                    print(book)
                }
            }
        }
        
        
        
        func stateBtnPressed(_ sender: UIButton) {
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
                memoLabel.text = "\nMemo: " + book.memo
                
                // libraryViewController에도 변경 사항을 반영
                if let index = selectedBook {
                    // books 배열 업데이트
                    if index < libraryViewController.books.count {
                        libraryViewController.books[index] = book
                    }
                    
                    // filteredBooks 배열 업데이트
                    if index < libraryViewController.filteredBooks.count {
                        libraryViewController.filteredBooks[index] = book
                    }
                    
                    // UI 업데이트
                    libraryViewController.libraryTableView.reloadData()
                }
                
            }
        }
        
    }


