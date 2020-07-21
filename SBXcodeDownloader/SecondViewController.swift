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
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var currentURLTextField: NSTextField!
    @IBOutlet weak var downloadButton: NSButton!
    var downloadFolderPath: URL! = nil
    
    private var currentURL: URL? = nil {
        didSet {
            if currentURL != nil {
                let request = URLRequest(url: currentURL!)
                self.webView.load(request)
                self.currentURLTextField.stringValue = currentURL!.absoluteString
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadBaseURLViewController()
    }
    
    private func loadBaseURLViewController() {
        self.performSegue(withIdentifier: "loadBaseURLViewController", sender: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let baseURLViewController = segue.destinationController as? ObtainBaseURLViewController {
            baseURLViewController.delegate = self
        }
    }

    @IBAction private func downloadButtonTapped(_ sender: Any) {
        if let downloadViewController = self.storyboard?.instantiateController(withIdentifier: "downloadScreen") as? DownloadViewController,
           let userSelectedURL = URL(string: self.currentURLTextField.stringValue) {
            self.parseWebViewForCookiesAndGenerateCookiesTxt(webView: self.webView,
                                                             downloadFolderPath: self.downloadFolderPath) {[weak self] in
                guard let self = self else { return }
                let cookieFileURL = self.downloadFolderPath.appendingPathComponent("cookies").appendingPathExtension("txt")
                let downloadViewModel = DownloadViewControllerViewModel(cookieFileURL: cookieFileURL,
                                                                        urlSelectedByUser: userSelectedURL,
                                                                        downloadFolderPath: self.downloadFolderPath)
                downloadViewController.viewModel = downloadViewModel
                self.view.window?.contentViewController = downloadViewController
            }
        }
    }
}

extension SecondViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.currentURLTextField.stringValue = navigationAction.request.url?.absoluteString ?? ""
        decisionHandler(.allow)
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.progressIndicator.stopAnimation(self)
//    }
}

extension SecondViewController: NSTextFieldDelegate {
    
}


extension SecondViewController: DismissOnObtainingBaseURL {
    func dismiss(with baseURL: URL) {
        self.currentURL = baseURL
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

extension SecondViewController: CookieGeneratorProtocol {}
