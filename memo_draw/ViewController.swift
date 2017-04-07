//
//  ViewController.swift
//  memo_draw
//
//  Created by Tomoko Takagi on 2015/11/11.
//  Copyright (c) 2015年 Tomoko Takagi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate {
    
    /*
    --------------------------------------------
    // MARK: - 変数宣言
    --------------------------------------------
    */

    @IBOutlet weak var canvas: UIImageView!
    @IBOutlet weak var saveImageView: UIImageView!
    
    /// 遷移時の受け取り用の変数
    var _second:String = ""
    
    var data:NSData!
    
    //ペン種関連
    var pen_flg  = 0
    var penColor = UIColor.blackColor()

    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

    override func viewDidLoad() {
        canvas.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        saveImageView.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)

        let fileName = _second+".png"
        print(_second)
        let filePath = self.documentsPath.stringByAppendingPathComponent(fileName)
        //FIXME:描画画面→テーブルビュー→描画画面の遷移で再編集を可能にする
        //※現在は一回アプリを落とさないと最新の保存が反映されない
        saveImageView.image = UIImage(named: filePath)
    }


    /*
    --------------------------------------------
    // MARK: - StoryBoadとの紐付け
    --------------------------------------------
    */
    
    //
    // MARK:描画モードの切り替え
    //
    @IBAction func pensel(sender: AnyObject) {
            switch sender.selectedSegmentIndex{
            case 0:
                pen_flg = 0
            case 1:
                pen_flg = 1
            default:
                pen_flg = 0
        }
    }

    //
    // MARK:写真ボタン
    //
    @IBAction func photo(sender: AnyObject) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            let imagePickerController = UIImagePickerController()
            
            // フォトライブラリから選択
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // 編集OFFに設定
            // これをtrueにすると写真選択時、写真編集画面に移る
            imagePickerController.allowsEditing = false
            
            // デリゲート設定
            imagePickerController.delegate = self
            
            // 選択画面起動
            self.presentViewController(imagePickerController,animated:true ,completion:nil)
        }
    }
    
    //
    // MARK:保存ボタン
    //
    @IBAction func save(sender: UIButton) {
        let alertController = UIAlertController(title: "確認", message: "メモをカメラロールに保存しますか？", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) { action in
            
            let canvas_image = self.canvas?.image
            let save_image = self.saveImageView?.image
            
            if save_image != nil {
                if canvas_image != nil{
                    let hoge: UIImage? = self.synthesizeImage([save_image!, canvas_image!], size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height))
                self.data = UIImagePNGRepresentation(hoge!)!
                } else {
                self.data = UIImagePNGRepresentation(save_image!)!
                }
            } else {
                self.data = UIImagePNGRepresentation(canvas_image!)!
            }
            
            let fileName = self._second+".png"
            let filePath = self.documentsPath.stringByAppendingPathComponent(fileName)
            
            if self.data.writeToFile(filePath, atomically: true) {
                self.saveImageView.image = UIImage(named: filePath)
                NSLog(filePath)
                NSLog("OK")
            } else {
                NSLog("Error")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in
        }
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //
    // MARK:クリアボタン
    //
    @IBAction func clear(sender: UIButton) {
        let alertController = UIAlertController(title: "確認", message: "全消去してよろしいですか？", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) { action in
            self.clear()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in
        }
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /*
    --------------------------------------------
    // MARK: - 関数
    --------------------------------------------
    */
    
    //描画終点
    var lastDrawImage: UIImage!
    var bezierPath: UIBezierPath!
    
    //
    // MARK:タッチ開始時の処理
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //タッチ開始時の座標を取得
        let touch = touches.first!
        let currentPoint:CGPoint = touch.locationInView(canvas)
        bezierPath = UIBezierPath()
        //ベジェの終点スタイルの指定
        // Xcode7にアップデートした際、kCGLineCapRoundについてエラーが出るのでひとまずコメントアウト
        //bezierPath.lineCapStyle = kCGLineCapRound
        //起点（movetopoint）をcurrentに指定
        bezierPath.moveToPoint(currentPoint)
    }
    
    //
    // MARK:タッチ移動時の処理
    //
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //タッチされていないときは何もしない
        if bezierPath == nil {
            return
        }
        let touch = touches.first!
        let currentPoint:CGPoint = touch.locationInView(canvas)
        bezierPath.addLineToPoint(currentPoint)
        drawLine(bezierPath)
    }
    
    //
    // MARK:タッチ終了時の処理
    //
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //タッチされていないときは何もしない
        if bezierPath == nil {
            return
        }
        let touch = touches.first!
        let currentPoint:CGPoint = touch.locationInView(canvas)
        bezierPath.addLineToPoint(currentPoint)
        drawLine(bezierPath)
        lastDrawImage = canvas.image
    }
    
    //
    // MARK:描画処理
    //
    func drawLine(path:UIBezierPath) {
        
        //ここでの描画結果は表示はされない（見えない）が、描画結果はUIImageで取得できる
        UIGraphicsBeginImageContext(canvas.frame.size)

        if lastDrawImage != nil {
            lastDrawImage.drawAtPoint(CGPointZero)
        }
        // var blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        // blackColor.setStroke()
        pen_select()
        penColor.setStroke()

        path.stroke()
        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    //
    // MARK:ペンの色設定
    //
    func pen_select() {
        switch pen_flg{
        case 0: //鉛筆
            bezierPath.lineWidth = 3.0
            penColor = UIColor.blackColor()
            penColor.setStroke()
        case 1: //消しゴム
            bezierPath.lineWidth = 30.0
            penColor = UIColor.whiteColor()
            penColor.setStroke()
        default:
            bezierPath.lineWidth = 3.0
            penColor = UIColor.blackColor()
            penColor.setStroke()
        }
    }
    
    //
    // MARK:クリア処理
    //
    func clear() {
        lastDrawImage = nil
        canvas.image = nil
    }
    
    
    //
    // MARK:写真選択時
    //
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
            // イメージ表示
            // Xcode7でinfoについてエラーが出るので、ひとまずコメントアウト
            //var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            saveImageView.image = image
            self.view.sendSubviewToBack(saveImageView)    //最背面に配置
            
            // 選択画面閉じる
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK:Table関連
    //
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //
    // MARK:画像の結合
    //
    func synthesizeImage(names: Array<UIImage>, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        for name in names {
            let image = name
            image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
