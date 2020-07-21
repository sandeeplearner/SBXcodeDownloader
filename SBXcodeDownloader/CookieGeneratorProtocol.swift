//
//  CookieGeneratorProtocol.swift
//  SBXcodeDownloader
//
//  Created by sandeep bhandari on 22/07/20.
//  Copyright © 2020 sandeep bhandari. All rights reserved.
//

import Foundation
import WebKit

protocol CookieGeneratorProtocol: NSViewController {
    func getCookieString(for cookie: HTTPCookie) -> String
    func writeToFile(cookieString: String, fileURLToSave: URL)
    func parseWebViewForCookiesAndGenerateCookiesTxt(webView: WKWebView, downloadFolderPath: URL, completion: @escaping () -> ())
}

extension CookieGeneratorProtocol {
    func getCookieString(for cookie: HTTPCookie) -> String {
        var cookieString = ""
        cookieString = cookie.domain + "\t"
        cookieString += "TRUE\t"
        cookieString += cookie.path + "\t"
        cookieString += cookie.isSecure ? "TRUE" + "\t" : ""
        var timeIntervalString = "0"
        if let expiryDate = cookie.expiresDate {
            timeIntervalString = "\(expiryDate.timeIntervalSince1970)" + "\t"
        }
        else {
            timeIntervalString += "\t"
        }
        cookieString += timeIntervalString
        cookieString += cookie.name + "\t"
        cookieString += cookie.value + "\n"
        return cookieString
    }
    
    func writeToFile(cookieString: String, fileURLToSave: URL) {
        let fileURL = fileURLToSave.appendingPathComponent("cookies").appendingPathExtension("txt")
        do {
            try cookieString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Error: fileURL failed to write: \n\(error)" )
        }
    }
    
    func parseWebViewForCookiesAndGenerateCookiesTxt(webView: WKWebView, downloadFolderPath: URL, completion: @escaping () -> ()) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {[weak self] (cookies) in
            guard let self = self else { return }
            var cookieString = ""
            for cookie in cookies {
                if cookie.domain.contains(".apple.com") {
                    cookieString += self.getCookieString(for: cookie)
                }
            }
            self.writeToFile(cookieString: cookieString, fileURLToSave: downloadFolderPath)
            completion()
        }
    }
}
