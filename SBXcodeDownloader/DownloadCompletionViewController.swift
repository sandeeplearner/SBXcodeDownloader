//
//  DownloadCompletionViewController.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 20/07/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Cocoa

protocol ChangeRootViewControllerProtocol: NSViewController {
    func changeRootVC()
}

class DownloadCompletionViewController: NSViewController {
    @IBOutlet weak var downloadLocationLabel: NSTextField!
    var downloadFilePath: String = ""
    weak var delegate: ChangeRootViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadLocationLabel.stringValue = downloadFilePath
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.dismiss(self)
        self.delegate?.changeRootVC()
    }
}
