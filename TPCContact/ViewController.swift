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
        TPCContactManager.shareManager.loadAddressBook()
//        print(TPCContactManager.shareManager.contacts)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

