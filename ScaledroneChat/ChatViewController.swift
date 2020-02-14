import UIKit
import MessageKit
import InputBarAccessoryView

/// A base class for the example controllers
class ChatViewController: MessagesViewController {
    private var bSDK: BehavioSecIOSSDK = BehavioSecIOSSDK.shared()
    lazy var tMessage: UITextField = {
        let textField = UITextField()
        return textField
    } ()
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
        
        //configureMessageCollectionView()
        configureMessageInputBar()
        
        title = "BehavioSec "
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 4
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        messageInputBar.separatorLine.isHidden = true
        tMessage.textColor = UIColor.blue

 //       messageInputBar.setMiddleContentView(tMessage, animated: false)
        
        //messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        //let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), .flexibleSpace]
        //messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        messageInputBar.sendButton.activityViewColor = .white
        //messageInputBar.sendButton.backgroundColor = .primaryColor
        messageInputBar.sendButton.layer.cornerRadius = 10
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
        messageInputBar.sendButton.addTarget(self, action: #selector(printChat), for: .touchUpInside)
        tMessage.text = nil
        tMessage.textColor = UIColor.black
        messageInputBar.sendButton.isEnabled = true
        
        bSDK.registerKbdTarget(withID: tMessage, andName: "CREDIT_INPUT", andTargetType: NORMAL_TARGET)
        bSDK.addInformation("data from input view", withName: "message_data")
        bSDK.addInformation("message1", withName: "viewIdentifier")
        
        //TouchSDK
        bSDK.enableTouch(with: self);
        bSDK.startMotionDetect()

    }
}
// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()

        // Send button activity animation
        inputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
 //               self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

}
