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
    
   
    var books: [Book] = []
    var currentElement: String?
    var currentBook: Book?
    var foundCharacters: String = ""
    
    
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
    
    // 셀의 높이를 일정하게 설정
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
}



extension BookSearchViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        
        let book = books[indexPath.row]
        
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = book.name
        
        let writerLabel = UILabel()
        writerLabel.numberOfLines = 0
        writerLabel.text = book.writer
        writerLabel.textColor = .gray
        
        let imageView = UIImageView()
        imageView.loadImage(from: book.imageName)
        
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel,writerLabel])
        outer.spacing = 10
        
        cell.contentView.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    outer.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outer.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 1),
                    outer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    outer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    nameLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 5),
                    writerLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2)
                ])
        
        return cell
    }
}





//let bookSite = "https://www.aladin.co.kr/ttb/api/ItemSearch.aspx"//도서검색 요철 URLaddress

extension BookSearchViewController{
    
    func getBookInfo(bookName: String){
        var urlStr = bookSite
        urlStr += "?"+"ttbkey=\(TTBKey)"
        urlStr += "&"+"Query="
        let Query = bookName
        let QueryText = "&QueryType=Title&MaxResults=10&start=1&SearchTarget=Book&js&Version=20131101"
        urlStr += Query
        urlStr += QueryText
        //urlStr = "https://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=ttbsm39041712001 &Query=aladdin&QueryType=Title&MaxResults=10&start=1&SearchTarget=Book&output=xml&Version=20070901"
        //print(urlStr)
        
        
        let request = URLRequest(url: URL(string: urlStr)!) // 디폴트가 GET방식이다
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request){ (data, response, error) in
            guard let jsonData = data else{ print(error!); return }
            
//            if let jsonStr = String(data:jsonData, encoding: .utf8){
//                print("!!!!\n"+jsonStr)
//            }
            
            guard let xmlData = data else {
                            print(error ?? "Unknown error")
                            return
                        }
            let parser = XMLParser(data: xmlData)
            parser.delegate = self
            parser.parse()
            
            //let (infoStr, imageData) = self.makeUpBookInfo(jsonData: jsonData)
            //print(infoStr)
            
            
            DispatchQueue.main.async {
                // 업데이트할 UI 코드 작성
            }
            
        }
        dataTask.resume()
    }
}


extension BookSearchViewController: XMLParserDelegate{
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
            if elementName == "item" {
                self.currentBook = nil
                currentBook = Book(id: 0, name: "", writer: "", description: "", imageName: "", state: "wanna", memo: "")
                if let itemId = attributeDict["itemId"], let id = Int(itemId) {
                    currentBook?.id = id
                }
            }
        else if elementName == "title" || elementName == "author" || elementName == "description" || elementName == "cover" {
                    currentElement = elementName
                    foundCharacters = ""
                }
    }
    
    
    
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            foundCharacters += string
        }
        
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            switch elementName {
            case "title":
                currentBook?.name = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "author":
                currentBook?.writer = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "description":
                currentBook?.description = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "cover":
                currentBook?.imageName = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "item":
                books.append(currentBook ?? Book(id: 1, name: "", writer: "", description: "", imageName: "", state: "wanna", memo: ""))
                    self.currentBook = nil
            default:
                break
            }

////
//                books.append(currentBook)
//                self.currentBook = nil
                currentElement = nil
                foundCharacters = ""
        }
    
        func parserDidEndDocument(_ parser: XMLParser) {
            DispatchQueue.main.async {
                // JSON 출력
                do {
                    // Books 배열을 JSON으로 변환
                    let jsonData = try JSONEncoder().encode(self.books)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("Parsed JSON: \(jsonString)")
                    } else {
                        print("Failed to convert JSON to string")
                    }
                } catch {
                    print("Error encoding books array to JSON: \(error)")
                }
                self.bookTableView.reloadData()
            }
        }
        func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            print("XML Parsing Error: \(parseError)")
        }
    }

extension UIImageView {//책이미지 다운받기
    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        // Create a URL session data task to fetch the image data
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            // Check for errors and ensure we received data
            guard let imageData = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Create an image from the data
            let image = UIImage(data: imageData)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.image = image
            }
        }
        
        // Start the data task
        task.resume()
    }
}
