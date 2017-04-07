//
//  MemolistTableViewController.swift
//

import UIKit

class MemolistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myTableView: UITableView!
    var texts = AnyObject!([])
    var times = NSMutableArray(array : [])
    
    var _param:String = "segueOK"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        myTableView.allowsSelectionDuringEditing = true

        //NSUserDefaultsのロード
        let loadtext: AnyObject! = NSUserDefaults.standardUserDefaults().arrayForKey("fileNames");
        if(loadtext != nil){
            texts = loadtext
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK:Cellの総数を返す
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
 
    //
    // MARK:各行に表示するセルを返す
    //
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 現在日時の取得
        let now = NSDate()
        
        // フォーマットを取得しJPロケール
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        
        // セル番号でセルを取り出す
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        
        // セルに表示するテキストを設定する
        cell.textLabel?.text = texts[indexPath.row] as? String
        times.addObject(dateFormatter.stringFromDate(now))
        cell.detailTextLabel?.text = (times[indexPath.row] as! String)

        return cell
    }
    
    //
    // MARK:編集ボタン
    //
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // TableViewを編集可能にする
        myTableView.setEditing(editing, animated: true)
        
        if editing {
            //編集中
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCell:")
            self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        } else {
            //通常モード
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    
    //
    // MARK:削除許可
    //
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    
    //
    // MARK:各種ボタン押下時
    //
    func addCell(sender: AnyObject) {
        let alert = UIAlertController(title: "タイトルの入力", message: "タイトルを入力してください", preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Done", style: .Default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキスト
            let textField = alert.textFields![0]

            let mutablearray = self.texts.mutableCopy()
            self.texts = mutablearray
            mutablearray.addObject(textField.text!)

            //NSUserDefaultsに入力値を保存
            NSUserDefaults.standardUserDefaults().setObject(mutablearray, forKey:"fileNames")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // TableViewを再読み込み.
            self.myTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action:UIAlertAction!) -> Void in
        }
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //
    // MARK:Cellの挿入または削除
    //
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // 削除
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 指定されたセルのオブジェクトをmyItemsから削除する
            let mutablearray = self.texts.mutableCopy()
            self.texts = mutablearray
            mutablearray.removeObjectAtIndex(indexPath.row)
            
            //NSUserDefaultsに入力値を保存
            NSUserDefaults.standardUserDefaults().setObject(mutablearray, forKey:"fileNames")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // TableViewを再読み込み.
            myTableView.reloadData()
        }
    }
    
    //
    //MARK:Cellが選択された際に呼び出されるデリゲートメソッド.
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(texts[indexPath.row])")
        _param =  (texts[indexPath.row]) as! String
    }
    
    //
    //MARK:セグエにタイトル＝ファイル名を渡す
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segue") {
            // SecondViewControllerクラスをインスタンス化してsegue（画面遷移）で値を渡せるようにバンドルする
            let secondView : ViewController = segue.destinationViewController as! ViewController
            // secondView（バンドルされた変数）に受け取り用の変数を引数とし_paramを渡す（_paramには渡したい値）
            // この時SecondViewControllerにて受け取る同型の変数を用意しておかないとエラーになる
            secondView._second = _param
        }
    }
    
}