//
//  LsqCalendarHeadView.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/2.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class LsqCalendarHeadView: UIView {
    //-1上月,1下月
    public var dateSelectHandler: ((Int)->Swift.Void)?
    
    public var dateStr: String? {
        didSet {
            self.dateLabel.text = self.dateStr
            
            dateLabel.sizeToFit()
            dateLabel.center.x = self.frame.width / 2
            dateLabel.height = 20 * LsqScale375
            dateLabel.top = 15 * LsqScale375
            
            lastBtn.right = dateLabel.left
            lastBtn.center.y = dateLabel.center.y
            
            nextBtn.left = dateLabel.right
            nextBtn.center.y = dateLabel.center.y
        }
    }
    
    private var lastBtn: UIButton!
    private var nextBtn: UIButton!
    private var dateLabel: UILabel!
    
    private let weekArray = ["日","一","二","三","四","五","六"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.loadSomeView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var leftEnable: Bool = true {
        didSet {
            if self.leftEnable {
                lastBtn.setImage(UIImage(named: "向左_黑"), for: .normal)
            }else{
                lastBtn.setImage(UIImage(named: "向左_灰"), for: .normal)
            }
            lastBtn.isEnabled = self.leftEnable
        }
    }
    public var rightEnable: Bool = true {
        didSet {
            if self.rightEnable {
                nextBtn.setImage(UIImage(named: "向右_黑"), for: .normal)
            }else{
                nextBtn.setImage(UIImage(named: "向右_灰"), for: .normal)
            }
            nextBtn.isEnabled = self.rightEnable
        }
    }
    
    private func loadSomeView() {
        dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let dt = Date().toString(type: .yNmY)
        dateLabel.text = dt
        dateLabel.textColor = UIColor.hexColor(with: "#202D3C")
        dateLabel.font = UIFont.auto(font: 14)
        dateLabel.textAlignment = .center
        dateLabel.sizeToFit()
        dateLabel.center.x = self.frame.width / 2
        dateLabel.height = 20 * LsqScale375
        dateLabel.top = 15 * LsqScale375
        self.addSubview(dateLabel)
        
        lastBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 34 * LsqScale375, height: 30 * LsqScale375))
        lastBtn.right = dateLabel.left
        lastBtn.center.y = dateLabel.center.y
        lastBtn.setImage(UIImage(named: "向左_黑"), for: .normal)
        lastBtn.setTitleColor(UIColor.hexColor(with: "#333333"), for: .normal)
        lastBtn.titleLabel?.font = UIFont.auto(font: 14)
        lastBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        lastBtn.tag = -1
        self.addSubview(lastBtn)
        
        nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 34 * LsqScale375, height: 30 * LsqScale375))
        nextBtn.left = dateLabel.right
        nextBtn.center.y = dateLabel.center.y
        nextBtn.setImage(UIImage(named: "向右_黑"), for: .normal)
        nextBtn.setTitleColor(UIColor.hexColor(with: "#333333"), for: .normal)
        nextBtn.titleLabel?.font = UIFont.auto(font: 14)
        nextBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        nextBtn.tag = 1
        self.addSubview(nextBtn)
        
        let weekWidth = CGFloat(Int(50 * LsqScale375))
        let sy = self.width - weekWidth * 7
        let left = CGFloat(Int(sy / 2))
        
        let w = self.width - left - right
        let weekView = UIView(frame: CGRect.init(x: left, y: dateLabel.bottom + 25 * LsqScale375, width: w, height: 17 * LsqScale375))
        weekView.backgroundColor = UIColor.clear
        self.addSubview(weekView)
        for i in 0 ..< 7 {
            let weekLabel = UILabel.init(frame: CGRect.init(x: CGFloat(i) * weekWidth , y: 0, width: weekWidth, height: weekView.height))
            weekLabel.backgroundColor = UIColor.clear
            weekLabel.text = weekArray[i]
            weekLabel.font = UIFont.systemFont(ofSize: 15)
            weekLabel.textAlignment = .center
            weekLabel.textColor = UIColor.hexColor(with: "#202D3C")
            weekView.addSubview(weekLabel)
        }
    }

    @objc private func someBtnAct(_ send: UIButton) {
        let tag = send.tag
        self.dateSelectHandler?(tag)
    }
}
