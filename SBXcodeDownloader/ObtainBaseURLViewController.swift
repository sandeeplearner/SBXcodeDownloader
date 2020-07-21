//
//  ObtainBaseURLViewController.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 22/07/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Cocoa

@objc protocol DismissOnObtainingBaseURL {
    func dismiss(with baseURL: URL)
}

class ObtainBaseURLViewController: NSViewController {
    weak var delegate: DismissOnObtainingBaseURL? = nil
    @IBOutlet weak var urlTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        if self.urlTextField.stringValue.isValidURL, let url = URL(string: self.urlTextField.stringValue) {
            self.dismiss(self)
            self.delegate?.dismiss(with: url)
        }
    }
}
