//
//  TPCContactHelper.swift
//  TPCContact
//
//  Created by tripleCC on 16/3/31.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCContactHelper: NSObject {
    static func systemVersion() -> String {
        return UIDevice.currentDevice().systemVersion
    }
    
    /**
     异步callback，同步completion
     
     - parameter callBack:   异步callback
     - parameter completion: 同步completion
     */
    static func callAsyncBlock(block: () -> Void, syncCompletion completion: () -> Void) -> Void {
        let currentQueue = NSOperationQueue.currentQueue()
        let operation = NSBlockOperation(block: block)
        operation.completionBlock = {
            currentQueue?.addOperation(NSBlockOperation(block: completion))
        }
        NSOperationQueue().addOperation(operation)
    }
    
    /**
     同步callback，异步completion
     
     - parameter callBack:   同步callback
     - parameter completion: 异步completion
     */
    static func callSyncBlock(block: () -> Void, asyncCompletion completion: () -> Void) -> Void {
        let operation = NSBlockOperation(block: block)
        operation.completionBlock = completion
        NSOperationQueue.currentQueue()?.addOperation(operation)
    }
}

typealias AddressPhoneNumber = String
extension AddressPhoneNumber {
    func normalizeMobileNumber() -> String? {
        var numberTrimPattern = "\\D"
        do {
            let regular = try NSRegularExpression(pattern: numberTrimPattern, options: .CaseInsensitive)
            let pureNumber = regular.stringByReplacingMatchesInString(self, options: [], range: NSRange(location: 0, length: characters.count), withTemplate: "")
            if !isEmpty && pureNumber.isMobileNumber() {
                numberTrimPattern = "(1)\\d{10}"
                do {
                    let regular = try NSRegularExpression(pattern: numberTrimPattern, options: .CaseInsensitive)
                    if let checkResult = regular.firstMatchInString(pureNumber, options: [], range:  NSRange(location: 0, length: pureNumber.characters.count)) {
                        if checkResult.range.location != NSNotFound {
                            return (pureNumber as NSString).substringWithRange(checkResult.range)
                        }
                    }
                } catch let error {
                    print("init regular expression failed with error: \(error)")
                }
            }
        } catch let error {
            print("init regular expression failed with error: \(error)")
        }

        return nil
    }
    
    func isMobileNumber() -> Bool {
        let pattern = "^((\\+|00)?86)?(1)\\d{10}$"
        let predicate = NSPredicate(format: "SELF matches %@", pattern)
        return predicate.evaluateWithObject(self)
    }
}

extension Optional {
    func stringValue() -> String {
        return self as? String ?? ""
    }
    
    func arrayValue<T>() -> [T] {
        return self as? [T] ?? [T]()
    }
    

}