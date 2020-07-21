//
//  ViewController.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 12/04/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Cocoa
import WebKit

//"https://idmsa.apple.com/IDMSWebAuth/signin?appIdKey=891bd3417a7776362562d2197f89480a8547b108fd934911bcbea0110d07f757&path=%2Faccount%2F&rv=1"
///account/#/welcome
class ViewController: NSViewController {
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var pathControl: NSPathControl!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    private var downloadFolderPath: URL = URL(fileURLWithPath: "~/Downloads")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pathControl.allowedTypes = ["public.folder"]
        self.progressIndicator.startAnimation(self)
        if let url = URL(string: "https://developer.apple.com/download/more/") {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
            self.webView.navigationDelegate = self
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func openDownloadViewController(with userSelectedURL: URL) {
        if let downloadViewController = self.storyboard?.instantiateController(withIdentifier: "downloadScreen") as? DownloadViewController {
            let cookieFileURL = self.downloadFolderPath.appendingPathComponent("cookies").appendingPathExtension("txt")
            let downloadViewModel = DownloadViewControllerViewModel(cookieFileURL: cookieFileURL, urlSelectedByUser: userSelectedURL, downloadFolderPath: self.downloadFolderPath)
            downloadViewController.viewModel = downloadViewModel
            self.view.window?.contentViewController = downloadViewController
        }
    }
    
    @IBAction func openSecondViewController(_ sender: Any) {
        if let secondViewController = self.storyboard?.instantiateController(withIdentifier: "secondVC") as? SecondViewController {
            secondViewController.downloadFolderPath = self.downloadFolderPath
            self.view.window?.contentViewController = secondViewController
        }
    }
    
    @IBAction private func pathSelectorTriggered(sender: NSPathControl) {
        if let url = sender.url {
            self.downloadFolderPath = url
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let absoluteString = navigationAction.request.url?.absoluteString, absoluteString.contains("download.developer.apple.com/Developer_Tools") {
            let downloadURL = navigationAction.request.url!
            self.parseWebViewForCookiesAndGenerateCookiesTxt(webView: self.webView,
                                                             downloadFolderPath: self.downloadFolderPath) {[weak self] in
                self?.openDownloadViewController(with: downloadURL)
            }
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.progressIndicator.stopAnimation(self)
    }
}

extension ViewController: CookieGeneratorProtocol {}

extension Date {
    func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}
