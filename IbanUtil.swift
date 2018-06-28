//
//  IbanUtil.swift
//  Jax
//
//  Created by wangjh on 2018/6/25.
//  Copyright © 2018年 Flozy. All rights reserved.
//

import UIKit
import BigInt

class IbanUtil {
    static let DEFAULT_CHECK_DIGIT = "00"
    static let DEFAULT_ETH_COUNTRY_NUMBER = "XE"
    
    private static let MOD = 97
    private static let MAX = 999999999
    private static let COUNTRY_CODE_INDEX = 0
    private static let COUNTRY_CODE_LENGTH = 2
    private static let CHECK_DIGIT_INDEX = COUNTRY_CODE_LENGTH
    private static let CHECK_DIGIT_LENGTH = 2
    private static let BBAN_INDEX = CHECK_DIGIT_INDEX + CHECK_DIGIT_LENGTH
    
    class func toIban(address: String) -> String? {
        let bban = convertHexToBase36(hex: address).uppercased()
        let iban = DEFAULT_ETH_COUNTRY_NUMBER + DEFAULT_CHECK_DIGIT + bban
        return replaceCheckDigit(iban: iban, checkDigit: calculateCheckDigit(iban: iban))
    }
    
    class func fromIban(iban: String) -> String? {
        if (iban.count != 34 && iban.count != 35) {
            return nil
        }
        let checkSum = calculateCheckDigit(iban: iban)
        if (getCheckDigit(iban: iban) == checkSum) {
            let bban = getBban(iban: iban)
            var address = convertBase36ToHex(b36: bban)
    
            // 38位地址是 Basic 模式iban，要填充00才是真正的地址
            if (address.count == 38) {
                address = "00" + address
            }
            return address
        }
        return nil
    }
    
    class func convertHexToBase36(hex: String) -> String {
        var hexNumber = hex
        if hex.hasPrefix("0x") {
            hexNumber = String(hexNumber.dropFirst(2))
        }
        guard let big = BigInt(hex, radix: 16) else { return "" }
        let base36 = String(big, radix: 36)
        return base36
    }
    
    class func convertBase36ToHex(b36: String) -> String {
        guard let big = BigInt(b36, radix: 36) else { return "" }
        let hex = String(big, radix: 16)
        return hex
    }
 
    class func getCheckDigit(iban: String) -> String {
        let start = iban.index(iban.startIndex, offsetBy: CHECK_DIGIT_INDEX)
        let end = iban.index(iban.startIndex, offsetBy: CHECK_DIGIT_INDEX + CHECK_DIGIT_LENGTH)
        let subStr = iban[start..<end]
        return String(subStr)
    }
    
    class func getCountryCode(iban: String) -> String {
        let start = iban.index(iban.startIndex, offsetBy: COUNTRY_CODE_INDEX)
        let end = iban.index(iban.startIndex, offsetBy: COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH)
        let subStr = iban[start..<end]
        return String(subStr)
    }

    class func getCountryCodeAndCheckDigit(iban: String) -> String{
        let start = iban.index(iban.startIndex, offsetBy: COUNTRY_CODE_INDEX)
        let end = iban.index(iban.startIndex, offsetBy: COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH + CHECK_DIGIT_LENGTH)
        let subStr = iban[start..<end]
        let str = String(subStr)
        return str
    }
    
    class func getBban(iban: String) -> String {
        let start = iban.index(iban.startIndex, offsetBy: BBAN_INDEX)
        let subStr = iban.suffix(from: start)
        let str = String(subStr)
        return str
    }
    
    class func calculateCheckDigit(iban: String) -> String {
        let reformattedIban = replaceCheckDigit(iban: iban, checkDigit: DEFAULT_CHECK_DIGIT)
        let modResult = calculateMod(iban: reformattedIban)
        let checkDigitIntValue = (98 - modResult)
        let checkDigit = "\(checkDigitIntValue)"
        return checkDigitIntValue > 9 ? checkDigit : "0" + checkDigit
    }
    
    class func replaceCheckDigit(iban: String, checkDigit: String) -> String {
        return getCountryCode(iban: iban) + checkDigit + getBban(iban: iban)
    }

    class func calculateMod(iban: String) -> Int {
        let reformattedIban = getBban(iban: iban) + getCountryCodeAndCheckDigit(iban: iban)
        var total = 0
        for c in reformattedIban {
            guard let numericValue = c.unicodeScalars.first?.value else {
                FZlog.error("error calculateMod : \(c)")
                return 0
            }
            var value = numericValue - 48
            value = value > 9 ? value - 7 : value
            total = (Int(value) > 9 ? total * 100 : total * 10) + Int(value)
            if (total > MAX) {
                total = (total % MOD)
            }
        }
        return total % MOD
    }
}
