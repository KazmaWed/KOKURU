import UIKit
import Firebase

class SendViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションバータイトル
        navigationController?.navigationBar.topItem?.title = "KOKURU"
        
        //宛先テキストフィールド初期設定
        setIdTextField()
        //メッセージテキストビュー初期設定
        setMessageTextView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    //------------------------------IBアウトレットなど------------------------------
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    //Firestore
    var docRef: DocumentReference!
    
    //------------------------------メッセージテキストビュー------------------------------
    
    
    //初期設定
    func setIdTextField() {
        //デリゲート
        userIdTextField.delegate = self
    }
    
    //リターンキータップ時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //ファーストレスンダーがID -> Message
        closeKeyboard()
        return true
    }
    
    
    //------------------------------メッセージテキストビュー------------------------------
    
    
    //初期設定
    func setMessageTextView() {
        
        //
        activityIndicator.isHidden = true
        
        //デリゲート
        messageTextView.delegate = self
        
        //メッセージ枠線
        messageTextView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        //線の幅
        messageTextView.layer.borderWidth = 1.0
        //角丸にする
        messageTextView.layer.cornerRadius = 6.0
        messageTextView.layer.masksToBounds = true
        //
        let textInset:CGFloat = 6
        messageTextView.textContainerInset.left = textInset
        messageTextView.textContainerInset.right = textInset
        
    }
    
    //テキストが変更される度に呼び出し
    func textViewDidChange(_ textView: UITextView) {
        //テキスト入力でプレイスホルダー非表示
        placeHolderLabel.isHidden = messageTextView.text != ""
    }
    
    //テキストフィールド外タップでキーボード非表示
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
    
    
    //------------------------------送信ボタン------------------------------
    
    
    @IBAction func tapSendButton(_ sender: Any) {
        
        //宛先、本文が空白ガード
        guard let messageTo = userIdTextField.text, !messageTo.isEmpty else { return }
        guard let messageSending = messageTextView.text, !messageSending.isEmpty else { return }
        
        //クルクル表示
        startActivities()
        
        //保存用、日付(id)
        let date = Date()
        let dateInString = String(Int(date.timeIntervalSince1970))
        //本文
        let messageToSave:[String:Any] = ["body": messageSending, "read":false, "archived":false]
        
        //Firestoreに保存
        let documentPath:String = "users/" + messageTo + "/inbox/" + dateInString
        docRef = Firestore.firestore().document(documentPath)
        docRef.setData(messageToSave) { (error) in
            //エラーハンドリング
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Message Sent Correctly!")
            }
            
            //メッセージフィールド初期化
            self.messageTextView.text = ""
            self.placeHolderLabel.isHidden = false
            
            //クルクル非表示
            self.finishActivities()
        }
        
        closeKeyboard()
        
    }
    
    
    //------------------------------アクティビティインジケータ------------------------------
    
    
    //通信開始
    func startActivities() {
        objectsEnabled(false)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //通信完了
    func finishActivities() {
        objectsEnabled(true)
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    //------------------------------その他ファンクション------------------------------
    
    
    //ボタン・テキストフィールドの有効化・無効化
    func objectsEnabled(_ bool : Bool) {
        //
        userIdTextField.isEnabled = bool
        messageTextView.isEditable = bool
        sendButton.isEnabled = bool
    }
    
    //キーボード非表示
    func closeKeyboard() {
        if userIdTextField.isFirstResponder {
            userIdTextField.resignFirstResponder()
        } else if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
    
}
