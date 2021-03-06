//
//  UploaderViewController.swift
//  PoReader
//
//  Created by 黄中山 on 2020/5/21.
//  Copyright © 2020 potato. All rights reserved.
//

import UIKit
import GCDWebServer

class UploaderViewController: BaseViewController {
    
    private var webUploader: PoReaderWebUploader?
    private lazy var hostLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        startUploadServer()
    }
    
    private func setupUI() {
        title = "书本上传"
        
        view.addSubview(hostLabel)
        hostLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func startUploadServer() {
        webUploader = PoReaderWebUploader(uploadDirectory: Constants.localBookDirectory)
        webUploader?.allowedFileExtensions = ["txt"] // 只支持上传txt
        webUploader?.prologue = "请将书本拖至下方方框，或者点击上传按钮，目前只支持txt格式"
        webUploader?.delegate = self
        webUploader?.start(withPort: 8866, bonjourName: "Reader Uploader Server")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hostLabel.text = "请确保手机和电脑在同一Wifi下，在电脑浏览器上打开如下地址：\n\(webUploader?.serverURL?.absoluteString ?? "无效地址")"
    }
    
    deinit {
        webUploader?.stop()
    }
    
}

// MARK: - GCDWebUploaderDelegate

extension UploaderViewController: GCDWebUploaderDelegate {
    
    /// 将上传的书本存入本地数据库
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        let bookName = ((path as NSString).deletingPathExtension as NSString).lastPathComponent
        Database.shared.addBook(bookName)
    }
    
    /// 在浏览器端删除书本
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        let bookName = ((path as NSString).deletingPathExtension as NSString).lastPathComponent
        Database.shared.removeBook(bookName)
    }
}


class PoReaderWebUploader: GCDWebUploader {
    /**
     *  This method is called to check if a file upload is allowed to complete.
     *  The uploaded file is available for inspection at "tempPath".
     *
     *  The default implementation returns YES.
     */
//    /// 只允许上传txt格式文件
//    override func shouldUploadFile(atPath path: String, withTemporaryFile tempPath: String) -> Bool {
//        return (path as NSString).pathExtension == "txt"
//    }

    /**
     *  This method is called to check if a file or directory is allowed to be moved.
     *
     *  The default implementation returns YES.
     */
    override func shouldMoveItem(fromPath: String, toPath: String) -> Bool {
        return false
    }

    /**
     *  This method is called to check if a file or directory is allowed to be deleted.
     *
     *  The default implementation returns YES.
     */
//    override func shouldDeleteItem(atPath path: String) -> Bool {
//        return false
//    }

    /**
     *  This method is called to check if a directory is allowed to be created.
     *
     *  The default implementation returns YES.
     */
    override func shouldCreateDirectory(atPath path: String) -> Bool {
        return false
    }

}
