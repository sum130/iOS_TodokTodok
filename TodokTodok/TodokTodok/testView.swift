//
//  testView.swift
//  TodokTodok
//
//  Created by sumin Kong on 6/6/24.
//

import UIKit
class testViewController: UIViewController {


    @IBOutlet weak var resultlabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
    super.viewDidLoad()
   
        tableview.dataSource = self
        tableview.delegate = self
    
    //cityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "smkong")
    
    
    
    //cityTableView.isEditing = true
    
}
    
    
    
    

}

extension testViewController: UITableViewDataSource{
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}


func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "smkong")!
    
            cell.textLabel?.text = "BookName"
            cell.detailTextLabel?.text = "WriterName"
            cell.textLabel?.textAlignment = .right
    
    
    
    return cell
}

}

extension testViewController: UITableViewDelegate{
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    resultlabel.text = "test"

}
    
}

