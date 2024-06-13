//
//  DBFirebase.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/9/24.
//

import Foundation
import FirebaseFirestore

class DbFirebase: Database{
    // 데이터를 저장할 위치 설정
    var reference: CollectionReference = Firestore.firestore().collection("books")

  
    
    
    // 데이터의 변화가 생기면 알려쥐 위한 클로즈
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?
    // 이미 설정한 Query의 존재여부

    // 생성자에 기본값 설정
    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        // 클로저를 보관
        self.parentNotification = parentNotification
    }
    
    func setQuery(from: Any, to: Any) {
        if let query = existQuery{
            query.remove()
        }
        //새로운 쿼리를 설정한다. 원하는 필드, 원하는 데이터를 적절히 설정하면 된다.

        let query = reference.whereField("id", isGreaterThanOrEqualTo : 0).whereField("id", isLessThanOrEqualTo: 10000)
        existQuery = query.addSnapshotListener(onChangingData)
    }

    // 데이터 저장 메서드
        func saveChange(key: String, object: [String: Any], action: DbAction) {
            let documentRef = reference.document(key)
            if action == .delete {
                documentRef.delete()
            } else {
                documentRef.setData(object)
            }
        }
    
    
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?){
        guard let querySnapshot = querySnapshot else{return}
        if (querySnapshot.documentChanges.isEmpty){
            return
        }
        
        for documentChange in querySnapshot.documentChanges{
            let dict = documentChange.document.data()
            var action : DbAction?
            switch(documentChange.type){
                case    .added: action = .add
                case    .modified: action = .modify
                case    .removed: action = .delete
            }
            if let parentNotification = parentNotification {parentNotification(dict,action)}
        }
    }
    // 메모 업데이트 메서드
        func updateMemo(bookId: String, newMemo: String, completion: @escaping (Error?) -> Void) {
            let documentRef = reference.document(bookId)
            documentRef.updateData(["memo": newMemo]) { error in
                if let error = error {
                    print("Error updating memo: \(error)")
                }
                completion(error)
            }
        }
}



import FirebaseStorage
extension DbFirebase{
    func uploadImage(imageName: String, image: UIImage, completion: @escaping () -> Void){
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {return}
        
        let reference = Storage.storage().reference().child("books").child(imageName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        reference.putData(imageData, metadata: metaData, completion: { data, error in
            completion()
        })
    }
    
    func downloadImage(imageName: String, completion: @escaping (UIImage?) -> Void){
        let reference = Storage.storage().reference().child("my").child(imageName)
        let megaByte = Int64(10*1024*1024)
        reference.getData(maxSize: megaByte){ data, error in
            completion( data != nil ? UIImage(data: data!): nil)
        }
    }
    
}
