import UIKit
import Firebase

class TabBarViewController: UITabBarController , UITabBarControllerDelegate {

    static var selectedTab:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザーデフォルト呼び出し
        loadUserDefaults()
        
        //未読メッセージ数バッジ
        InboxViewController().fetchMessages(completion: {() -> Void in
            if Statics.numOfNewMessages == 0 {
                self.tabBarEmbeded.items![1].badgeValue = nil
            } else {
                self.tabBarEmbeded.items![1].badgeColor = UIColor.systemBlue
                self.tabBarEmbeded.items![1].badgeValue = String(Statics.numOfNewMessages)
            }
        })
        
    }
    
    //タブバータップ時
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        TabBarViewController.selectedTab = item.tag
    }
    
    
    //------------------------------IBアウトレットなど------------------------------
    
    
    //タブバー
    @IBOutlet weak var tabBarEmbeded: UITabBar!
    
    //Firestore
    var collecRef: CollectionReference!
    
    
    //------------------------------その他メソッド------------------------------
    
    
    //ユーザーでフォルド読み出し
    func loadUserDefaults() {
        //既存のユーザーIDがあれば
        if let loadedUserId = UserDefaults.standard.string(forKey: "userId") {
            //読み出して
            Statics.userId = loadedUserId
            //コンソール
            print("----------userId loaded (\(Statics.userId))----------")
        }
    }

}
