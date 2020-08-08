import UIKit
import Firebase
import RealmSwift

class MessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //選択されたタブ取得
        tabTag = TabBarViewController.selectedTab
        
        //日付タイトル
        title = message?.dateFormat()
        
        //メッセージ本文ラベル
        messageBodyLabel.text = message?.body
        messageBodyLabel.sizeToFit()
        
        //オフラインセーブボタン
        if realmMessageAlreadyExsist(id: message!.id) {
            saveOfflineButton.setTitle("Remove Offline", for: .normal)
            saveOfflineButton.setTitleColor(UIColor.systemPink, for: .normal)
        }
        
        //Savedタブの時は削除・アーカイブボタン非表示
        guard  tabTag != 3 else {
            archiveButton.isHidden = true
            deleteButton.isHidden = true
            return
        }
        
        //アーカイブボタン
        if message!.archived {
            archiveButton.setTitle("Unarchive", for: .normal)
        }
    }
    
    
    //------------------------------IBアウトレットなど------------------------------
    
    
    @IBOutlet weak var messageBodyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deleteButtonAction(_ sender: Any) { deleteButtonPushed() }
    @IBOutlet weak var archiveButton: UIButton!
    @IBAction func archiveButtonAction(_ sender: Any) { archiveButtonPushed() }
    @IBOutlet weak var saveOfflineButton: UIButton!
    @IBAction func saveOfflineButtonAction(_ sender: Any) { saveOfflinePushed() }
    
    
    
    //Firestoreリファレンス
    var collecRef: CollectionReference!
    var docRef: DocumentReference!
    
    //親から受け取るメッセージ
    var message:Message?
    
    //選択されているタブ
    var tabTag:Int?
    
    //------------------------------ボタンアクション------------------------------
    
    
    //削除ボタン
    func deleteButtonPushed() {
        let documentPath:String = "users/" + Statics.userId + "/inbox/" + message!.id
        docRef = Firestore.firestore().document(documentPath)
        docRef.delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //アーカイブボタン
    func archiveButtonPushed() {
        //Firestoreに保存
        let messageToSave:[String:Any] = ["body": message!.body, "read": message!.read,
                                          "archived": !message!.archived]
        
        let documentPath:String = "users/" + Statics.userId + "/inbox/" + message!.id
        docRef = Firestore.firestore().document(documentPath)
        docRef.setData(messageToSave) { (error) in
            //エラーハンドリング
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Message Marked as Read")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //セーブボタン
    func saveOfflinePushed() {
        
        let realm = try! Realm()
        let id = String(message!.id)
        let body = String(message!.body)
        
        if !realmMessageAlreadyExsist(id: id) {
            
            //Realm保存
            let realmMessage = RealmMessage()
            realmMessage.id = id
            realmMessage.body = body
            try! realm.write { realm.add(realmMessage) }
            //ボタン色変更
            saveOfflineButton.setTitle("Remove Offline", for: .normal)
            saveOfflineButton.setTitleColor(UIColor.systemPink, for: .normal)
            
        } else {
            
            //削除
            let results = realm.objects(RealmMessage.self).filter("id = '\(id)'")
            try! realm.write { realm.delete(results) }
            //ボタン色変更
            saveOfflineButton.setTitle("Save Offline", for: .normal)
            saveOfflineButton.setTitleColor(UIColor.systemBlue, for: .normal)
            
        }
        
    }
    
    //Realmメッセージ既存チェック
    func realmMessageAlreadyExsist(id:String) -> Bool {
        let realm = try! Realm()
        let ifExsist = realm.objects(RealmMessage.self).filter("id = '\(id)'").count != 0
        return ifExsist
    }
    
}
