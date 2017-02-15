//
//  FeedTableViewController.swift
//  AC3.2-Final
//
//  Created by Kadell on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class FeedTableViewController: UITableViewController {
    
    let reuseIdentifier = "feedCell"
    var databaseReference: FIRDatabaseReference!
    
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "loginViewController")
        present(viewController, animated: false, completion: nil)
        
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        getPosts()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }
    
    func getPosts() {
        databaseReference.observeSingleEvent(of: .value, with: { (snapShot) in
            var newPosts: [Post] = []
            for child in snapShot.children {
                dump("********\(child)********")
                if let snap = child as? FIRDataSnapshot,
                    let valueDict = snap.value as? [String: Any] {
                        let post = Post(key: snap.key,
                                           comment: valueDict["comment"] as! String? ?? "",
                                           userId: valueDict["userId"] as! String? ?? "")
                         newPosts.append(post)
                }
            }
            self.posts = newPosts
            
         
            self.tableView.reloadData()
            
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FeedTableViewCell

       let post = self.posts[indexPath.row]
        cell.commentLabel.text = post.comment
        cell.pictureImageView.image = nil
        
        let storageRef = FIRStorage.storage().reference().child("images/\(post.key)")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    cell.pictureImageView.image = image
                    cell.setNeedsLayout()
                }
                
                
            }
        }

        return cell
    }
    
}
