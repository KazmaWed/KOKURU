import UIKit
import Firebase

class SettingViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //ナビバータイトル
        title = "Setting"
        
        //デリゲート
        userIdTextField.delegate = self
        userIdTextField.text = Statics.userId
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    
    //------------------------------IBアウトレットなど------------------------------
    
    
    //IBアウトレット
    @IBOutlet weak var userIdTextField: UITextField!
    
    
    //------------------------------テキストフィールド------------------------------
    
    
    //キーボードリターンキータップ
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        //userId変更時
        if Statics.userId != userIdTextField.text! {
            //userId更新
            Statics.userId = userIdTextField.text!
            //ログ表示
            if Statics.userId != "" {
                print("New UserId (" + Statics.userId + ") saved")
            } else {
                print("UserId Deleted")
            }
            
            //ユーザーズデフォルト保存
            UserDefaults.standard.set(Statics.userId, forKey:"userId")
            //メッセージリセット
            Statics.messages = []
        }
        
        return true
    }
    
    
    //------------------------------ユーザーデフォルト読み出し------------------------------
    
}
