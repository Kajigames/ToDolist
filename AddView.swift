import UIKit
import RealmSwift

class AddView: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //アプリの使用者がいる地域のタイムゾーンを取得する
        datePicker.timeZone = TimeZone.current
        datePicker.locale = Locale.current
        
        //画面の余白をタップしたときにキーボードを非表示にするメソッドを呼び出す
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func onAddButton(_ sender: Any) {
        
        //項目欄のテキストを格納する変数
        let koumoku = textField.text!
        
        if koumoku.count == 0 {
            //エラーメッセージを表示するメソッドを呼び出し
            showError(message: "項目を入力してください")
        } else {
            
        //InfoHelperからデータセットをRealmに保存する処理を読み込む
        InfoHelper().save(title:textField.text! ,date:datePicker.date)
        //画面を閉じる処理。animated:trueでアニメーションをつける
        //completion:nilで閉じる時に何も処理を行わない
        dismiss(animated: true, completion: nil)
    }
    }
    
    //エラーメッセージを表示するメソッド
    func showError(message:String){
        //エラーメッセージの内容を定義
        let dialog = UIAlertController(title: "エラー", message:message,preferredStyle: .alert)
        //アラートの下にOKボタンを表示
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //アラートを表示
        present(dialog,animated: true,completion: nil)
    }
 
}
