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
        nameLabel.textColor = .gray
        nameLabel.backgroundColor = .black
        let imageView = UIImageView(image: papaImage) //UIImageView(image: book.uiImage())
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
                currentBook = Book(id: 0, name: "", writer: "", description: "", imageName: "")
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
                print("title -> \(foundCharacters)") // 디버깅을 위해 추가
                currentBook?.name = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "author":
                print("author -> \(foundCharacters)")
                currentBook?.writer = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "description":
                print("description -> \(foundCharacters)")
                currentBook?.description = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "cover":
                print("cover -> \(foundCharacters)")
                currentBook?.imageName = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
                print(currentBook)
            case "item":
                books.append(currentBook ?? Book(id: 1, name: "", writer: "", description: "", imageName: ""))
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
        
        //    func makeUpBookInfo(jsonData: Data) -> (String, Data) {
        //
        //        let jsonObjct = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        //
        //        let id = jsonObjct["itemID"] as! Double
        //        let name = jsonObjct["bookName"] as! String
        //        let writer = jsonObjct["writer"] as! String
        //        let description = jsonObjct["descript"] as! String
        //        let imageName = jsonObjct["imageName"] as! String
        //
        //        var infoStr = "제목: \(name), 작가: \(writer)\n\(description)"
        //        let imageUrl = URL(string: "http://www.aladin.co.kr/shop/wproduct.aspx?ItemId=336137245&amp;partner=openAPI&amp;start=api")
        //        //imageName)
        //
        //        let data = try! Data(contentsOf: imageUrl!)
        //        return (infoStr, data)
        //    }
        
        
    }
