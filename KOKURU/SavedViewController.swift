import UIKit
import RealmSwift

class SavedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        savedMessages = []
        
        let realm = try! Realm()
        let realmMessages = realm.objects(RealmMessage.self)
        
        for realmMessage in realmMessages {
            let message = Message(id: realmMessage.id!,
                                  body: realmMessage.body!,
                                  read: true, archived: true)
            savedMessages.append(message)
            print("\(message.dateFormat()) \(message.body)")
        }
        
        tableView.reloadData()
        
    }

    
    //------------------------------IBアウトレットなど------------------------------
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var savedMessages:[Message] = []
    var selectedCell:Int?
    
}


extension SavedViewController:  UITableViewDelegate, UITableViewDataSource {

    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMessages.count
    }

    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //メッセージ
        let message = savedMessages[indexPath.row]
        //セル
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)

        //表示テキスト
        let title = message.body
        let detail = message.dateFormat()

        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail

        return cell
    }

    //セルタップ時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedCell = indexPath.row
        //セルのハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)

        //画面遷移
        performSegue(withIdentifier: "showMessageDetail",sender: nil)

    }

    //遷移先にメッセージを渡す

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessageDetail" {
            let detailVC = segue.destination as! MessageViewController
            detailVC.message = savedMessages[selectedCell!]
        }
    }

}
