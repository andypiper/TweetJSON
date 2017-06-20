//
//  ViewController.swift
//  TweetJSON
//
//  Created by Andy Piper on 13/06/2017.
//  Copyright © 2017 Andy Piper. All rights reserved.
//

// TODO: make get status options toggles
// TODO: clear screen
// TODO: share extension
// TODO: refactor Tweet fetch code
// TODO: syntax colouring
// TODO: support user ID lookup as well
// TODO: quick copy full JSON body

import UIKit
import TwitterKit

class ViewController: UIViewController {
    
    //MARK: properties
    @IBOutlet weak var tweetID: UITextField!
    @IBOutlet weak var jsonBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: actions
    @IBAction func queryButton(_ sender: Any) {
        callApi()
    }
    
    func callApi() {
        self.tweetID.resignFirstResponder()
        
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
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
            }
            
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("json: \(json)") // debug, not really useful
                    let jsonObj = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let jsonString = NSString(data: jsonObj, encoding: String.Encoding.utf8.rawValue)
                    self.jsonBody.text = jsonString! as String
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                    self.jsonBody.text = jsonError.localizedDescription
                }

            } else {
                self.jsonBody.text = "no valid response from the API"
            }
            
        }
        
    }
    
}
