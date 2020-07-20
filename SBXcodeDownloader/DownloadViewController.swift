//
//  DownloadViewController.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 18/07/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {
    @IBOutlet weak var downloadStatusLabel: NSTextField!
    @IBOutlet weak var downloadProgressBar: NSProgressIndicator!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet var consoleTextView: NSTextView!
    var downloadTask: Process!
    var viewModel: DownloadViewControllerViewModel!
    var tailTask: Process!
    var tailPipe: Pipe!
    var awkTask: Process!
    var awkPipe: Pipe!
    var timer: Timer!
    
    
    var downloadProgressAmount: Double = 0.0 {
        didSet {
            if self.downloadProgressAmount > 0.0 {
                if self.downloadProgressBar.isIndeterminate {
                    self.downloadProgressBar.isIndeterminate = false
                    self.downloadProgressBar.stopAnimation(self)
                }
                self.downloadProgressBar.doubleValue = downloadProgressAmount
                if self.downloadProgressAmount >= 100.0 {
                    self.timer?.invalidate()
                    updateCompletionView()
                }
                else {
                    self.downloadStatusLabel.stringValue = "Progress... \(downloadProgressAmount)%"
                }
            }
            else {
                self.downloadProgressBar.isIndeterminate = true
                self.downloadProgressBar.startAnimation(self)
                self.downloadStatusLabel.stringValue = self.isRunning ? "Downloading ..." : "Download Paused ..."
            }
        }
    }
    
    var isRunning: Bool = false {
        didSet {
            let title = self.isRunning ? "Pause" : "Download"
            self.playPauseButton.title = title
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(stopTasks), name: NSWindow.willCloseNotification, object: self.view.window)
        
        self.consoleTextView.isEditable = false
        self.startTask()
        self.downloadProgressAmount = 0.0
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: Any) {
        if self.isRunning == false {
            self.startTask()
        }
        else {
            self.stopTasks()
        }
    }
    
    private func startTask() {
        self.isRunning = true
        
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else { return }
            self.downloadTask = Process()

            self.downloadTask.currentDirectoryURL = self.viewModel.downloadFolderPath
            self.downloadTask.launchPath = "/usr/local/bin/wget"

            self.downloadTask.arguments = []
            self.downloadTask.arguments?.append("-o log.txt")
            self.downloadTask.arguments?.append("--load-cookies=\(self.viewModel.cookieFileURL.path)")
            self.downloadTask.arguments?.append("-c")
            self.downloadTask.arguments?.append(self.viewModel.urlSelectedByUser.absoluteString)
            
            self.downloadTask.terminationHandler = {[weak self] task in
                guard let self = self else { return }
                let terminationStatus = self.downloadTask?.terminationStatus
                self.downloadTask = nil
                DispatchQueue.main.async(execute: {[weak self] in
                    guard let self = self else { return }
                    self.isRunning = false
                    if terminationStatus == 0 || self.downloadProgressAmount >= 100.0 {
                        self.updateCompletionView()
                    }
                })
            }
            
            self.redirectStandardOutputToTextView()
            
            self.downloadTask.launch()
            self.downloadTask.waitUntilExit()
        }
    }
    
    @objc private func stopTasks() {
        self.downloadTask?.terminate()
        self.tailTask?.terminate()
        self.awkTask?.terminate()
        self.tailTask = nil
        self.tailPipe = nil
        self.awkTask = nil
        self.awkPipe = nil
        self.downloadStatusLabel.stringValue = "Download Paused ..."
    }
    
    private func updateCompletionView() {
        self.tailTask?.terminate()
        self.awkTask?.terminate()
        self.tailTask = nil
        self.tailPipe = nil
        self.awkTask = nil
        self.awkPipe = nil
        self.downloadProgressBar.isIndeterminate = false
        self.downloadProgressBar.doubleValue = 100.0
        self.downloadStatusLabel.stringValue = "Download Completed"
        self.playPauseButton.isEnabled = true
        self.performSegue(withIdentifier: "completionSegue", sender: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let downloadCompletionVC = segue.destinationController as? DownloadCompletionViewController {
            downloadCompletionVC.delegate = self
            downloadCompletionVC.downloadFilePath = "You can find your Xcode downloaded at \(self.viewModel.downloadFolderPath.path)"
        }
    }
    
    private func redirectStandardOutputToTextView() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.global(qos: .background).async {[weak self] in
                guard let self = self else { return }
                self.tailTask = Process()
                self.awkTask = Process()
                self.tailPipe = Pipe()
                self.awkPipe = Pipe()
                self.tailTask.currentDirectoryURL = self.viewModel.downloadFolderPath
                self.tailTask.launchPath = "/usr/bin/tail"
                self.tailTask.arguments = ["-n 2"]
                self.tailTask.arguments?.append(" log.txt")
                self.tailTask.standardOutput = self.tailPipe

                self.awkTask.currentDirectoryURL = self.viewModel.downloadFolderPath
                self.awkTask.launchPath = "/usr/bin/awk"
                self.awkTask.arguments = ["{ print $7 }"]
                self.awkTask.standardInput = self.tailPipe
                self.awkTask.standardOutput = self.awkPipe

                self.awkPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

                NotificationCenter.default
                    .addObserver(forName: Notification.Name.NSFileHandleDataAvailable,
                                 object: self.awkPipe!.fileHandleForReading,
                                 queue: nil) { (notification) in
                                    if let output = self.awkPipe?.fileHandleForReading.availableData, output.count > 0 {
                                        let outputString = String(bytes: output, encoding: .utf8)
                                        
                                        let consoleLogURL = self.viewModel.downloadFolderPath.appendingPathComponent(" log.txt")
                                        let fileContent = FileManager.default.contents(atPath: consoleLogURL.path)
                                        
                                        if let stringArray = outputString?.components(separatedBy: CharacterSet.decimalDigits.inverted) {
                                            for item in stringArray {
                                                if let number = Double(item) {
                                                    DispatchQueue.main.async {
                                                        self.downloadProgressAmount = Double(number)
                                                        self.consoleTextView.string = String(data: fileContent ?? Data(), encoding: .utf8) ?? ""
                                                        self.consoleTextView.scrollToEndOfDocument(self)
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                    }

                }

                self.awkTask?.launch()
                self.tailTask?.launch()
                self.awkTask?.waitUntilExit()
                self.tailTask?.waitUntilExit()

                self.tailTask = nil
                self.awkTask = nil
                self.tailPipe = nil
                self.awkPipe = nil
            }
        }
    }
}

extension DownloadViewController: ChangeRootViewControllerProtocol {
    func changeRootVC() {
        if let initialViewController = self.storyboard?.instantiateController(withIdentifier: "initialViewController") as? ViewController {
            self.view.window?.contentViewController = initialViewController
        }
    }
}
