//
//  ViewController.swift
//  TweetJSON
//
//  Created by Andy Piper on 13/06/2017.
//  Copyright © 2017 Andy Piper. All rights reserved.
//

// TODO: add toggles for get statuses/lookup options
// TODO: support user ID lookup
// TODO: refactor Tweet fetch code

// TODO: share extension

// TODO: clear screen
// TODO: fix dynamic text size (needs to redraw)
// TODO: syntax colour configuration
// TODO: quick copy full JSON body to pasteboard

import UIKit
import TwitterKit
import Highlightr
import Crashlytics

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: properties
    @IBOutlet weak var tweetID: UITextField!
    @IBOutlet weak var jsonBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Answers.logCustomEvent(withName: "Started",
                               customAttributes: [:])

        let readyText = "{ status: \"Ready to display response...\" }"
        self.jsonBody.attributedText = self.highlightCode(code: readyText)

        tweetID.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    //MARK: actions
    @IBAction func queryButton(_ sender: Any) {
        tweetID.resignFirstResponder()
        callApi()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tweetID {
            textField.resignFirstResponder()
            callApi()
            return false
        }
        return true
    }
    
    func highlightCode( code: String ) -> NSAttributedString {
        
        // colour codes a piece of text passed in as a String
        // returns an NSAttributedString with styling
        
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "github") // make configurable
        let highlightedCode = highlightr?.highlight(code)

        return highlightedCode!
    }
    
    func callApi() {
        
        // this all needs to be refactored into a separate function
        // should check for nil tweetID value
        let tweetVal = self.tweetID.text
        
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/show.json"
        
        // params should be broken out and toggled / optional
        let params = ["id": tweetVal!, "tweet_mode": "extended"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in

            // log that we ran a request metrics purposes
            // (but NOT what we searched for, privacy)
            // once refactored should measure Tweet vs User queries
            Answers.logCustomEvent(withName: "Tweet query",
                                           customAttributes: [:])
            
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
                Crashlytics.sharedInstance().recordError(connectionError!)
            }
            
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("json: \(json)") // debug, not really useful
                    let jsonObj = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let jsonString = NSString(data: jsonObj, encoding: String.Encoding.utf8.rawValue)
                    
                    self.jsonBody.attributedText = self.highlightCode(code: jsonString! as String)
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                    self.jsonBody.text = jsonError.localizedDescription
                    Crashlytics.sharedInstance().recordError(jsonError)
                }

            } else {
                let statusText = "{ status: \"no valid response from API\" }"
                self.jsonBody.attributedText = self.highlightCode(code: statusText)

            }
            
        }
        
    }
    
}
