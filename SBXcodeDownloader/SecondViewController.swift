//
//  SecondViewController.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 18/07/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Cocoa
import WebKit

class SecondViewController: NSViewController {
//    @IBOutlet weak var webView: WKWebView!
//    @IBOutlet weak var progressIndicator: NSProgressIndicator!
//    @IBOutlet weak var urlTextField: NSTextField!
//    @IBOutlet weak var downloadButton: NSButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.urlTextField.delegate = self
//        self.progressIndicator.startAnimation(self)
//        if let url = URL(string: "https://developer.apple.com/download/more/") {
//            let urlRequest = URLRequest(url: url)
//            self.webView.load(urlRequest)
//            self.webView.navigationDelegate = self
//        }
//    }
//
//    func controlTextDidChange(_ obj: Notification) {
//        self.checkIfDownloadButtonShouldBeEnabled()
//    }
//
//    func controlTextDidEndEditing(_ obj: Notification) {
//        self.view.window?.resignFirstResponder()
//    }
//
//    private func checkIfDownloadButtonShouldBeEnabled() {
//        self.downloadButton.isEnabled = self.urlTextField.stringValue.isValidURL
//    }
//
//    @IBAction private func downloadButtonTapped(_ sender: Any) {
//        if let secondViewController = self.storyboard?.instantiateController(withIdentifier: "downloadScreen") as? DownloadViewController {
//            self.view.window?.contentViewController = secondViewController
//        }
//    }
}

extension SecondViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let absoluteString = navigationAction.request.url?.absoluteString, absoluteString.contains("download.developer.apple.com/Developer_Tools") {
//            self.urlTextField.stringValue = navigationAction.request.url?.absoluteString ?? ""
//            self.checkIfDownloadButtonShouldBeEnabled()
//            decisionHandler(.cancel)
//        }
//        else {
//            decisionHandler(.allow)
//        }
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.progressIndicator.stopAnimation(self)
//    }
}

extension SecondViewController: NSTextFieldDelegate {
    
}

extension String {
//    var isValidURL: Bool {
//        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
//            // it is a link, if the match covers the whole string
//            return match.range.length == self.utf16.count
//        } else {
//            return false
//        }
//    }
}
