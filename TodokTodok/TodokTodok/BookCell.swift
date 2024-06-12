//
//  BookCell.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/12/24.
//

import UIKit

class BookCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    
    func configure(with book: Book) {
        nameLabel.text = book.name
        descriptionLabel.text = book.description
        bookImageView.image = UIImage(named: book.imageName)
        
        if book.state == "completed" {
            descriptionLabel.backgroundColor = .blue
        } else {
            descriptionLabel.backgroundColor = .clear
        }
    }
}
