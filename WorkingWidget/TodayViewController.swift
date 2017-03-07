//
//  TodayViewController.swift
//  WorkingWidget
//
//  Created by MacBook on 07/03/2017.
//  Copyright © 2017 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var reg  = false;
    let maxTimeMins = 10*60
    @IBOutlet var progressView: ProgressView!
      @IBOutlet var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(FIRApp.defaultApp() != nil) {
            FIRApp.configure();
        }
        statusLabel.text = ""
        addGradientBackgroundLayer()
        print(calcTimeProgress)
        //        progressView.animateProgressViewToProgress(calcTimeProgress)
        var timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.readDataFromFB), userInfo: nil, repeats: true);
        readDataFromFB()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        readDataFromFB()
        completionHandler(NCUpdateResult.newData)
    }
    
    func addGradientBackgroundLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        
        let colorTop: AnyObject = UIColor(red: 73.0/255.0, green: 223.0/255.0, blue: 185.0/255.0, alpha: 1.0).cgColor
        let colorBottom: AnyObject = UIColor(red: 36.0/255.0, green: 115.0/255.0, blue: 192.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func calcTimeProgress(res:[AnyObject]){
        //       progressView.animateProgressViewToProgress(0.5)
        //        let date = NSDate()
        let lastEnter:NSDate = res.last!["time"] as! NSDate
        let prevEnter:NSDate = res[res.count-2]["time"] as! NSDate
        var diff = 0.0
        if (res.last!["type"] as! String) == "leave" {
            diff = lastEnter.timeIntervalSince(prevEnter as Date)
        } else {
            diff = lastEnter.timeIntervalSinceNow
        }
        print(lastEnter.timeIntervalSinceNow)
        
        let res = diff/60
        let finalRes = abs(res/Double(maxTimeMins))
        print(finalRes)
        progressView.animateProgressViewToProgress(Float(finalRes))
        progressView.updateProgressViewLabelWithProgress(Float(finalRes)*10)
        progressView.updateProgressViewWith(Float(finalRes), totalFileSize: Float(10.0))
        
        
    }
    
    func readDataFromFB(){
        var res:[NSDictionary]=[]
        let ref = FIRDatabase.database().reference().child("putcygov").child("Recs")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                //                print(rest.value!)
                var val:[String] =  rest.value! as! [String]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                let date = dateFormatter.date(from: val[0] as String)
                
                res.append(["time":date!, "type":val[1]])
            }
            
            self.calcTimeProgress(res: res)
            //            self.tableView.reloadData()
        })
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize =  CGSize(width: 320, height: 200)
            }, completion: nil)
            
        }
        else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize =   CGSize(width: 320, height: 300)
            }, completion: nil)
        }
    }
    
}
