//
//  BBViewController.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class BBViewController: UIViewController {

    public var handler: ((LsqCalendarView.LsqCalendarDate,Bool)->Swift.Void)?
    
    public var startDate: Int?
    public var endDate: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.purple
        let rect = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 400 * LsqScale375)
        let v = LsqCalendarView(frame: rect, startDate: self.startDate, endDate: self.endDate, limitMonth: 12 * 50)
        v.dateHandler = { [weak self](date,isok) in
            print(date,isok)
            if isok {
                self?.handler?(date,isok)
                self?.navigationController?.popViewController(animated: true)
            }
            
        }
        self.view.addSubview(v)
        
    }
 
}



extension UIFont {
    
    enum FontType: String {
        case thin       = "PingFangSC-Thin"
        case light      = "PingFangSC-Light"
        case regular    = "PingFangSC-Regular"
        case medium     = "PingFangSC-Medium"
        case bold       = "PingFangSC-Bold"
        case heavy      = "PingFangSC-Heavy"
        case black      = "PingFangSC-Black"
    }
    
    class func auto(font: CGFloat, type: FontType) -> UIFont? {
        var fontSize: CGFloat = font
        fontSize *= LsqScale375
        return UIFont(name: type.rawValue, size: fontSize)
    }
    
    class func auto(font: CGFloat) -> UIFont {
        var fontSize: CGFloat = font
        fontSize *= LsqScale375
        return UIFont.systemFont(ofSize: fontSize)
    }
    class func boldAuto(font: CGFloat) -> UIFont {
        var fontSize: CGFloat = font
        fontSize *= LsqScale375
        return UIFont.boldSystemFont(ofSize: fontSize)
    }
}

extension Date {
    //转字符串格式
    func toString(type: TimeFormat) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = type.rawValue
        let dateStr = dateFormat.string(from: self)
        return dateStr
    }
}
//时间戳转换
enum TimeFormat: String {
    //y表示年份，m表示月份，d表示日，h表示小时，m表示分钟，s表示秒
    case yyyy_MM_dd_HH_mm_ss    = "yyyy-MM-dd HH:mm:ss"
    case yyyy_MM_dd_HH_mm       = "yyyy-MM-dd HH:mm"
    case yyyy_MM_dd_HH          = "yyyy-MM-dd HH"
    case yyyy_MM_dd             = "yyyy-MM-dd"
    case yyyyMMdd               = "yyyy.MM.dd"
    case yyyyMM                 = "yyyy.MM"
    case yyyy_MM                = "yyyy-MM"
    case HH_mm                  = "HH:mm"
    case HH_mm_ss               = "HH:mm:ss"
    case yyyy                   = "yyyy"
    case MM_dd                  = "MM-dd"
    case MM                     = "MM"
    
    case yNmY                   = "yyyy年MM月"
}

//MARK:UIColor扩展
extension UIColor {
    //16进制颜色
    public class func hexColor(with string:String) -> UIColor? {
        var cString = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.count < 6 {
            return nil
        }
        if cString.hasPrefix("0X") {
            let index = cString.index(cString.startIndex, offsetBy: 2)
            cString = String(cString[index...])
        }
        if cString .hasPrefix("#") {
            let index = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString[index...])
        }
        if cString.count != 6 {
            return nil
        }
        
        let rrange = cString.startIndex..<cString.index(cString.startIndex, offsetBy: 2)
        let rString = String(cString[rrange])
        let grange = cString.index(cString.startIndex, offsetBy: 2)..<cString.index(cString.startIndex, offsetBy: 4)
        let gString = String(cString[grange])
        let brange = cString.index(cString.startIndex, offsetBy: 4)..<cString.index(cString.startIndex, offsetBy: 6)
        let bString = String(cString[brange])
        var r:CUnsignedInt = 0 ,g:CUnsignedInt = 0 ,b:CUnsignedInt = 0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
}


extension UIView {
    
    //获取视图的控制器
    public var viewController: UIViewController? {
        var next: UIResponder?
        next = self.next
        repeat {
            if (next as? UIViewController) != nil {
                return (next as? UIViewController)
            } else {
                next = next?.next
            }
        } while next != nil
        return (next as? UIViewController)
    }
    //位置
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: newValue)
        }
    }
    public var width: CGFloat{
        get {
            return self.frame.size.width
        }
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue, height: self.frame.height)
        }
    }
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.height
        }
        set {
            let y = newValue - self.frame.height
            self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.width
        }
        set {
            let x = newValue - self.frame.width
            self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
    }
    public func setBorder(width: CGFloat, color: UIColor, top: Bool, right: Bool, bottom: Bool, left: Bool) {
        if top {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
            layer.backgroundColor = color.cgColor
            self.layer.addSublayer(layer)
        }
        if right {
            let layer = CALayer()
            layer.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
            layer.backgroundColor = color.cgColor
            self.layer.addSublayer(layer)
        }
        if bottom {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: self.frame.height - width, height: width)
            layer.backgroundColor = color.cgColor
            self.layer.addSublayer(layer)
        }
        if left {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            layer.backgroundColor = color.cgColor
            self.layer.addSublayer(layer)
        }
    }
    @discardableResult
    public func setRoundBorder(rect: CGRect? = nil, rectCorners: UIRectCorner, cornerRadii: CGSize) -> CAShapeLayer{
        
        let bds = rect == nil ? self.bounds : rect!
        let mask = UIBezierPath(roundedRect: bds, byRoundingCorners: rectCorners, cornerRadii: cornerRadii)
        let shape = CAShapeLayer()
        shape.path = mask.cgPath
        shape.frame = bds
        self.layer.mask = shape
        return shape
    }
    
    public func setRoundBorder(rectCorners: UIRectCorner,fillColor: UIColor?, strokeColor: UIColor?){
        
        let mask = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorners, cornerRadii: CGSize(width: 4, height: 4))
        mask.lineWidth = 0.5
        let shape = CAShapeLayer()
        shape.fillColor = fillColor?.cgColor
        shape.strokeColor = strokeColor?.cgColor
        shape.path = mask.cgPath
        shape.frame = self.bounds
        self.layer.addSublayer(shape)
    }
    
}

//TODO:延迟异步执行方法
public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
