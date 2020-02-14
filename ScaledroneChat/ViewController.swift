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
    
        var chatService: ChatService!
        var chatbotService: ChatbotService!
        var messages: [Message] = []
        var member: Member!
        var chatbotMember: Member!
        var lastMessageText: String = ""
        var replyToMessage = false
    

        let behavioSession: BehavioSession = BehavioSession(user: "marcofanti2@behaviosec.com")

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
            member = Member(name: .randomName, color: .random)
            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messagesLayoutDelegate = self
            
     //       self.inputView = inputBar
            tMessage.textColor = UIColor.blue
            
            
    //        self.inputView.inputBar
            tMessage.text = nil
            tMessage.textColor = UIColor.black


            messagesCollectionView.messagesDisplayDelegate = self
            
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
                    self!.chatbotService.sendMessage("Received " + message.text)
                }
                self!.replyToMessage = false
            })
            
            chatService.connect()
            chatbotService.connect()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            /*
            MockSocket.shared.connect(with: [SampleData.shared.marco])
                .onNewMessage { [weak self] message in
                    self?.insertMessage(message)
            } */
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            /*
            MockSocket.shared.disconnect()
            audioController.stopAnyOngoingPlaying()
     */
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(false)
            behavioSession.finalize()
            bSDK.clearRegistrations()
        }

   
    func setup()
    {
        bSDK.registerKbdTarget(withID: tMessage, andName: "FIELD_USER", andTargetType: NORMAL_TARGET)
        tMessage.text = ""
        bSDK.addInformation("data from login view", withName: "login_data")
        bSDK.addInformation("MinimalTextFieldExample/Login", withName: "viewIdentifier")
        
        //TouchSDK
        bSDK.enableTouch(with: self);
        
        bSDK.startMotionDetect()
    }
    
     /*
         
        @objc
        func printChat() {
      //       callNetwork()
            print("send4 " + (tMessage.text ?? " No text"))
            let messageText = tMessage.text
            DispatchQueue.global(qos: .default).async {
                // fake send request task
                sleep(1)
                let user = SampleData.shared.currentSender
                let message = MockMessage(text: messageText ?? "", user: user, messageId: UUID().uuidString, date: Date())
               // insertMessage(message)
                
                
                DispatchQueue.main.async { [weak self] in
                    self?.messageInputBar.sendButton.stopAnimating()
                    self?.messageInputBar.inputTextView.placeholder = "Aa"
                    self?.insertMessage(message)
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.add3(initial: "Another Message")
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            }

            tMessage.text = nil
            messageInputBar.sendButton.isEnabled = true
            //configureMessageInputBarForChat()

            let timingData: String? = bSDK.getSummary()
            //        #if DEBUG
            //DEBUGGING-INFORMATION
            print("""
                
                
                
                timing:
                ==========
                \(timingData)
                
                
                
                """)
            //        #endif
            
            let result = behavioSession.getScoreForTimings(timingData, andNotes: "Login Request", andReportFlag: "0", andOperatorFlag: "512")
            //#if DEBUG
            //DEBUGGING-INFORMATION
            print("""
                
                
                
                result:
                ==========
                \(result)
                
                
                
                """)
            bSDK.clearTimingData()
            bSDK.startMotionDetect()
            // #endif
        }
        
        func configureMessageCollectionView() {
            
            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messageCellDelegate = self
            
            scrollsToBottomOnKeyboardBeginsEditing = true // default false
            maintainPositionOnKeyboardFrameChanged = true // default false
            
            messagesCollectionView.addSubview(refreshControl)
            refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        }
        */
        @objc
         func printChat() {
        //       callNetwork()
              print("printChat  " + (tMessage.text ?? " No text"))
        }
        
        func configureMessageInputBar() {
            print("configureMessageInputBar" )
            messageInputBar.delegate = self
            //messageInputBar.inputTextView.tintColor = .primaryColor
            
            tMessage.textColor = UIColor.blue
            
            messageInputBar.setMiddleContentView(tMessage, animated: false)
    /*
            messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
            messageInputBar.sendButton.setTitleColor(
                UIColor.primaryColor.withAlphaComponent(0.3),
                for: .highlighted
            )
            
            
            messageInputBar.layer.shadowColor = UIColor.black.cgColor
            messageInputBar.layer.shadowRadius = 4
            messageInputBar.layer.shadowOpacity = 0.3
            messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
            messageInputBar.separatorLine.isHidden = true */
            tMessage.textColor = UIColor.blue

     //       messageInputBar.setMiddleContentView(tMessage, animated: false)
            
            //messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
            //let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), .flexibleSpace]
            //messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
            
            messageInputBar.sendButton.activityViewColor = .white
            messageInputBar.sendButton.backgroundColor = .blue
            messageInputBar.sendButton.layer.cornerRadius = 10
            messageInputBar.sendButton.setTitleColor(.white, for: .normal)
            messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
            messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
            messageInputBar.sendButton.addTarget(self, action: #selector(printChat), for: .touchUpInside)
            tMessage.text = nil
            tMessage.textColor = UIColor.red
            messageInputBar.sendButton.isEnabled = true
            
            
            //bSDK.registerKbdTarget(withID: tMessage, andName: "CREDIT_INPUT", andTargetType: NORMAL_TARGET)
           // bSDK.addInformation("data from input view", withName: "message_data")
            //bSDK.addInformation("message1", withName: "viewIdentifier")
            
            //TouchSDK
            //bSDK.enableTouch(with: self);
            //bSDK.startMotionDetect()

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
        print("****************** inputBar " + text)
        // Here we can parse for which substrings were autocompleted
        messageInputBar.sendButton.isEnabled = false
        messageInputBar.inputTextView.text = String()
        //inputBar.invalidatePlugins()

        // Send button activity animation
        inputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        chatService.sendMessage(text)
        inputBar.inputTextView.text = ""
        inputBar.sendButton.stopAnimating()
        messageInputBar.sendButton.isEnabled = true
    }
}
