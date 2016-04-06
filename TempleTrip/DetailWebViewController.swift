//
//  DetailWebViewViewController.swift
//  TempleTrip
//
//  Created by Ephraim Kunz on 4/5/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

import UIKit
import WebKit

class DetailWebViewController: UIViewController, WKNavigationDelegate {
    var webView : WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string:"https://www.apple.com")!
        webView.loadRequest(NSURLRequest(URL:url))
        webView.allowsBackForwardNavigationGestures = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
