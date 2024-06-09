//
//  LibraryViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/9/24.
//

import UIKit

class LibraryViewController: UIViewController{
    
    
    var books: [Book] = TodokTodok.load("bookData.json")
    var imagePool: [String: UIImage] = [:]
    
    var dbFirebase : DbFirebase?
    var selected : Int?
    
    
    @IBOutlet weak var libraryTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    let papaImage = UIImage(named: "papa")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryTableView.dataSource = self
        libraryTableView.delegate = self
        // 전달받은 텍스트를 레이블에 설정
        
        dbFirebase = DbFirebase(parentNotification: manageDatabase)
        dbFirebase?.setQuery(from: 1, to: 10000)
       
        
    }
    
    func manageDatabase(dict: [String: Any]?, dbaction: DbAction?){
            let book = Book.fromDict(dict: dict!)
          if dbaction == .add{  // 단순히 배열에 더한다
            books.append(book)
          }
          if dbaction == .modify{ // 수정인 경우 선택된 row가 있으므로 그것을 수정
            for i in 0..<books.count{   // 삭제 대상을 찾아야 한다.
              if book.id == books[i].id{
                  books[i] = book // 선택된 row의 시티정보 수정
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
    func tableView(_ tableView: UITableView, didSelectRowAt
                   indexPath: IndexPath) {
        nameLabel.text = "   \(indexPath.row)th row was selected"
    }
}

extension LibraryViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = UITableViewCell()
        
        let book = books[indexPath.row]// 현재 indexPath에 해당하는 책을 가져옴
        
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = book.name
        nameLabel.textColor = .black
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = book.description
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


