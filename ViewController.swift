import UIKit
import RealmSwift
import GoogleMobileAds


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, GADBannerViewDelegate {
    
    let realm = try! Realm()
    var itemList:Results<ToDoItem>!
    var token:NotificationToken!
    @IBOutlet weak var tableView: UITableView!
    
    // 広告ユニットID
    let AdMobID = "AdMobで取得した広告ID"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = true　//いらないかも
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //itemListにToDoItem.Swiftで作ったデータモデルを読み込み、日付(date)順に並べ替える
        itemList = realm.objects(ToDoItem.self).sorted(byKeyPath: "date")
        token = realm.observe{ notificaiton,realm in
            //realmのデータベースに変更があった場合、tableViewを更新する
            self.tableView.reloadData()
        }
        
        

    }
    //バナー広告表示用メソッド
    override func viewDidLayoutSubviews(){    // ★←この関数まるまる追記
            //  広告インスタンス作成
            var admobView = GADBannerView()
            admobView = GADBannerView(adSize:kGADAdSizeBanner)
            
            //  広告位置設定(iPhoneX対応)
            let safeArea = self.view.safeAreaInsets.bottom
            admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - safeArea - admobView.frame.height)
            admobView.frame.size = CGSize(width:self.view.frame.width, height:admobView.frame.height)
            
            //  広告ID設定
            admobView.adUnitID = TEST_ID　//シミュレーターの場合はTEST_ID、本番はAdMobIDを設定
            
            //  広告表示
            admobView.rootViewController = self
            admobView.load(GADRequest())
            self.view.addSubview(admobView)
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
        cell?.textLabel?.numberOfLines = 0
        //リストの右側(日時)に表示する文字列
        //InfoHelperから日付を文字列型に変換する処理を読み込む
        //let dateString = InfoHelper().dateToString(date: item.date)
        cell?.detailTextLabel?.text = InfoHelper().dateToString(date: item.date)
        return cell!
        }
    
    
    
    //tableViewをスワイプできるようにするメソッド
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //スワイプしたItemを削除するメソッド(InfoHelper.deleteItem)を読み込む
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            InfoHelper().deleteItem(item: itemList[indexPath.row], token: token)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}


