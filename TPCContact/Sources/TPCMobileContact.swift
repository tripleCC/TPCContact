//
//  TPCMobileContact.swift
//  TPCContact
//
//  Created by tripleCC on 16/3/31.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public class TPCMobileContact: NSObject, NSCoding {
    struct TPCMobileContactStatic {
        static let TPCMobileContactStaticFullNameKey = "TPCMobileContactStaticFullNameKey"
        static let TPCMobileContactStaticPhonesArrayKey = "TPCMobileContactStaticPhonesArrayKey"
    }
    var fullName: String?
    var phonesArray: [String]?
    
    init(fullName: String?, phonesArray:[String]? = nil) {
        self.fullName = fullName
        self.phonesArray = phonesArray
        super.init()
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        let fullName = aDecoder.decodeObjectForKey(TPCMobileContactStatic.TPCMobileContactStaticFullNameKey).stringValue()
        let phonesArray: [String] = aDecoder.decodeObjectForKey(TPCMobileContactStatic.TPCMobileContactStaticPhonesArrayKey).arrayValue()
        self.init(fullName: fullName, phonesArray: phonesArray)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(fullName)
        aCoder.encodeObject(phonesArray)
    }
}

extension TPCMobileContact {
    func createNewByDifferencePartReferToContact(contact: TPCMobileContact) -> TPCMobileContact? {
        guard self != contact else { return nil }
        let newContact = TPCMobileContact(fullName: contact.fullName)
        if let phonesArray = phonesArray {
            var differencePhones = [String]()
            for phone in phonesArray {
                if contact.phonesArray?.contains(phone) != true {
                    differencePhones.append(phone)
                }
            }
            newContact.phonesArray = differencePhones
        } else {
            newContact.phonesArray = contact.phonesArray
        }
        return contact
    }
}

func ==(lhs: TPCMobileContact, rhs: TPCMobileContact) -> Bool {
    guard lhs.fullName == lhs.fullName else { return false }
    if let lphonesArray = lhs.phonesArray {
        if let rphonesArray = rhs.phonesArray {
            return lphonesArray == rphonesArray
        } else { return false }
    } else {
        return rhs.phonesArray == nil
    }
}




