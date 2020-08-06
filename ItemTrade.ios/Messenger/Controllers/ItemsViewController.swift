//
//  ItemsViewController.swift
//  Messenger
//
//  Created by Alp on 28.07.2020.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseAuth

class ItemsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    private var items = [Item]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(noConversationsLabel)
        startListeningForCOnversations()
        setupCollectionView()
        self.navigationItem.largeTitleDisplayMode = .always
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForCOnversations()
        })
    }
    
    
    
    private func startListeningForCOnversations() {
        
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting items fetch...")
        
        DatabaseManager.shared.getAllItems( completion: { [weak self] result in
            switch result {
            case .success(let items):
                print("successfully got conversation models")
                guard !items.isEmpty else {
                    self?.collectionView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.collectionView.isHidden = false
                self?.items = items
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                self?.collectionView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        })
    }
    
    
    /*private func createNewConversation(result: SearchResult) {
     let name = result.name
     let email = DatabaseManager.safeEmail(emailAddress: result.email)
     
     // check in datbase if conversation with these two users exists
     // if it does, reuse conversation id
     // otherwise use existing code
     
     DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
     guard let strongSelf = self else {
     return
     }
     switch result {
     case .success(let conversationId):
     let vc = ChatViewController(with: email, id: conversationId)
     vc.isNewConversation = false
     vc.title = name
     vc.navigationItem.largeTitleDisplayMode = .never
     strongSelf.navigationController?.pushViewController(vc, animated: true)
     case .failure(_):
     let vc = ChatViewController(with: email, id: nil)
     vc.isNewConversation = true
     vc.title = name
     vc.navigationItem.largeTitleDisplayMode = .never
     strongSelf.navigationController?.pushViewController(vc, animated: true)
     }
     })
     }*/
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUpGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        collectionView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
    
    func setUpGridView(){
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        
    }
    
}

extension ItemsViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = indexPath.item
        openConversation(model)
    }
    
    
    
    func openConversation(_ model: Int) {
        let vc = ItemDetailViewController(with: items[model])
        vc.title = items[model].title
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: false)
    }
}


extension ItemsViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        let height = width
        return CGSize(width: width, height: height )
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
