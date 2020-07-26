//
//  Tab1ViewController.swift
//  ItemTrade
//
//  Created by Alp on 25.07.2020.
//  Copyright © 2020 Alp Eren. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Tab1ViewController: UIViewController,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var ref: DatabaseReference!
    var dataArrayCells = [Item]()
    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionView.delegate=self
        self.collectionView.dataSource = self
        observeItems()
        
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        self.setUpGridView()
        

        // Do any additional setup after loading the view.
        
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setUpGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setUpGridView(){
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        
    }
    
    
    
    func observeItems(){
        let ref = Database.database().reference(withPath: "Items")
        
        
        ref.observe(.value, with: {(snapshot) in snapshot.value
            
            var newDataArray: [Item]  = []
            
            for child in snapshot.children{
                if let childSnapshots = child as? DataSnapshot,
                    let dict = childSnapshots.value as? [String:Any],
                    let title = dict["title"] as? String,
                    let content = dict["content"] as? String{
                    let item = Item(title: title, content: content)
                    newDataArray.append(item)
                }
            }
        /*var newDataArrayCells: [Item] = []
        db.collection("Items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.get("title") as? String? as Any)
                    let title = document.get("title") as? String
                    let content = document.get("content") as? String
                    let item = Item(title: title!, content: content!)
                    newDataArrayCells.append(item)
                }
            }
        }*/
        self.dataArrayCells = newDataArray
        self.collectionView.reloadData()
        
    })
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArrayCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.set(item: dataArrayCells[indexPath.row])
        Utilities.styleItemCardView(cell)
        return cell
    }
    

}

extension Tab1ViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func calculateWith() -> CGFloat{
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2 )
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount-1) - margin)
        let withlast = width / cellCount
        
        return withlast
    }
}
