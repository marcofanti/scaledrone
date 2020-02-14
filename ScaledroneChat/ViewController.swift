//
//  ViewController.swift
//  ScaledroneChatTest
//
//  Created by Marin Benčević on 08/09/2018.
//  Copyright © 2018 Scaledrone. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


class ViewController: MessagesViewController {
    private var bSDK: BehavioSecIOSSDK = BehavioSecIOSSDK.shared()
    lazy var tMessage: UITextField = {
        let textField = UITextField()
        return textField
    } ()
    let behavioSession: BehavioSession = BehavioSession(user: "marcofanti2@behaviosec.com")
    
    var chatService: ChatService!
    var chatbotService: ChatbotService!
    var messages: [Message] = []
    var member: Member!
    var chatbotMember: Member!
    var lastMessageText: String = ""
    var replyToMessage = false
    var timingData: String = ""

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDelegates()
        configureMessageInputBar()
        
        title = "BehavioSec "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // conBottom.constant = view.frame.size.height / 2.5
        // setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        bSDK.clearRegistrations()
        super.viewDidDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        behavioSession.finalize()
        bSDK.clearRegistrations()
    }
    
    @objc
    func printChat() {
        //       callNetwork()
        print("printChat  " + (tMessage.text ?? " No text"))
        timingData = bSDK.getSummary()
        //        #if DEBUG
        //DEBUGGING-INFORMATION
        print("""
            
            
            
            timing:
            ==========
            \(timingData)
            
            
            
            """)
        //        #endif
    }
    
    func configureDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        
        tMessage.textColor = UIColor.blue
        
        messageInputBar.setMiddleContentView(tMessage, animated: false)
        
        messageInputBar.sendButton.setTitleColor(.brown, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.green.withAlphaComponent(0.3),
            for: .highlighted
        )
//        messageInputBar.layer.shadowColor = UIColor.black.cgColor
//        messageInputBar.layer.shadowRadius = 4
//        messageInputBar.layer.shadowOpacity = 0.3
//        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
//        messageInputBar.separatorLine.isHidden = true
        tMessage.textColor = UIColor.blue
        
        //       messageInputBar.setMiddleContentView(tMessage, animated: false)
        
        //messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        //messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        //let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), .flexibleSpace]
        //messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        messageInputBar.sendButton.activityViewColor = .white
        messageInputBar.sendButton.backgroundColor = .brown
        messageInputBar.sendButton.layer.cornerRadius = 10
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
        messageInputBar.sendButton.addTarget(self, action: #selector(printChat), for: .touchUpInside)
        messageInputBar.sendButton.isEnabled = true
        
        setUpChatbot()
        setup()
    }
    
    func setUpChatbot() {
        member = Member(name: .randomName, color: .random)
        chatbotMember = Member(name: "Banking", color: .random)
        
        chatService = ChatService(member: member, onRecievedMessage: {
            [weak self] message in
            self?.messages.append(message)
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToBottom(animated: true)
        })
        
        chatbotService = ChatbotService(member: chatbotMember, onRecievedMessage: {
            [weak self] message in
            print("Message received on otherchat" + message.text + " " + message.messageId)
            if (self!.replyToMessage) {
                let result = self!.behavioSession.getScoreForTimings(self?.timingData, andNotes: "Login Request", andReportFlag: "0", andOperatorFlag: "512")
                //#if DEBUG
                //DEBUGGING-INFORMATION
                print("""
                    
                    
                    
                    result:
                    ==========
                    \(result)
                    
                    
                    
                    """)
                self!.bSDK.clearTimingData()
                self!.bSDK.startMotionDetect()
                // #endif

                self!.chatbotService.sendMessage("Received " + message.text)
            }
            self!.replyToMessage = false
        })
        
        chatService.connect()
        chatbotService.connect()
    }
    
    func setup() {
        bSDK.registerKbdTarget(withID: tMessage, andName: "CREDIT_INPUT", andTargetType: NORMAL_TARGET)
        bSDK.addInformation("data from input view", withName: "message_data")
        bSDK.addInformation("payment", withName: "viewIdentifier")
        
        //TouchSDK
        bSDK.enableTouch(with: self);
        bSDK.startMotionDetect()
    }
}

extension ViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension ViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

extension ViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
}

// MARK: - MessageInputBarDelegate
extension ViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        chatService.sendMessage(tMessage.text!)
        replyToMessage = true
        print ("inputBar " + tMessage.text!)
        tMessage.text = nil
        tMessage.textColor = UIColor.black
        messageInputBar.sendButton.isEnabled = true
    }
}
