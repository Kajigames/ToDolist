import UIKit
import RealmSwift
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, GADBannerViewDelegate {
    
    let realm = try! Realm()
    var itemList:Results<ToDoItem>!
    var token:NotificationToken!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var GADBannerView: GADBannerView!
    
    //行番号を取得するための配列を定義
    var rowListArray = [Int]()
    
    //アイコンのバッジ操作用
    let application = UIApplication.shared

    // 広告ユニットID
    let AdMobID = "AdMobで取得したID"
    
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true
    
    //ViewControllerがインスタンス化された時(最初似表示された時)呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //itemListにToDoItem.Swiftで作ったデータモデルを読み込み、入力された順に表示
        itemList = realm.objects(ToDoItem.self)
        
        token = realm.observe{ [self] notificaiton,realm in
            //realmのデータベースに変更があった場合、tableViewを更新する
            tableView.reloadData()
            
        }
        
        //rowListArray重複削除
        let newListArray = Array(Set(rowListArray))
        //セルの選択を有効にする(true = 複数選択可)
        self.tableView.allowsMultipleSelection = true
        //AdMob広告読み込み

        GADBannerView.adUnitID = AdMobID//テストの際はTEST_IDに変更
        GADBannerView.rootViewController = self
        GADBannerView.load(GADRequest())
        
        //項目が入っていない部分の区切り線を消す
        self.tableView.tableFooterView = UIView()
        
        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
      
    }
    
    //viewControllerが表示された時に呼ばれるメソッド(毎回)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        
        //rowListArray重複削除
        let newListArray = Array(Set(rowListArray))
        
        
        
        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
        
        //iOS14以降ならトラッキング許可のアラートを表示するメソッドを呼び出す(iPhoneの設定に応じてバターンを用意)
        if #available(iOS 14, *) {
                    switch ATTrackingManager.trackingAuthorizationStatus {
                    //iPhoneで全てのトラッキングが許可されている場合
                    case .authorized:
                        print("Allow Tracking")
                        print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    //iPhoneで全てのトラッキングが拒否されている場合(アラートも表示されない)
                    case .denied:
                        print("拒否")
                    case .restricted:
                        print("制限")
                    //iPhoneでトラッキングに関する設定がされていない場合(アラートを表示して許可を求める)
                    case .notDetermined:
                        showRequestTrackingAuthorizationAlert()
                    @unknown default:
                        fatalError()
                    }
                } else {// iOS14未満
                    if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                        print("Allow Tracking")
                        print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    } else {
                        print("制限")
                    }
                }
        
    }
    ///Alert表示
        private func showRequestTrackingAuthorizationAlert() {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    switch status {
                    case .authorized:
                        print("許可されました")
                        //IDFA取得
                        print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    case .denied, .restricted, .notDetermined:
                        print("拒否されました")
                    @unknown default:
                        fatalError()
                    }
                })
            }
        }
    //TableViewを使うための2つのメソッド
    //①リストの行数を決めるメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    //②リストに表示する文字列を決めるメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        //セルのIDを指定
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        //itemListに格納されているデータセットのrow番目のデータをitemに格納
        let item = itemList[indexPath.row]
        //リストの左側(項目)に表示する文字列(itemListのrow番目のタイトル)
        cell?.textLabel?.text = item.title
        //numberOfLines = 0で改行をいくらでもできるようにする
        cell?.textLabel?.numberOfLines = 0
        
        cell?.detailTextLabel?.text = InfoHelper().dateToString(date: item.date)

        return cell!

        }

    //セルがタップされた直後に読み込まれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //indexPathからどのセルがタップされたか判定する
        let cell = tableView.cellForRow(at: indexPath)
        //取り消し線を追加するの文字列を定義
        let atr = NSMutableAttributedString(string: (cell?.textLabel?.text)!)

        //rowListArrayに行番号を追加
        self.rowListArray.append(indexPath.row)
        //rowListArrayが重複していたら同じ値を削除
        let newListArray = Array(Set(rowListArray))

       
        //タップされたセルにチェックボックスを加える
        cell?.accessoryType = .checkmark
        //文字色をグレーにする
        cell?.textLabel?.textColor = .gray
        //文字に取り消し線を追加する(.strikethroughStyle)、valueで線の太さ、NSMakeRange(0, atr.length)でテキスト全体を指定
        atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, atr.length))
        //取り消し線を反映
        cell?.textLabel?.attributedText = atr

        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
 
      }
    
    //もう一度セルをタップした直後(セルの選択解除直後)に読み込まれるメソッド
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //indexPathからどのセルがタップされたか判定する
        let cell = tableView.cellForRow(at: indexPath)
        //取り消し線操作用
        let atr = NSMutableAttributedString(string: (cell?.textLabel?.text)!)
        
        
        //タップされたセルにチェックボックスを消す
        cell?.accessoryType = .none
        //文字色をデフォルトに戻す
        cell?.textLabel?.textColor = .label
        //取り消し線を戻す(value:0)
        atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, atr.length))
        //ラベルに反映
        cell?.textLabel?.attributedText = atr
        
        //rowListArrayに入っている行番号を削除
        rowListArray.removeAll(where: {$0 == indexPath.row})

        //rowListArrayが重複していたら同じ値を削除
        let newListArray = Array(Set(rowListArray))
        
        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
 
    }
    
    
    //tableViewをスワイプできるようにするメソッド
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //スワイプしたItemを削除するメソッド(InfoHelper.deleteItem)を読み込む
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //indexPathからどのセルがタップされたか判定する
        let cell = tableView.cellForRow(at: indexPath)
        //取り消し線操作用
        let atr = NSMutableAttributedString(string: (cell?.textLabel?.text)!)
     
        //タップされたセルにチェックボックスを消す
        cell?.accessoryType = .none
        //文字色をデフォルトに戻す
        cell?.textLabel?.textColor = .label
        //取り消し線を戻す(value:0)
        atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, atr.length))
        //ラベルに反映
        cell?.textLabel?.attributedText = atr

        //rowListArrayに入っている行番号を削除
        rowListArray.removeAll(where: {$0 == indexPath.row})
        for i in 0..<rowListArray.count {
            if rowListArray[i] > indexPath.row {
            rowListArray[i] = rowListArray[i] - 1
            }
        }
        
        print("インデックス\(rowListArray)")
        
        if editingStyle == .delete {
            InfoHelper().deleteItem(item: itemList[indexPath.row], token: token)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        //rowListArrayが重複していたら同じ値を削除
        let newListArray = Array(Set(rowListArray))
        
        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
        
    }
    

    
    //ゴミ箱ボタンが押されたときの処理
    @IBAction func deleteButton(_ sender: Any) {
        
        //チェックマークが入っているセルがあるか判定
        if rowListArray.isEmpty == true {
            print("Enpty")
        } else {
            //rowArrayの値を降順に並べ替え
            rowListArray.sort(by: > )
            //チェックマークがついたセルを削除
            for value in rowListArray {
                //タップされたセルにチェックボックスを消す
                let cell = tableView.cellForRow(at: [0,value])
                //取り消し線操作用
                let atr = NSMutableAttributedString(string: (cell?.textLabel?.text)!)
                cell?.accessoryType = .none
                //文字色をデフォルトに戻す
                cell?.textLabel?.textColor = .label
                //取り消し線を戻す(value:0)
                atr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, atr.length))
                //ラベルに反映
                cell?.textLabel?.attributedText = atr
                InfoHelper().deleteItem(item: itemList[value], token: token)
            }
            rowListArray.removeAll()
        }
        
        //rowListArrayが重複していたら同じ値を削除
        let newListArray = Array(Set(rowListArray))
        
        //バッジを表示
        if itemList.count == 0 || itemList.count == newListArray.count {
            application.applicationIconBadgeNumber = 0
        } else {
                application.applicationIconBadgeNumber = itemList.count - newListArray.count
        }
        
        //tableViewを更新する
        tableView.reloadData()
    }
    
}


