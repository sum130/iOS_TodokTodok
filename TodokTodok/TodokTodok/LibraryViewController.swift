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
        // 테이블 뷰에 셀 등록
        libraryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookCell")
        
        
        libraryTableView.reloadData()  // 테이블 뷰 초기화
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
        
//          if dbaction == .add{  // 단순히 배열에 더한다
//            books.append(book)
//          }
//          if dbaction == .modify{ // 수정인 경우 선택된 row가 있으므로 그것을 수정
//            for i in 0..<books.count{   // 삭제 대상을 찾아야 한다.
//              if book.id == books[i].id{
//                  books[i] = book // 선택된 row의 정보 수정
//                imagePool[book.imageName] = nil
//                break
//              }
//            }
//          }
//          if dbaction == .delete{
//            for i in 0..<books.count{   // 삭제 대상을 찾아야 한다.
//              if book.id == books[i].id{
//                  books.remove(at: i)    // 삭제한다
//                break
//              }
//            }
//          }
        
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
        
//        // 필터링된 배열에서 해당 인덱스의 책을 가져옴
        let book: Book
        if filterState == "completed" || filterState == "reading" || filterState == "wanna" {
            print(filteredBooks)
            book = filteredBooks[indexPath.row]
        } else {
            book = books[indexPath.row]
        }

        
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
        imageView.loadImage(from: book.imageName, placeholder: papaImage)
        
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


// UIImageView extension을 추가하여 URL에서 이미지를 로드하는 메서드를 정의합니다.
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
