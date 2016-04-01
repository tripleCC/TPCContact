//
//  TPCContactManager.swift
//  TPCContact
//
//  Created by tripleCC on 16/3/31.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import Contacts
import AddressBook

class TPCContactManager: NSObject {
    static let shareManager = TPCContactManager()
    // **************************************************** //
    //                      private var
    // **************************************************** //
    /// 是否在加载
    private var loading = false
    
    // **************************************************** //
    //                      public var
    // **************************************************** //
    /// 通讯录数据
    var contacts = [TPCMobileContact]()
    
    // **************************************************** //
    //                      private func
    // **************************************************** //
    /**
     加载通讯录
     */
    func loadAddressBook() {
        loading = true
        if TPCContactHelper.systemVersion() < 9.0 {
            let addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            if !requestAccessWithAddressBook(addressBook) {
                let authStatus = ABAddressBookGetAuthorizationStatus()
                guard authStatus != .Denied && authStatus != .Restricted else {
                    loading = false
                    return
                }
            }
            let peoples = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [CFTypeRef]
            for peopleValue in peoples {
                let people: ABRecordRef = peopleValue
                let fullName = fullNameForPeople(people)
                let phones = phonesForPeople(people)
                let contact = TPCMobileContact(fullName: fullName, phonesArray: phones)
                contacts.append(contact)
            }
        } else {
            
        }
        loading = false
    }
    
    private func phonesForPeople(people: ABRecordRef) -> [String] {
        var phones = [String]()
        let phonesValue = ABRecordCopyValue(people, kABPersonPhoneProperty).takeRetainedValue()
        let phoneCount = ABMultiValueGetCount(phonesValue)
        for i in 0 ..< phoneCount {
            if let phoneValue = ABMultiValueCopyValueAtIndex(phonesValue, i).takeRetainedValue() as? String {
                if let phone = phoneValue.normalizeMobileNumber() {
                    if phone.characters.count > 0 {
                        phones.append(phone)
                    }
                    print(phoneValue)
                }
            }
        }
        return phones
    }
    
    private func fullNameForPeople(people: ABRecordRef) -> String {
        let fullNameRef = ABRecordCopyCompositeName(people).takeRetainedValue()
        let fullName = fullNameRef as String
        return fullName.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    private func requestAccessWithAddressBook(addressBook: ABAddressBookRef) -> Bool {
        var accessGranted = false
        let semaphore = dispatch_semaphore_create(0)
        ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) in
            accessGranted = granted
            dispatch_semaphore_signal(semaphore)
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return accessGranted
    }
}
