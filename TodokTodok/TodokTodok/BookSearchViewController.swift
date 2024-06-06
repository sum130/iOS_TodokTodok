//
//  BookSearchViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/6/24.
//

import UIKit

class BookSearchViewController: UIViewController{
    
    
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
        
    
       
        
    }
    
    
}
extension BookSearchViewController: UITableViewDelegate{
    
    // 특정 row를 클릭하면 이 함수가 호출된다
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
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
        
        
//        let (r,g,b) = (CGFloat.random(in: 0...1), CGFloat.random(in: 0...1), CGFloat.random(in: 0...1))
//        let cell = UITableViewCell()
//        
//        cell.contentView.backgroundColor = UIColor(red: r , green: g, blue: b, alpha: 1.0)
        
        
    
//
//        cell.imageView?.image = papaImage
//        cell.textLabel?.text = "BookName"
//        cell.detailTextLabel?.text = "WriterName"
//        cell.textLabel?.textAlignment = .right

        
        let cell = UITableViewCell()
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.text = "hiroo"
        nameLabel.textColor = .gray
        nameLabel.backgroundColor = .black
        let imageView = UIImageView(image: papaImage)
        var outer = UIStackView(arrangedSubviews: [imageView,nameLabel])
        outer.spacing = 10
        
        cell.contentView.backgroundColor = .blue
        cell.contentView.addSubview(outer)
        outer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    outer.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outer.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 1),
                    outer.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    outer.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    imageView.widthAnchor.constraint(equalTo: nameLabel.widthAnchor, multiplier: 2)
                ])
        
        return cell
    }
    
    
    
}
