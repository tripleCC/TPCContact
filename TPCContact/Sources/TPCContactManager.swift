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
    
    private var lessThanVersion9: Bool {
        return TPCContactHelper.systemVersion() < "9.0"
    }
    
    // **************************************************** //
    //                      public var
    // **************************************************** //
    /// 通讯录数据
    var contacts = [TPCMobileContact]()
    
    // **************************************************** //
    //                      public func
    // **************************************************** //
    /**
     加载通讯录
     */
    func fetchContactsWithCompletion(completion:(contacts: [TPCMobileContact]) -> Void) {
        TPCContactHelper.callAsyncBlock({ 
            self.fetchContacts()
            }) {
                completion(contacts: self.contacts)
        }
    }
    
    // **************************************************** //
    //                      private func
    // **************************************************** //
    private func fetchContacts() {
        let mapping: TPCFetchContactsMapping = { fullName, phoneNumbers in
            let contact = TPCMobileContact(fullName: fullName, phonesArray: phoneNumbers)
            self.contacts.append(contact)
        }
        loading = true
        if #available(iOS 9.0, *) {
            fetchContactsFromContactStoreWithMapping(mapping)
        } else {
            fetchContactsFromAddressBookWithMapping(mapping)
        }
        loading = false
    }
    
    private func requestAccessSyncWithHandler(handler: (accessGranted: UnsafeMutablePointer<Bool>, semaphore: dispatch_semaphore_t) -> Void) -> Bool {
        var accessGranted = false
        let semaphore = dispatch_semaphore_create(0)
        handler(accessGranted: &accessGranted, semaphore: semaphore)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return accessGranted
    }
}

typealias TPCFetchContactsMapping = ((fullName: String, phoneNumbers: [String]) -> Void)
typealias TPCContactManagerAddressBook = TPCContactManager
extension TPCContactManagerAddressBook {
    private func fetchContactsFromAddressBookWithMapping(mapping: TPCFetchContactsMapping) {
        let addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        if !requestAccessWithAddressBook(addressBook) {
            let authStatus = ABAddressBookGetAuthorizationStatus()
            guard authStatus != .Denied && authStatus != .Restricted else {
                return
            }
        }
        let peoples = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [CFTypeRef]
        for peopleValue in peoples {
            let people: ABRecordRef = peopleValue
            let fullName = fullNameForPeople(people)
            let phoneNumbers = phonesForPeople(people)
            mapping(fullName: fullName, phoneNumbers: phoneNumbers)
        }
    }
    
    private func requestAccessWithAddressBook(addressBook: ABAddressBookRef) -> Bool {
        return requestAccessSyncWithHandler { (accessGranted, semaphore) in
            ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) in
                accessGranted.memory = granted
                dispatch_semaphore_signal(semaphore)
            })
        }
    }

    private func fullNameForPeople(people: ABRecordRef) -> String {
        let fullNameRef = ABRecordCopyCompositeName(people).takeRetainedValue()
        let fullName = fullNameRef as String
        return fullName.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    private func phonesForPeople(people: ABRecordRef) -> [String] {
        var phoneNumbers = [String]()
        let phonesValue = ABRecordCopyValue(people, kABPersonPhoneProperty).takeRetainedValue()
        let phoneCount = ABMultiValueGetCount(phonesValue)
        for i in 0 ..< phoneCount {
            if let phoneValue = ABMultiValueCopyValueAtIndex(phonesValue, i).takeRetainedValue() as? String {
                if let phone = phoneValue.normalizeMobileNumber() {
                    if phone.characters.count > 0 {
                        phoneNumbers.append(phone)
                    }
                }
            }
        }
        return phoneNumbers
    }
}

typealias TPCContactManagerContactStore = TPCContactManager
@available(iOS 9.0, *)
extension TPCContactManagerContactStore {
    private func fetchContactsFromContactStoreWithMapping(mapping: TPCFetchContactsMapping) {
        let contactStore = CNContactStore()
        if !requestAccessWithContactStore(contactStore) {
            let authStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
            guard authStatus != .Denied && authStatus != .Restricted else {
                return
            }
        }
        do {
            let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactFamilyNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactGivenNameKey])
            try contactStore.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) in
                let phoneNumbers = contact.phoneNumbers
                    .map{ ($0.value as? CNPhoneNumber).flatMap{ $0.stringValue.normalizeMobileNumber() } }
                    .flatMap{ $0 }
                let fullName = contact.givenName + contact.familyName
                mapping(fullName: fullName, phoneNumbers: phoneNumbers)
            }
        } catch let error {
            print("enumerate contacts failed with error: \(error)")
        }
    }
    
    private func requestAccessWithContactStore(contactStore: CNContactStore) -> Bool {
        return requestAccessSyncWithHandler { (accessGranted, semaphore) in
            contactStore.requestAccessForEntityType(.Contacts) { (granted, error) in
                accessGranted.memory = granted
                dispatch_semaphore_signal(semaphore)
            }
        }
    }
}


