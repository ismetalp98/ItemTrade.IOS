//
//  ChatViewController.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 6/10/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation


final class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    public let otherUserId: String
    private var conversationId: String?
    public var isNewConversation = false
    public let otherUserName: String
    public let itemId: String
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let senderid = UserDefaults.standard.value(forKey: "userId") as? String else {
            return nil
        }
        
        return Sender(photoURL: "",
                      senderId: senderid,
                      displayName: "Me")
    }
    
    init(with ownerId: String, ownerName: String, id: String?, itemid: String) {
        self.conversationId = id
        self.otherUserId = ownerId
        self.otherUserName = ownerName
        self.itemId = itemid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        self.navigationItem.titleView = navTitleWithImageAndText(titleText: otherUserName)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        /*actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
         self?.presentVideoInputActionsheet()
         }))*/
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]  _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoorindates in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                let name = strongSelf.title,
                let selfSender = strongSelf.selfSender else {
                    return
            }
            
            let longitude: Double = selectedCoorindates.longitude
            let latitude: Double = selectedCoorindates.latitude
            
            print("long=\(longitude) | lat= \(latitude)")
            
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, itemId: self!.itemId, otherUserId: strongSelf.otherUserId, name: name, newMessage: message, completion: { success in
                if success {
                    print("sent location message")
                }
                else {
                    print("failed to send location message")
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    /*private func presentVideoInputActionsheet() {
     let actionSheet = UIAlertController(title: "Attach Video",
     message: "Where would you like to attach a video from?",
     preferredStyle: .actionSheet)
     actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
     
     let picker = UIImagePickerController()
     picker.sourceType = .camera
     picker.delegate = self
     picker.mediaTypes = ["public.movie"]
     picker.videoQuality = .typeMedium
     picker.allowsEditing = true
     self?.present(picker, animated: true)
     
     }))
     actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
     
     let picker = UIImagePickerController()
     picker.sourceType = .photoLibrary
     picker.delegate = self
     picker.allowsEditing = true
     picker.mediaTypes = ["public.movie"]
     picker.videoQuality = .typeMedium
     self?.present(picker, animated: true)
     
     }))
     actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
     
     present(actionSheet, animated: true)
     }*/
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    func navTitleWithImageAndText(titleText: String) -> UIView {
        
        let path = "Images/\(otherUserId)_profile_picture.png"
        
        
        // Creates a new UIView
        let titleView = UIView()
        
        // Creates a new text label
        let label = UILabel()
        label.text = titleText
        label.sizeToFit()
        label.center = titleView.center
        label.textAlignment = NSTextAlignment.center
        
        // Creates the image view
        let imageView = UIImageView()
        
        
        // Sets the image frame so that it's immediately before the text:
        let imageX = label.frame.origin.x - label.frame.size.height
        let imageY = label.frame.origin.y - 10
        
        let imageWidth = label.frame.size.height + 20
        let imageHeight = label.frame.size.height + 20
        
        imageView.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        // Adds both the label and image view to the titleView
        titleView.addSubview(label)
        titleView.addSubview(imageView)
        
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit()
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.senderPhotoURL = url
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("\(error)")
            }
        })
        return titleView
        
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let name = self.title,
            let selfSender = selfSender else {
                return
        }
        
        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            // Upload image
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, itemId: self!.itemId, otherUserId: strongSelf.otherUserId, name: name, newMessage: message, completion: { success in
                        
                        if success {
                            print("sent photo message")
                        }
                        else {
                            print("failed to send photo message")
                        }
                        
                    })
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            })
        }
        /*else if let videoUrl = info[.mediaURL] as? URL {
         let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
         
         // Upload Video
         
         StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
         guard let strongSelf = self else {
         return
         }
         
         switch result {
         case .success(let urlString):
         // Ready to send message
         print("Uploaded Message Video: \(urlString)")
         
         guard let url = URL(string: urlString),
         let placeholder = UIImage(systemName: "plus") else {
         return
         }
         
         let media = Media(url: url,
         image: nil,
         placeholderImage: placeholder,
         size: .zero)
         
         let message = Message(sender: selfSender,
         messageId: messageId,
         sentDate: Date(),
         kind: .video(media))
         
         DatabaseManager.shared.sendMessage(to: conversationId, otherUserId: strongSelf.otherUserId, name: name, newMessage: message, completion: { success in
         
         if success {
         print("sent photo message")
         }
         else {
         print("failed to send photo message")
         }
         
         })
         
         case .failure(let error):
         print("message photo upload error: \(error)")
         }
         })
         }*/
    }
    
}




//burda kaldın isnewconversation da 







extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() else {
                return
        }
        
        print("Sending: \(text)")
        
        let mmessage = Message(sender: selfSender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(text))
        
        // Send Message
        if isNewConversation {
            // create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserName, itemId: itemId, otherUserId: otherUserId, firstMessage: mmessage, completion: { [weak self]success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(mmessage.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("faield ot send")
                }
            })
        }
        else {
            guard let conversationId = conversationId else {
                return
            }
            
            // append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, itemId: itemId, otherUserId: otherUserId, name: otherUserName, newMessage: mmessage, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUesrEmail, senderEmail, randomInt
        guard let currentUserId = UserDefaults.standard.value(forKey: "userId") as? String else {
            return nil
        }
        
        
        let newIdentifier = "\(currentUserId)_\(itemId)"
        
        print("created message id: \(newIdentifier)")
        
        return newIdentifier
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
          layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
          layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            return .link
        }
        
        return .secondarySystemBackground
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            
            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
            /*case .video(let media):
             guard let videoUrl = media.url else {
             return
             }
             
             let vc = AVPlayerViewController()
             vc.player = AVPlayer(url: videoUrl)
             present(vc, animated: true)*/
        default:
            break
        }
    }
}
