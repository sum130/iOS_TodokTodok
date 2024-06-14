//
//  LibraryViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/9/24.
//

import UIKit

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
    
    
    
    let papaImage = UIImage(named: "papa")
    
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
            dbFirebase.setQuery(from: 1, to: 10000)
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
        // 테이블 뷰에 셀 등록
       libraryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookCell")
        
        
        libraryTableView.reloadData()  // 테이블 뷰 초기화
    }
    
    @objc func totalPressed(_ sender: UIButton){
        print("total_Book!")
        filteredBooks = books
        filterState = "total"
        libraryTableView.reloadData()
        filterState = ""
    }
    @objc func completedPressed(_ sender: UIButton) {
        print("completed_Book!")
        filterState = "completed"
        filteredBooks = books.filter { $0.state == "completed" }
        print(filteredBooks)
        libraryTableView.reloadData()
        filterState = ""
   }
        
   @objc func readingPressed(_ sender: UIButton) {
       print("reading_Book!")
       filterState = "reading"
       filteredBooks = books.filter { $0.state == "reading" }
       print(filteredBooks)
       libraryTableView.reloadData()
       filterState = ""
   }
        
   @objc func wannaPressed(_ sender: UIButton) {
       print("wanna_Book!")
       filterState = "wanna"
       filteredBooks = books.filter { $0.state == "wanna" }
       print(filteredBooks)
       libraryTableView.reloadData()
       filterState = ""
   }
    
    
    
    
    
    
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?){
            //let book = Book.fromDict(dict: dict!)
        guard let dbFirebase = dbFirebase else {
                print("DbFirebase 객체가 초기화되지 않았습니다.")
                return
            }
        if(dbFirebase != nil){
            print("있음")
        }
        
        guard let dict = dict, let book = Book.fromDict(dict: dict) else {
                    print("Failed to parse book from dict: \(String(describing: dict))")
                    return
        }
        
          if dbaction == .add{  // 단순히 배열에 더한다
            books.append(book)
          }
          if dbaction == .modify{ // 수정인 경우 선택된 row가 있으므로 그것을 수정
            for i in 0..<books.count{   // 삭제 대상을 찾아야 한다.
              if book.id == books[i].id{
                  books[i] = book // 선택된 row의 정보 수정
                imagePool[book.imageName] = nil
                break
              }
            }
          }
          if dbaction == .delete{
            for i in 0..<books.count{   // 삭제 대상을 찾아야 한다.
              if book.id == books[i].id{
                  books.remove(at: i)    // 삭제한다
                break
              }
            }
          }
        libraryTableView.reloadData() // tableView의 내용을 업데이트한다
        print("success")
         
          if let indexPath = libraryTableView.indexPathForSelectedRow{
            // 만약 선택된 row가 있다면 그 도시의 discription 내용을 업데이트 한다
            nameLabel.text = books[indexPath.row].description
          }

    }
    
}

extension LibraryViewController: UITableViewDelegate{

    // 특정 row를 클릭하면 이 함수가 호출된다
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedBook = filteredBooks[indexPath.row] // 선택된 행의 책 가져오기
//            nameLabel.text = "\(selectedBook.state) - \(indexPath.row)th row was selected" // 책의 상태와 행 정보 출력
//    }
    

    // 특정 row를 클릭하면 이 함수가 호출된다
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "GotoDetail", sender: indexPath)
        }

    // 셀의 높이를 일정하게 설정
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100//return CGFloat(books.count)
        }
}

extension LibraryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filterState=="completed"||filterState=="reading"||filterState=="wanna"){
            return filteredBooks.count
        }
        else{
            return books.count
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell")!//pool에 저장하여 재사용
        //let cell = UITableViewCell()
        
            
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        
        // 필터링된 배열에서 해당 인덱스의 책을 가져옴
            let book: Book
            if filterState == "completed" || filterState == "reading" || filterState == "wanna" {
                print(filteredBooks)
                book = filteredBooks[indexPath.row]
            } else {
                book = books[indexPath.row]
            }
        
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = book.name
        nameLabel.textColor = .black
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = book.writer
      
  
        if book.state == "completed" {
            cell.detailTextLabel?.backgroundColor = .blue
        } else {
            cell.detailTextLabel?.backgroundColor = .clear
        }
    
        
        //let imageView = UIImageView()
        //imageView.loadImage(from: book.imageName)
        
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
