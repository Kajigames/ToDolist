import UIKit
import MessageUI

class MenuView: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //menuの初期位置を取得
        let menuPos = self.menuView.layer.position
        //初期位置を画面の外にするために、menuの幅の文だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        //表示時のアニメーション
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.menuView.layer.position.x = menuPos.x
        }, completion: { bool in})
        
        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

        }

    //menu以外をタップしたときにmenuを閉じる
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate (
                    withDuration: 0.2, delay: 0,options: .curveEaseIn,animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                    } , completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //"Privacy Policy"ボタンタップでサファリ起動→プラポリ表示
    @IBAction func onPrivacyPolicy(_ sender: Any) {
        let url = NSURL(string: "PrivacyPolicyサイトのURL")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    //"お問い合わせ"タップでActionsheetを出現、メールORサイトへの書き込みを選択させる
    @IBAction func onContactUs(_ sender: Any) {
        let url = NSURL(string: "お問い合わせ用サイトのURL")
        
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: "お問い合わせ", message: nil, preferredStyle: UIAlertController.Style.actionSheet)

             // 自分の選択肢を生成
        //action1つ目→サイトに飛ばす
        let action1 = UIAlertAction(title: "よくあるご質問", style: UIAlertAction.Style.default, handler: {
            action in if UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }
             })
        //action2つ目→メールを起動
        let action2 = UIAlertAction(title: "メールでお問い合わせ", style: UIAlertAction.Style.default, handler: {
                 action in
            self.sendMail()
             })
        //action3つ目→何もせず閉じる
        let action3 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
                 (action: UIAlertAction!) in
             })

        // アクションを追加.
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(action3)

        self.present(alertSheet, animated: true, completion: nil)
    }
    
    //メールアプリを起動して宛先、件名等を指定するメソッド
    func sendMail() {
            //メールを送信できるかチェック
            if MFMailComposeViewController.canSendMail() == false {
                print("Email Send Failed")
                return
            }

            let mailViewController = MFMailComposeViewController()
            let toRecipients = ["宛先にしたいメールアドレス"]
            let NoInt = Int.random(in: 0001...9999)　//件名にランダムな数字を当てるための変数

            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("【お問い合わせ】No.\(NoInt)")
            mailViewController.setToRecipients(toRecipients) //Toアドレスの表示
            mailViewController.setMessageBody("お問い合わせ内容：", isHTML: false)

        self.present(mailViewController, animated: true, completion: nil)
        }
    
    //メールを閉じる処理(SendやCanceledで処理したあとに画面を閉じてアプリに戻るメソッド)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .cancelled:
                print("Email Send Cancelled")
                break
            case .saved:
                print("Email Saved as a Draft")
                break
            case .sent:
                print("Email Sent Successfully")
                break
            case .failed:
                print("Email Send Failed")
                break
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
        }

    }
