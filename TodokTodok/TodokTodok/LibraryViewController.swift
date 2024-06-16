//
//  LibraryViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/9/24.
//

import UIKit
import Firebase

class LibraryViewController: UIViewController{
    
    
    var books: [Book] = TodokTodok.load("bookData.json")
    var filteredBooks: [Book] = []  // 필터링된 책 배열
    var imagePool: [String: UIImage] = [:]
    
    var dbFirebase : DbFirebase!
    var selected : Int?
    var filterState : String = ""
    
    @IBOutlet weak var libraryTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var totalBtn: UIButton!
    @IBOutlet weak var completedBookBtn: UIButton!
    @IBOutlet weak var readingBookBtn: UIButton!
    @IBOutlet weak var wannaBookBtn: UIButton!
    
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    let basicImage = UIImage(named: "Todok")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryTableView.dataSource = self
        libraryTableView.delegate = self
        // 전달받은 텍스트를 레이블에 설정
        
        dbFirebase = DbFirebase(parentNotification: manageDatabase)
        if dbFirebase == nil {
            print("DbFirebase 객체 초기화 실패")
            // 처리할 로직 추가
        } else {
            dbFirebase.setQuery(from: 1, to: 10000000000)
            print("DbFirebase 객체 초기화")
        }

        let writeMemoVC = writeMemoViewController()
        writeMemoVC.libraryViewController = self
        
        totalBtn.addTarget(self, action: #selector(totalPressed), for: .touchUpInside)
        completedBookBtn.addTarget(self, action: #selector(completedPressed), for: .touchUpInside)
        readingBookBtn.addTarget(self, action: #selector(readingPressed), for: .touchUpInside)
        wannaBookBtn.addTarget(self, action: #selector(wannaPressed), for: .touchUpInside)
                
        // 초기화 시 모든 책을 보여줍니다.
        filteredBooks = books
        filterState = "total"
        // 테이블 뷰에 셀 등록
        libraryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookCell")
        libraryTableView.reloadData()  // 테이블 뷰 초기화
    }
    
    
    
    @IBAction func editingTableViewRow(_ sender: UIBarButtonItem) {
        if libraryTableView.isEditing == true{
            sender.title = "Edit"
            libraryTableView.isEditing = false
        }
        else{
            sender.title = "Done"
            libraryTableView.isEditing = true
        }
    }
    
    
    @objc func totalPressed(_ sender: UIButton){
        print("total_Book!")
        filteredBooks = books
        filterState = "total"
        libraryTableView.reloadData()
    }
    @objc func completedPressed(_ sender: UIButton) {
        print("completed_Book!")
        filterState = "completed"
        filteredBooks = books.filter { $0.state == "completed" }
        print(filteredBooks)
        libraryTableView.reloadData()
   }
        
   @objc func readingPressed(_ sender: UIButton) {
       print("reading_Book!")
       filterState = "reading"
       filteredBooks = books.filter { $0.state == "reading" }
       print(filteredBooks)
       libraryTableView.reloadData()
   }
        
   @objc func wannaPressed(_ sender: UIButton) {
       print("wanna_Book!")
       filterState = "wanna"
       filteredBooks = books.filter { $0.state == "wanna" }
       print(filteredBooks)
       libraryTableView.reloadData()
   }
    
    
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?) {
        guard let dict = dict, let book = Book.fromDict(dict: dict) else {
            print("Failed to parse book from dict: \(String(describing: dict))")
            return
        }
        
        switch dbaction {
        case .add:
            books.append(book)
        case .modify:
            if let index = books.firstIndex(where: { $0.id == book.id }) {
                books[index] = book
            }
        case .delete:
            if let index = books.firstIndex(where: { $0.id == book.id }) {
                books.remove(at: index)
                
            }
        default:
            break
        }
        
        updateFilteredBooks()  // 변경된 상태를 필터에 반영
        libraryTableView.reloadData()
        
        if let indexPath = libraryTableView.indexPathForSelectedRow {
            nameLabel.text = books[indexPath.row].description
        }
    }
    
    
    func updateFilteredBooks() {
        switch filterState {
        case "completed":
            filteredBooks = filteredBooks.filter { $0.state == "completed" }
        case "reading":
            filteredBooks = filteredBooks.filter { $0.state == "reading" }
        case "wanna":
            filteredBooks = filteredBooks.filter { $0.state == "wanna" }
        default:
            filteredBooks = books
        }
    }
}

extension LibraryViewController: UITableViewDelegate{

    // 특정 row를 클릭하면 이 함수가 호출된다
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GotoDetail", sender: indexPath)
    }
    
    //삭제하는 경우
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //데베에서 삭제 해야함
            var selectedBook = filteredBooks[indexPath.row]
            selectedBook.state = ""
            selectedBook.memo = ""
            
            if selectedBook.id < 3{ //bookData에서 읽어온 것인 경우
                if let index = books.firstIndex(where: { $0.id == selectedBook.id }) {
                    books.remove(at: index)
                }
                filteredBooks.remove(at: indexPath.row)
                libraryTableView.reloadData()
            }else{
                let booksCollection = Firestore.firestore().collection("books")
                
                // 책 ID로 Firestore를 쿼리하여 문서 ID 찾기
               booksCollection.whereField("id", isEqualTo: selectedBook.id).getDocuments { [weak self] (querySnapshot, error) in
                   guard let self = self else { return }

                   if let error = error {
                       print("문서 가져오기 실패: \(error.localizedDescription)")
                       return
                   }

                   guard let document = querySnapshot?.documents.first else {
                       print("일치하는 문서를 찾을 수 없음")
                       return
                   }

                   let documentID = document.documentID
                   print(documentID)
                   // Firestore에서 문서 삭제
                   booksCollection.document(documentID).delete { error in
                       if let error = error {
                           print("책 삭제 실패: \(error.localizedDescription)")
                       } else {
                           print("책 삭제 성공!")
                           
                           // books 배열에서도 삭제
                           if let index = self.books.firstIndex(where: { $0.id == selectedBook.id }) {
                               self.books.remove(at: index)
                           }
                           // 책이 삭제된 후, filteredBooks를 업데이트하여 새로운 필터링 상태를 반영
                           self.updateFilteredBooks()
                           self.libraryTableView.reloadData()
                       }
                   }
               }
            }
        }
    }
    
    
    //이동하는 경우
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let book = filteredBooks.remove(at: sourceIndexPath.row)
        filteredBooks.insert(book, at: destinationIndexPath.row)
    }
    
    // 셀의 높이를 일정하게 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension LibraryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBooks.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell")!//pool에 저장하여 재사용
        let book = filteredBooks[indexPath.row]
        
    // 태그를 사용하여 서브뷰 식별
        let tagImageView = 100
        let tagNameLabel = 101
        let tagDescriptionLabel = 102
    // UIImageView 재사용 또는 생성
        var imageView: UIImageView
        if let existingImageView = cell.contentView.viewWithTag(tagImageView) as? UIImageView {
            imageView = existingImageView
        } else {
            imageView = UIImageView()
            imageView.tag = tagImageView
            cell.contentView.addSubview(imageView)
        }
        imageView.loadImage(from: book.imageName, placeholder: basicImage)
        
        // UILabel 재사용 또는 생성 (Name Label)
        var nameLabel: UILabel
        if let existingNameLabel = cell.contentView.viewWithTag(tagNameLabel) as? UILabel {
            nameLabel = existingNameLabel
        } else {
            nameLabel = UILabel()
            nameLabel.tag = tagNameLabel
            nameLabel.numberOfLines = 0
            nameLabel.textColor = .black
            nameLabel.font = UIFont.systemFont(ofSize: 14) // 원하는 크기로 설정
            cell.contentView.addSubview(nameLabel)
        }
        nameLabel.text = book.name
        
        // UILabel 재사용 또는 생성 (Description Label)
        var descriptionLabel: UILabel
        if let existingDescriptionLabel = cell.contentView.viewWithTag(tagDescriptionLabel) as? UILabel {
            descriptionLabel = existingDescriptionLabel
        } else {
            descriptionLabel = UILabel()
            descriptionLabel.tag = tagDescriptionLabel
            descriptionLabel.numberOfLines = 0
            cell.contentView.addSubview(descriptionLabel)
        }
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .right
        descriptionLabel.font = UIFont.systemFont(ofSize: 12) // 원하는 크기로 설정
        descriptionLabel.text = book.writer
        
        // 기존의 UIStackView 제거
        for view in cell.contentView.subviews where view is UIStackView {
            view.removeFromSuperview()
        }
        
        // 새로운 UIStackView 추가
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel,descriptionLabel])
        outer.spacing = 10
        cell.contentView.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    outer.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outer.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 1),
                    outer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    outer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    nameLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3),
                    descriptionLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3)
        ])
        
        return cell
        }
    }

extension LibraryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoDetail" {
            if let bookDetailViewController = segue.destination as? BookDetailViewController, let indexPath = sender as? IndexPath {
                let book: Book
                if filterState == "completed" || filterState == "reading" || filterState == "wanna" {
                    book = filteredBooks[indexPath.row]
                } else {
                    book = books[indexPath.row]
                }
                bookDetailViewController.book = book
                bookDetailViewController.libraryViewController = self
                bookDetailViewController.selectedBook = indexPath.row
            }
        }
    }
}


// UIImageView extension을 추가하여 URL에서 이미지를 로드하는 메서드를 정의
extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.image = placeholder
                }
            }
        }
    }
}
