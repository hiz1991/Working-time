//
//  FBHelper.swift
//  GeoTargeting
//
//  Created by MacBook on 05/03/2017.
//  Copyright © 2017 Evgenii Trapeznikov. All rights reserved.
//
//
//import Foundation
//import Firebase
//class FBHelper{
//    func readDataFromFB(callback:){
//        var res:[NSDictionary]=[]
//        let ref = FIRDatabase.database().reference().child("putcygov").child("Recs")
//        ref.observeSingleEvent(of: .value, with: { snapshot in
//            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
//                //                print(rest.value!)
//                var val:[String] =  rest.value! as! [String]
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//                let date = dateFormatter.date(from: val[0] as String)
//                
//                res.append(["time":date!, "type":val[1]])
//                
//            }
//            callback(res)
//        })
//    }
//    
//    
//}
