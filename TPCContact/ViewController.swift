//
//  ViewController.swift
//  TPCContact
//
//  Created by tripleCC on 16/3/31.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        TPCContactManager.shareManager.fetchContactsWithCompletion { (contacts) in
            print(contacts)
        }
        
//        TPCContactHelper.asyncCallBack({
//            print( "b: \(NSThread.currentThread())")
//            }) {
//                print(NSThread.currentThread())
//        }
//        
//        TPCContactHelper.syncCallBack({
//            print( "b: \(NSThread.currentThread())")
//        }) {
//            print(NSThread.currentThread())
//        }
//        print(TPCContactMan.asager.shareManager.contacts)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

