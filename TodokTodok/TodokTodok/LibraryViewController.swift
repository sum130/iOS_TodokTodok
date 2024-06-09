//
//  LibraryViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/9/24.
//

import UIKit

class LibraryViewController: UIViewController{
    
    
    
    
    
    @IBOutlet weak var libraryTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    let papaImage = UIImage(named: "papa")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryTableView.dataSource = self
        libraryTableView.delegate = self
        // 전달받은 텍스트를 레이블에 설정
        
        
       
        
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


