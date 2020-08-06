//
//  ItemPhotosCollectionViewCell.swift
//  Messenger
//
//  Created by Alp on 29.07.2020.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit

class ItemPhotosCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ItemPhotosCollectionViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(userImageView)
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
        
    }
    
    public func configure(url: String ) {
        let urlconverted = URL.init(string: url)
        DispatchQueue.main.async {
            self.userImageView.sd_setImage(with: urlconverted, completed: nil)
        }
    }
    
}
