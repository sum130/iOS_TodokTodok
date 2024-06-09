//
//  Book.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/10/24.
//

import Foundation

import SwiftUI
import CoreLocation

struct Book: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var writer: String
    var description: String
    var imageName: String
    
    init(id: Int, name: String, writer: String, description: String, imageName: String) {
        self.id = id
        self.name = name
        self.writer = writer
        self.description = description
        self.imageName = imageName
    }

    func uiImage(size: CGSize? = nil) -> UIImage?{
        //let image = UIImage(named: imageName)!
        guard let image = UIImage(named: imageName) else {return nil}
        
        guard let size = size else{ return image}
        
        // context를 획득 (사이즈, 투명도, scale 입력)
        // scale의 값이 0이면 현재 화면 기준으로 scale을 잡고, sclae의 값이 1이면 self(이미지) 크기 기준으로 설정
        UIGraphicsBeginImageContext(size)

        // 이미지를 context에 그린다.
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // 그려진 이미지 가져오기
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
        
        // context 종료
        UIGraphicsEndImageContext()
        return resizedImage
    }

    var image: Image {
        Image(imageName)
    }
}

extension Book{
    static func toDict(book: Book) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = book.id
        dict["name"] = book.name
        dict["writer"] = book.writer
        dict["description"] = book.description
        dict["imageName"] = book.imageName

        dict["datetime"] = Date().timeIntervalSince1970//현재 시간
        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Book{
        
        let id = dict["id"] as! Int
        let name = dict["name"] as! String
        let writer = dict["writer"] as! String
        let description = dict["description"] as! String
        let imageName = dict["imageName"] as! String

        return Book(id: id, name: name, writer: writer, description: description, imageName: imageName)
    }
}

