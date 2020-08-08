import UIKit
import Firebase

class InboxViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //選択されたタブ取得
        tabTag = TabBarViewController.selectedTab
        //タイトル
        if tabTag == 1 { title = "Inbox" } else {  title = "Arichive" }
        
        //ID変更時など、メッセージ一時リセット
        if Statics.messages.count == 0 { filtered = []; tableView.reloadData() }
        
        //メッセージ更新
        fetchMessages()
        
    }
    
    
    //------------------------------IBアウトレットなど------------------------------
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func fetchButton(_ sender: Any) { fetchMessages() }
    
    //Firestoreリファレンス
    var collecRef: CollectionReference!
    var docRef: DocumentReference!
    
    //
    
    //タブアイテムタグ
    var tabTag:Int?
    //選択されたセル番号
    var selectedCell:Int?
    
    //------------------------------メッセージ受信------------------------------
    

    //メッセージ配列
    var filtered:[Message] = []
    
    //メッセージ受信
    func fetchMessages(completion: @escaping () -> Void) {
        
        //ID未設定ガード
        guard Statics.userId != "" else { return }
        
        //コレクションパス
        let collectionPath:String = "users/" + Statics.userId + "/inbox"
        //コレションリファレンス
        collecRef = Firestore.firestore().collection(collectionPath)
        
        
        //ゲットコレクション
        collecRef.addSnapshotListener { (querySnapshot, err) in
            
            if let err = err { print("Error:\(err)") } else {
                //初期化
                Statics.messages = []
                Statics.numOfNewMessages = 0
                
                //ドキュメント１件ずつ格納
                for document in querySnapshot!.documents {
                    //メッセージの要素
                    let id:String = document.documentID //日付
                    let body:String = document.data()["body"]! as! String //ボディ
                    let read:Bool = document.data()["read"]! as! Bool
                    let archived:Bool = document.data()["archived"]! as! Bool
                    
                    //未読メッセージ数
                    if !read && !archived  { Statics.numOfNewMessages += 1 }
                    
                    //格納
                    let message = Message(id:id, body:body, read:read, archived:archived)
                    Statics.messages.append(message)
                }
                
                //コンプレッション
                completion()
            }
            
        }
    }
    
    //メッセージ受信completionのデフォルト設定
    func fetchMessages() {
        fetchMessages(completion: { () -> Void in
            self.filterMessages()
        })
    }
    
    //メッセージ受信+completionのデフォルト設定
    func filterMessages() {
        
        //初期化
        self.filtered = []
        //フィルター設定
        let ifShowArchived = self.tabTag == 2
        
        //メッセージ0件ガード
        guard Statics.messages.count != 0 else { self.tableView.reloadData(); return }
        
        //未アーカイブメッセージ抽出
        for message in Statics.messages {
            if message.archived == ifShowArchived { self.filtered.append(message) }
        }
        
        //テーブルビュー更新
        self.tableView.reloadData()
        
    }
    
    //------------------------------その他ファンクション------------------------------
    
    
}

extension InboxViewController:  UITableViewDelegate, UITableViewDataSource {
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //メッセージ
        let message = filtered[indexPath.row]
        //セル
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
     
        //表示テキスト
        let title = message.body
        let detail = message.dateFormat()
        let read = message.read
        let archived = message.archived
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail
        
        //未読は青太字
        if read || archived {
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        } else {
            cell.textLabel?.textColor = UIColor.systemBlue
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        }
        
        return cell
    }
    
    //セルタップ時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セル番号
        selectedCell = indexPath.row
        //セルのハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Firestoreに保存
        let message = filtered[selectedCell!]
        let messageToSave:[String:Any] = ["body": message.body, "read":true, "archived":message.archived]
        
        let documentPath:String = "users/" + Statics.userId + "/inbox/" + message.id
        docRef = Firestore.firestore().document(documentPath)
        docRef.setData(messageToSave) { (error) in
            //エラーハンドリング
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Message Marked as Read")
            }
        }
        
        //画面遷移
        performSegue(withIdentifier: "showMessageDetail",sender: nil)
        
    }
    
    //遷移先にメッセージを渡す
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessageDetail" {
            let detailVC = segue.destination as! MessageViewController
            detailVC.message = filtered[selectedCell!]
        }
    }
    
}
