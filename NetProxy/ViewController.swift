//
//  ViewController.swift
//  NetProxy
//
//  Created by Mohsin on 10/08/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import CFNetwork

class ViewController: UIViewController, NSURLSessionDelegate, NSURLSessionTaskDelegate {

    
    
    @IBOutlet weak var txtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtView.text = ""

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func click(sender: UIButton) {
        
        self.getCountry("", callBack: { (error) -> Void in
            
            
        })
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        
        self.txtView.text = "\(self.txtView.text) \n didReceiveChallenge Method "
        
        var credential = NSURLCredential(user: "test3", password: "karachi@3", persistence: NSURLCredentialPersistence.ForSession)
        
        
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential)
        
    }
    
    
    
    
    func getCountry(password: String, callBack : (error: String?) -> Void){
        
        let getCountryUrl = "http://www.bluewaydesign.com/travelbook/index.php/webservice/getcountries"
        
        let tempUrl = "https://www.google.com"

        var session : NSURLSession!
        
        let proxyDictionary = CFNetworkCopySystemProxySettings().takeRetainedValue() as Dictionary
        
        println(proxyDictionary)
        

        if proxyDictionary["HTTPEnable"] != nil{
            
            
            //proxy setting
//            var proxyHost = "10.1.0.11"
//            var proxyPort = NSNumber(integer: 8080)
//            var proxyUsername = "test3"
//            var proxyPassword = "karachi@3"
            
            var proxyHost = proxyDictionary["HTTPSProxy"] as! CFStringRef
            var proxyPort = proxyDictionary["HTTPSPort"] as! CFNumberRef
            
            println(proxyHost)
            println(proxyPort)
            
            var proxyDict : NSDictionary = [
                "HTTPEnable":1,
                String(kCFStreamPropertyHTTPProxyHost) : proxyHost,
                String(kCFStreamPropertyHTTPProxyPort) : proxyPort,
                
                
                "HTTPSEnable":1,
                String(kCFStreamPropertyHTTPSProxyHost) : proxyHost,
                String(kCFStreamPropertyHTTPSProxyPort) : proxyPort,
            ]
            
            
            var configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            configuration.connectionProxyDictionary = proxyDict as [NSObject : AnyObject]
            //        configuration.connectionProxyDictionary = CFBridgingRetain(CFNetworkCopySystemProxySettings())
            
            
            session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        }
        else{
            session = NSURLSession.sharedSession()
        }

        
//        FTPPasive = 1
//        HTTPEnable = 1
//        HTTPPort = 8080
//        HTTPProxy = 10.1.0.11
//        HTTPProxyAuthenticated = 1
//        HTTPProxyUsername = test3
//        HTTPSEnable = 1
//        HTTPSPort = 8080
//        HTTPSProxy = 10.1.0.11
        
        self.txtView.text = "\(self.txtView.text) \n \(proxyDictionary)"
        
        //var session = NSURLSession.sharedSession()
        
        // Create a NSURLSession with our proxy aware configuration


        
        var request = NSMutableURLRequest(URL: NSURL(string: getCountryUrl)!)
        var err: NSError?
        
        request.HTTPMethod = "POST"
        
        //var params = ["email": "asdas@dsa.com"]
        var params = [:]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            println("Body: \(strData)\n\n")
            
            
            if strData != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.txtView.text = "\(self.txtView.text) \n \(strData?.description)"
                    
                })
            }
            
            var err: NSError?
            
            // if response is not found nil
            if response != nil{
                
                
                
                if((err) != nil) {
                    
                    //                    println(err!.localizedDescription)
                    callBack(error: err!.localizedDescription)
                    
                }

            }
                
                // if response is not found nil
            else if response == nil {
                callBack(error: "respnse is nil")
            }
        })
        
        task.resume()
        
    }
    
}




