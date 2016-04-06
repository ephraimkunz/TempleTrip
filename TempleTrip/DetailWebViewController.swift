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
    var url : NSURL!
    
    init(url : NSURL){
        self.url = url
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL:url))
        webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
