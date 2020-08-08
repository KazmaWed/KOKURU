import Foundation
import Firebase
import RealmSwift

class Statics: NSObject {
    
    static var userId:String = ""
    static var messages:[Message] = []
    static var numOfNewMessages:Int = 0
    
}

class Message {
    
    var id:String
    var body:String
    var read:Bool
    var archived:Bool
    
    init(id:String, body:String, read:Bool, archived:Bool) {
        self.id = id; self.body = body; self.read = read; self.archived = archived
    }
    
    //idをDateに変換
    func date() -> Date {
        let dateInString = id
        let tymeInterval = Double(dateInString)!
        return Date(timeIntervalSince1970: tymeInterval)
    }
    
    //日付ラベル用string出力
    func dateFormat() -> String {
        //書式設定
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        //日時取得
        let date = self.date()
        
        //String出力
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}

class RealmMessage: Object {
    @objc dynamic var id:String?
    @objc dynamic var body:String?
}
