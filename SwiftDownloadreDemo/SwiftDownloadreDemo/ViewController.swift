//
//  ViewController.swift
//  SwiftDownloadreDemo
//
//  Created by gao on 2018/10/19.
//  Copyright © 2018年 gao. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var downloadManager:SYDownloadTaskManager!
    private var urlCount = 0
    private var urls:[String]! = ["http://mmm.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E03.mp4",
                          "http://ooo.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E05.mp4",
                          "http://ooo.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E04.mp4",
                          "http://zuidazy.xunleiziyuan.net/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E06.mp4",
                          "http://zuidazy.xunleiziyuan.net/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E07.mp4",
                          "http://xunleia.zuida360.com/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E08.mp4",
                          "http://xunleia.zuida360.com/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E09.mp4",
                          "http://xunleia.zuida360.com/1802/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E10.mp4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadManager = SYDownloadTaskManager.init()
        self.downloadManager.maxTaskCount = 3
        self.downloadManager.downloadTaskCompletionHandle = {(url:String!, locationPath:String!) -> Void in
            print("完成" + "url:" + url + "local:" + locationPath)
        }
        self.downloadManager.downloadTaskProgressHandle = {(url:String!, progress:Float!) -> Void in
            let row = self.urls.index(of: url)
              DispatchQueue.main.async {
                let cell = self.tableView.cellForRow(at: IndexPath.init(row: row!, section: 0)) as! DownloadTableViewCell?
                if cell != nil {
                        cell?.progress?.progress = progress
                }
            }
        }
        
        self.downloadManager.downloadTaskStateChangedHandle = {(model:SYDownloadTaskModel!) -> Void in
            let row = self.urls.index(of: model.url!)
               DispatchQueue.main.async {
                  let cell = self.tableView.cellForRow(at: IndexPath.init(row: row!, section: 0)) as! DownloadTableViewCell?
                  if cell != nil {
                    cell?.stateLabel?.text = self.string(withState: model.state)
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DownloadTableViewCell.self), for: indexPath) as! DownloadTableViewCell
        let model = self.downloadManager.taskModel(withURLStr: self.urls[indexPath.row])
        
        cell.nameLabel?.text = String(indexPath.row)
        cell.stateLabel?.text = self.string(withState: (model?.state)!)
        cell.progress?.progress = (model?.progress)!
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.urls[indexPath.row]
        let model:SYDownloadTaskModel! = self.downloadManager.taskModel(withURLStr: url)
        switch model.state {
        case .added, .suspend, .fail:
            self.downloadManager.resumeTask(withURLStr: url)
        case .downloading, .waiting:
            self.downloadManager.suspendTask(withURLStr: url)
        case .finshed:
            print("")
        }
        
        
    }
    @IBAction func wwanAction(_ sender: UIButton) {
        //移动网络
        sender.isSelected = !sender.isSelected;
        self.downloadManager.allowsCellularAccess = sender.isSelected
     
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if self.urlCount > 0 {
            self.urlCount -= 1
            self.downloadManager.deleteTask(withURLStr: self.urls[self.urlCount])
            self.tableView.deleteRows(at: [IndexPath.init(row: self.urlCount, section: 0)], with: .bottom)
        }
    }

    @IBAction func addAction(_ sender: UIButton) {
        if self.urlCount < self.urls.count {
            let index = self.urlCount
            self.urlCount += 1
            self.downloadManager.addTask(withURLStr: self.urls[index], type: "mp4")
            self.tableView.insertRows(at: [IndexPath.init(row: index, section: 0)], with: .bottom)
            
        }
    }
   private func string(withState:SYDownloadTaskState) -> String {
        switch withState {
        case .added:
            return "added"
        case .downloading:
            return "downloading"
        case .suspend:
            return "suspend"
        case .finshed:
            return "finshed"
        case .waiting:
            return "waiting"
        case .fail:
            return "fail"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

