//
//  BookSearchViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/6/24.
//

import UIKit

class BookSearchViewController: UIViewController{
    
    let bookSite = "https://www.aladin.co.kr/ttb/api/ItemSearch.aspx"//도서검색 요철 URLaddress
    let TTBKey = "ttbsm39041712001"//ttbkey
    
    
    @IBOutlet weak var bookTableView: UITableView!
    var searchText: String?
    @IBOutlet weak var resultLabel: UILabel!
    
  
    
    
    let papaImage = UIImage(named: "papa")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookTableView.dataSource = self
        bookTableView.delegate = self
        // 전달받은 텍스트를 레이블에 설정
        if let text = searchText {
            resultLabel.text = text
        }
        
        getBookInfo(bookName: resultLabel.text ?? "없음")
        
    
       
        
    }
    
    
}
extension BookSearchViewController: UITableViewDelegate{

    // 특정 row를 클릭하면 이 함수가 호출된다
    func tableView(_ tableView: UITableView, didSelectRowAt
                   indexPath: IndexPath) {
        resultLabel.text = "   \(indexPath.row)th row was selected"
    }
}

extension BookSearchViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = UITableViewCell()
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = "hiroo"
        nameLabel.textColor = .gray
        nameLabel.backgroundColor = .black
        let imageView = UIImageView(image: papaImage)
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel])
        outer.spacing = 10
        
        cell.contentView.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    outer.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outer.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 1),
                    outer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    outer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    nameLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 5)
                ])
        
        return cell
    }
}





////요청 URL샘플 : http://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=[TTBKey]&Query=aladdin&QueryType=Title&MaxResults=10&start=1&SearchTarget=Book&output=xml&Version=20070901

//let bookSite = "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx"//도서검색 요철 URLaddress

extension BookSearchViewController{
    func getBookInfo(bookName: String){
        var urlStr = bookSite
        urlStr += "?"+"ttbkey=[\(TTBKey)]"
        urlStr += "&"+"Query="
        let Query = bookName
        let QueryText = "&QueryType=Title&MaxResults=10&start=1&SearchTarget=Book&xml&Version=20131101"//20131101
        urlStr += Query
        urlStr += QueryText
        let request = URLRequest(url: URL(string: urlStr)!) // 디폴트가 GET방식이다
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request){ (data, response, error) in
            guard let jsonData = data else{ print(error!); return }
            if let jsonStr = String(data:jsonData, encoding: .utf8){
                print(jsonStr)
            }
        }
        dataTask.resume()
    }
}
