//
//  ItemCollectionViewCell.swift
//  Messenger
//
//  Created by Alp on 28.07.2020.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ItemCollectionViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 18.0
        return imageView
    }()

    private let itemPrice: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Utilities.styleItemCardView(self)
        contentView.addSubview(userImageView)
        contentView.addSubview(itemPrice)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: frame.width,
                                     height: frame.height)

        itemPrice.frame = CGRect(x:  10,
                                 y: frame.height - 30,
                                     width: contentView.width - 20 ,
                                     height: 20)


    }

    public func configure(with model: Item ) {
        itemPrice.text = String(model.price)
        DispatchQueue.main.async {
            self.userImageView.image = UIImage(named: "logo-1")
        }
    }
}
