import Foundation
import RealmSwift
import NotificationCenter

class InfoHelper {

    let realm = try! Realm()
    
    //入力された項目(title)や通知の日付(datePicke.date)をRealmに保存する処理
    func save(title:String,date:Date) {
        //itemにToDoItem.Swiftで作ったRealmのデータモデルを読み込んで格納
            let item = ToDoItem()
            //データモデルのそれぞれの項目を格納
            item.title = title
            item.date = date
            //idは通知を管理するためのものなので、被らないように0~9999の数字を文字列型に変換して格納
            item.id = String(Int.random(in:0...99999))
            //Realmにデータセットを書き込む
            try! realm.write{
                realm.add(item)
            }
        //通知を設定するメソッドを読み込む
        setNotificationCenter(item: item)
    }
    
    //DatePickerで取得した日時をString(文字列型)に変換する処理
    func dateToString(date:Date) -> String {
        //itemListのrow番目の日付(date)を"月/日 時：分"の形で表示するためにフォーマット変換する
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    //通知を設定するメソッド
    func setNotificationCenter(item:ToDoItem) {
        //item.dateに保存された日付データから年、月、日、時、分を読み込む
        let targetDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: item.date)
        //上記で取得した日付を元にUNCalenderNotificaitonTriggerのインスタンスを作成
        let trigger = UNCalendarNotificationTrigger(dateMatching: targetDate, repeats: false)
        //UNMutableNotificationContentのインスタンスを作成
        let content = UNMutableNotificationContent()
        
        //通知の内容を設定
        //通知に表示されるタイトルを設定
        content.title = item.title
        //通知音を設定(.defaultでデフォルトの通知音)
        content.sound = .default
     
        //ここまでで設定したデータを元にUNNotificationRequestのインスタンスを作成
        let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
        //通知をNotificationCenterに追加する処理
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //Itemを削除するメソッド
    func deleteItem(item:ToDoItem,token:NotificationToken) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id])
        try! realm.write(withoutNotifying: [token]) {
            realm.delete(item)
        }
    }
}
