//
//  recordViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/13/24.
//

import UIKit
import Firebase

class recordViewController: UIViewController {

    var books: [Book] = TodokTodok.load("bookData.json")
    var dbFirebase : DbFirebase!
    var recordedBooks: [Book] = []  // 필터링된 책 배열
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var recordTableView: UITableView!
    
    let basicImage = UIImage(named: "Todok")
    var filterState : String = ""
    var isMemo : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordTableView.dataSource = self
        recordTableView.delegate = self
        
        //recordedBooks = recordedBooks.filter { $0.memo != "" }
        
        dbFirebase = DbFirebase(parentNotification: manageDatabase)
        if dbFirebase == nil {
            print("DbFirebase 객체 초기화 실패")
            // 처리할 로직 추가
        } else {
            dbFirebase.setQuery(from: 1, to: 10000000000)
            print("DbFirebase 객체 초기화")
        }
        // 상태와 메모가 비어 있지 않은 책만 필터링하여 recordedBooks 배열에 저장
        recordedBooks = books.filter { $0.state != "" && $0.memo != "" }
        recordTableView.reloadData()  // 테이블 뷰 초기화
    }
    
    
    @IBAction func editingRecordTable(_ sender: UIBarButtonItem) {
        if recordTableView.isEditing == true{
            sender.title = "Edit"
            recordTableView.isEditing = false
        }
        else{
            sender.title = "Done"
            recordTableView.isEditing = true
        }
        
    }
    
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?){
        guard let dbFirebase = dbFirebase else {
            print("DbFirebase 객체가 초기화되지 않았습니다.")
            return
        }
        
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
        // 필터링된 책 목록을 다시 설정
        recordedBooks = books.filter { $0.state != "" && $0.memo != "" }
        recordTableView.reloadData()  // tableView의 내용을 업데이트
    
        if let indexPath = recordTableView.indexPathForSelectedRow{
            //만약 선택된 row가 있다면 그 책의 description 내용을 업데이트한다
            noticeLabel.text = books[indexPath.row].description
        }
    }
}




//tableView
extension recordViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let selectedBook = recordedBooks[indexPath.row]  // 필터링된 책 목록에서 선택된 책 가져오기
       noticeLabel.text = "\(selectedBook.memo) - \(indexPath.row)th row was selected"  // 책의 상태와 행 정보 출력
       performSegue(withIdentifier: "recordToDetail", sender: indexPath)
   }

    
    
    
    
    //삭제하는 경우
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //데베에서 삭제 해야함
            var selectedBook = recordedBooks[indexPath.row]
            selectedBook.memo = ""
            
            if selectedBook.id < 3{ //bookData에서 읽어온 것인 경우
                recordedBooks.remove(at: indexPath.row)
                recordTableView.reloadData()
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
                   // 새로운 상태와 메모로 문서 업데이트
                   self.dbFirebase?.saveChange(key: documentID, object: Book.toDict(book: selectedBook), action: .modify)
               }
                recordTableView.reloadData()
            }
        }
    }
    
    
    //이동하는 경우
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let book = recordedBooks.remove(at: sourceIndexPath.row)
        recordedBooks.insert(book, at: destinationIndexPath.row)
    }
    
    
    
    
    
    
    
    
    
    
    // 셀의 높이를 일정하게 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100//return CGFloat(books.count)
    }
}


extension recordViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordedBooks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let book: Book
        book = recordedBooks[indexPath.row]
        print(book)
        
        
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
            descriptionLabel.text = book.writer
            
        
            
            
            // 기존의 UIStackView 제거
            for view in cell.contentView.subviews where view is UIStackView {
                view.removeFromSuperview()
            }
            
        
      
        
        
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


extension recordViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordToDetail" {
            if let bookDetailViewController = segue.destination as? BookDetailViewController, let indexPath = sender as? IndexPath {
                let book = recordedBooks[indexPath.row]  // 필터링된 책 목록에서 책 가져오기
                bookDetailViewController.book = book
                bookDetailViewController.recordViewController = self
                bookDetailViewController.selectedBook = indexPath.row
            }
        }
    }
}

