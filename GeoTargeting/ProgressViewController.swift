//
//  ProgressView.swift
//  GeoTargeting
//
//  Created by MacBook on 05/03/2017.
//  Copyright © 2017 Evgenii Trapeznikov. All rights reserved.
//

import Foundation
import Firebase
//  ViewController.swift
//  ZDT-DownloadVideo
//
//  Created by Sztanyi Szabolcs on 11/04/15.
//  Copyright (c) 2015 Sztanyi Szabolcs. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, URLSessionDownloadDelegate {
    
    let maxTimeMins = 10*60
    
    @IBOutlet var progressView: ProgressView!
    
//    @IBOutlet weak var progressView: ProgressView!
    
    @IBOutlet var statusLabel: UILabel!
    
//    @IBOutlet weak var downloadButton: DownloadButton!
    
    @IBOutlet var downloadButton: DownloadButton!
    
//    @IBOutlet weak var progressView: UIView!
//    
//    @IBOutlet weak var downloadButton: UIButton!
//    
//    @IBOutlet weak var statusLabel: UILabel!
    
    fileprivate var downloadTask: URLSessionDownloadTask?
    
    @IBAction func downloadButtonPressed() {
        if let downloadTask = downloadTask {
            downloadTask.cancel()
            statusLabel.text = ""
        } else {
            statusLabel.text = "Downloading video"
            downloadButton.setTitle("Stop download", for: UIControlState())
            createDownloadTask()
        }
    }
    
    func createDownloadTask() {
        let downloadRequest = NSMutableURLRequest(url: URL(string: "https://www.dropbox.com/s/r6lr4zlw12ipafm/SpeedTracker_movie.mov?dl=1")!)
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        downloadTask = session.downloadTask(with: downloadRequest as URLRequest)
        downloadTask!.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressView.animateProgressViewToProgress(progress)
        progressView.updateProgressViewLabelWithProgress(progress * 100)
        progressView.updateProgressViewWith(Float(totalBytesWritten), totalFileSize: Float(totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        statusLabel.text = "Download finished"
        resetView()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            statusLabel.text = "Download failed"
        } else {
            statusLabel.text = "Download finished"
        }
        resetView()
    }
    
    func resetView() {
        downloadButton.setTitle("Start download", for: UIControlState())
        downloadTask!.cancel()
    }
    
    // MARK: view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
        addGradientBackgroundLayer()
        print(calcTimeProgress)
//        progressView.animateProgressViewToProgress(calcTimeProgress)
        var timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.readDataFromFB), userInfo: nil, repeats: true);
        readDataFromFB()
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
}
