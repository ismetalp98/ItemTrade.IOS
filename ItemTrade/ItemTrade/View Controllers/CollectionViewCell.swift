//
//  CollectionViewCell.swift
//  ItemTrade
//
//  Created by Alp on 25.07.2020.
//  Copyright © 2020 Alp Eren. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ItemContent: UILabel!
    @IBOutlet weak var ItemTitle: UILabel!
    
    func set(item: Item)
    {
        self.ItemTitle.text = item.title
        self.ItemContent.text = item.content
        self.ItemImage.image = UIImage(named: "WhatsApp Image 2020-07-24 at 20.30.14")
    }
    
}

