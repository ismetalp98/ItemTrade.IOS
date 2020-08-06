//
//  ItemDetailViewController.swift
//  Messenger
//
//  Created by Alp on 29.07.2020.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//


import UIKit

final class ItemDetailViewController: UIViewController {
    
    private var item: Item
    var collectionView: UICollectionView!
    let maxWidth = UIScreen.main.bounds.width
    let maxHeight = UIScreen.main.bounds.height
    
    
    private let itemTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 28, weight: .medium)
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 310, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
        scroll.showsHorizontalScrollIndicator = true
        return scroll
    }()
    
    private let itemContentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 20
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    }()
    
    private let buyButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle("Send Message", for: .normal)
        Utilities.styleFilledButton(button)
        return button
    }()
    
    
    private let itemPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.isHidden = false
        return label
    }()
    
    public let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * (2/3))
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.minimumLineSpacing = CGFloat(0)
        layout.minimumInteritemSpacing = CGFloat(0)
        return layout
    }()
    
    init(with item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setTexts()
        setupCollectionView()
        view.addSubview(collectionView)
        scrollView.addSubview(itemTitleLabel)
        scrollView.addSubview(itemContentLabel)
        scrollView.addSubview(itemPriceLabel)
        scrollView.addSubview(buyButton)
        view.addSubview(scrollView)
        
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        
    }
    
    func setTexts()
    {
        itemPriceLabel.text = String(item.price) + " TL"
        itemTitleLabel.text = item.title
        itemContentLabel.text = item.content
    }
    
    private func setupCollectionView() {
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: view.width,
                          height: 300)
        
        collectionView = UICollectionView(frame: rect, collectionViewLayout: flowLayout)
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.dataSource = self
        self.collectionView.register(ItemPhotosCollectionViewCell.self, forCellWithReuseIdentifier: ItemPhotosCollectionViewCell.identifier)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        itemPriceLabel.frame = CGRect(x: 20,
                                      y: 20,
                                      width: view.width - 10,
                                      height: 20)
        
        itemTitleLabel.frame = CGRect(x: 20,
                                      y: itemPriceLabel.bottom + 15,
                                      width: view.width - 10,
                                      height: 20)
        
        itemContentLabel.frame = CGRect(x: 20,
                                        y: itemTitleLabel.bottom + 10,
                                        width: view.width - 30,
                                        height: 120)
        
        buyButton.frame = CGRect(x: view.width / 2 - view.width / 4,
                                 y: itemContentLabel.bottom + 20,
                                 width: view.width / 2,
                                 height: 50)
        
    }
    
    @objc private func buyButtonTapped() {
        
        let myId = UserDefaults.standard.value(forKey: "userId") as! String
        let path = "conversation_" + myId + "_" + item.itemId
        
        // item.id will be item.owner
        DatabaseManager.shared.conversationExists(with: path, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: self!.item.ownerId, ownerName: self!.item.ownerName, id: conversationId, itemid: self!.item.itemId)
                vc.isNewConversation = false
                //will be item.ownername
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.hidesBottomBarWhenPushed = false
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                //item.owner item.ownername
                let vc = ChatViewController(with: self!.item.ownerId, ownerName: (self!.item.ownerName), id: nil, itemid: self!.item.itemId)
                vc.isNewConversation = true
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}



extension ItemDetailViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let url = item.urls[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemPhotosCollectionViewCell.identifier, for: indexPath) as! ItemPhotosCollectionViewCell
        cell.configure( url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let url = item.urls[indexPath.item]
        openImage(url)
    }
    
    
    
    func openImage(_ url: String) {
        let urlconverted = URL.init(string: url)
        let vc = PhotoViewerViewController(with: urlconverted!)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: false)
    }
}


extension ItemDetailViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width - 10 , height: 290 )
    }
}

