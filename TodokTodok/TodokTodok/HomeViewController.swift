//
//  HomeViewController.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/6/24.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var BookSearchBar: UISearchBar!
    @IBOutlet weak var MainTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        BookSearchBar.delegate = self
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        // 검색바의 텍스트를 메인 텍스트 라벨에 설정
        MainTextLabel.text = searchBar.text
        // 키보드 내리기
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "BookSearch", sender: self)
    }


}

extension HomeViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? BookSearchViewController {
            destinationVC.searchText = BookSearchBar.text
        }
        print("\(BookSearchBar.text)");
    }
}

