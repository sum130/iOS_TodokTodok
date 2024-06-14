//
//  recordViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/13/24.
//

import UIKit

class recordViewController: UIViewController {

    var recordedBooks: [Book] = TodokTodok.load("bookData.json")
    var dbFirebase : DbFirebase!
    var filteredBooks: [Book] = []  // 필터링된 책 배열
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var recordTableView: UITableView!
    
    let papaImage = UIImage(named: "papa")
    var filterState : String = ""
    var isMemo : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordTableView.dataSource = self
        recordTableView.delegate = self
        
        recordedBooks = recordedBooks.filter { $0.memo != "" }
        
        dbFirebase = DbFirebase(parentNotification: manageDatabase)
        if dbFirebase == nil {
            print("DbFirebase 객체 초기화 실패")
            // 처리할 로직 추가
        } else {
            dbFirebase.setQuery(from: 1, to: 10000000000)
            print("DbFirebase 객체 초기화")
        }
        
        
        recordTableView.reloadData()  // 테이블 뷰 초기화
    }
    
    
    
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?){
        guard let dict = dict, let book = Book.fromDict(dict: dict) else {
                    print("Failed to parse book from dict: \(String(describing: dict))")
                    return
        }
//        if dbaction == .modify{
//            if let indexPath = cityTableView.indexPathForSelectedRow{
//                cities[indexPath.row] = city //선택된 row의 시티정보 수정
//            }
//        }
//        if dbaction == .delete{
//            for i in 0..<cities.count{ //삭제 대상을 찾아야 한다.
//                if city.id == cities[i].id{
//                    cities.remove(at: i) //삭제한다
//                    break
//                }
//            }
//        }
        
        recordTableView.reloadData()//tableView의 내용 업데이트
        
        if let indexPath = recordTableView.indexPathForSelectedRow{
            //만약 선택된 row가 있다면 그 도시의 description 내용을 업데이트한다
            noticeLabel.text = recordedBooks[indexPath.row].description
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = recordTableView.indexPathForSelectedRow{
          noticeLabel.text = recordedBooks[indexPath.row].description
        }
        recordTableView.reloadData()
    }
    
}




//tableView
extension recordViewController: UITableViewDelegate{

//    // 특정 row를 클릭하면 이 함수가 호출된다
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            //performSegue(withIdentifier: "GotoDetail", sender: indexPath)
//
//        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = recordedBooks[indexPath.row] // 선택된 행의 책 가져오기
            noticeLabel.text = "\(selectedBook.memo) - \(indexPath.row)th row was selected" // 책의 상태와 행 정보 출력
        performSegue(withIdentifier: "recordToDetail", sender: indexPath)
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
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return recordedBooks.count
//    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filterState != "" && isMemo != ""){
            return filteredBooks.count
        }
        else{
            return recordedBooks.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let book: Book
        book = recordedBooks[indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = book.name
        nameLabel.textColor = .black
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = book.writer
      
  
        let imageView = UIImageView(image: UIImage(named: book.imageName)) // 책의 이미지로 설정
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel,descriptionLabel])
        outer.spacing = 10
        
        cell.contentView.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    outer.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outer.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 1),
                    outer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    outer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    nameLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 5),
                    descriptionLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 5)
                ])
        
        return cell
    }
    
}


extension recordViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordToDetail" {
            if let bookDetailViewController = segue.destination as? BookDetailViewController, let indexPath = sender as? IndexPath {
                let book: Book
                book = recordedBooks[indexPath.row]
                bookDetailViewController.book = book
                bookDetailViewController.recordViewController = self
                bookDetailViewController.selectedBook = indexPath.row
            }
        }
    }
}
