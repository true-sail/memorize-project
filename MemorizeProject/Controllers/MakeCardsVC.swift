//
//  MakeCardsVC.swift
//  MemorizeProject
//
//  Created by 家田真帆 on 2019/12/10.
//  Copyright © 2019 家田真帆. All rights reserved.
//

import UIKit
// 読み込み
import RealmSwift
import Firebase

class MakeCardsVC: UIViewController {
    
    // 編集する時に飛んでくる値を受け取る
    var editCard: Card? = nil
    
    // alertに表示するmessage
    var message = ""
 
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var textViewQ: UITextView!
    
    @IBOutlet weak var textViewA: UITextView!
   
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // navbarの色設定
        navigationController?.navigationBar.barTintColor = UIColor(red: 109/255, green: 185/255, blue: 208/255, alpha: 100)
        
        // おまじない
        textViewQ.delegate = self
        textViewA.delegate = self
    
        // textViewQの枠線
        textViewQ.layer.borderWidth = 1
        textViewQ.layer.borderColor = UIColor.lightGray.cgColor
        
        // textViewAの枠線
        textViewA.layer.borderWidth = 1
        textViewA.layer.borderColor = UIColor.lightGray.cgColor
        
        // 変数editCardがnilでなければ、textViewQ, textViewA, textFieldに文字を表示
        if let e = editCard {
            // nilでない場合（編集の場合）
            
            // labelに「編集」と表示
            label.text = "編集"
            
            // 編集内容を表示
            textViewQ.text = e.Q
            textViewA.text = e.A
            textField.text = e.category
            button.setTitle("変更", for: .normal)
            
        } else {
            // nilの場合（作成の場合）
            
            // labelに「今日学んだこと」と表示
            label.text = "今日学んだこと"
            
            // textViewQ,textViewAにplaceholderを表示
            textViewQ.text = "問題"
            textViewQ.textColor = UIColor.lightGray
            textViewA.text = "解答"
            textViewA.textColor = UIColor.lightGray
            
            // buttonの文字を「作成」にする
            button.setTitle("作成", for: .normal)
        }
        
    }
    
    // カードを編集するためのメソッド
    fileprivate func updateCard(newQ: String, newA: String, newCategory: String, createdCard: Card) {
        let realm = try! Realm()
        try! realm.write {
            createdCard.Q = newQ
            createdCard.A = newA
            createdCard.category = newCategory
        }
    }

    // 作成ボタンを押した時にカードをRealmに追加するメソッド
    fileprivate func makeNewCards(_ inputQ: String, _ inputA: String, _ inputCategory: String) {
        
        // Realmに接続
        let realm = try! Realm()
        
        // Realmデータベースファイルまでのパスを表示
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        print("-------------------------------------------------")
        
        // QとAをRealmに登録
        let createdCard = Card()
        
        // インスタンス化(Cardクラスをもとに作成)
        createdCard.Q = inputQ
        createdCard.A = inputA
        createdCard.category = inputCategory
        createdCard.date = Date() // Date() : 現在の日付を入れる
        
        // 現在あるidの最大値+1の値を取得(AutoIncrement)
        let id = (realm.objects(Card.self).max(ofProperty: "id") as Int? ?? 0) + 1
        createdCard.id = id
        
        //Realmに新規カードを書き込む(追加)
        try! realm.write {
            realm.add(createdCard)
        }
    }
    
    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        // textViewQがnilの場合
        guard let inputQ = textViewQ.text else {
            // return:このメソッド(didClickButton)を中断する
            return
        }
        
        // textViewQが空の場合
        if inputQ.isEmpty {
            return
        }
        
        // textViewAがnilの場合
        guard let inputA = textViewA.text else {
            return
        }
        
        // textViewAが空の場合
        if inputA.isEmpty {
            return
        }
        
        // textFieldがnilの場合
        guard let inputCategory = textField.text else {
            return
        }
        
        // inputCategoryが空の場合
        if inputCategory.isEmpty {
            return
        }
        
        if let c = editCard {
            // 変数editCardがnilでない場合
            // 更新する場合
            updateCard(newQ: inputQ, newA: inputA, newCategory: inputCategory, createdCard: c)
            
            let selectedCategory = editCard?.category
            
            // CardVCに戻る
            performSegue(withIdentifier: "backToCard", sender: selectedCategory)
            
        } else {
            // 変数cardがnilの場合
            // 新規作成の場合
            makeNewCards(inputQ, inputA, inputCategory)
        }
        
        // スイッチがオンの状態の時、databaseに接続
        if didCheckSwitch == true {
            
            // firebaseに接続
            let db = Firestore.firestore()
                 print("on")
            
            db.collection("cards").addDocument(data: ["Q": textViewQ.text!, "A": textViewA.text!, "category": textField.text!, "createdAt": FieldValue.serverTimestamp()
            ]) { error in
                if let err = error {
                    // エラーが発生した場合、エラー情報を表示
                    print(err.localizedDescription)
                } else {
                    // エラーがない場合
                    print("カードをシェアしました")
                    self.message = "カードをシェアしました"
                    print(self.message)
                }
            }
        }
        
        // アラートの画面作成
        let alert = UIAlertController(title: "カード作成完了!", message: "\(message)", preferredStyle: .alert)
        print(message)
        
        // アラートを表示
        present(alert, animated: true, completion: nil)
        
        
        // textViewを最初の状態に戻す
        textViewQ.text = "問題"
        textViewQ.textColor = UIColor.lightGray
        textViewA.text = "解答"
        textViewA.textColor = UIColor.lightGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backToCard" {
            
            let CardVC = segue.destination as! CardVC
            
            CardVC.selectedCategory = sender as! String
        }
    }
    
    
    // スイッチを押した時
    @IBAction func didSwitchButton(_ sender: UISwitch) {
    
        if sender.isOn {
        // オンの場合
            didCheckSwitch = true
            print("オンです")
        } else {
        // オフの場合
            didCheckSwitch = false
            print("オフです")
        }
        
     
    }
    
  
    
}

// placeholderを使えるように拡張
extension MakeCardsVC: UITextViewDelegate {
    
    // textViewを編集し始めた時のメソッド
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == textViewQ {
            // textViewの文字がlightGrayの時
             if textViewQ.textColor == UIColor.lightGray {
                // textViewの文字をnilにする
                 textViewQ.text = nil
                // 文字を黒にする
                 textViewQ.textColor = UIColor.black
             }
        }
        
        if textView == textViewA {
            // textViewAの文字がlightGrayの時
            if textViewA.textColor == UIColor.lightGray {
                // textViewの文字をnilにする
                textViewA.text = nil
                // 文字を黒にする
                textViewA.textColor = UIColor.black
            }
        }
     }
    
    // textViewを編集し終えた時のメソッド
     func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == textViewQ {
            // textViewQの文字が空の場合
            if textViewQ.text.isEmpty {
            // textViewの文字を設定
             textViewQ.text = "問題"
            // 文字をlightGrayに変更
             textViewQ.textColor = UIColor.lightGray
            }
        }
        
        if textView == textViewA {
            // textViewAの文字が空の場合
            if textViewA.text.isEmpty {
            // textViewの文字を設定
            textViewA.text = "解答"
            // 文字をlightGrayに変更
            textViewA.textColor = UIColor.lightGray
            }
        }
    }
    

    
}
