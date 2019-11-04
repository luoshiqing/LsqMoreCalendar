//
//  ViewController.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let btn = UIButton(frame: CGRect(x: 0, y: 200, width: 100, height: 50))
        btn.center.x = self.view.width / 2
        btn.setTitle("下一个", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.titleLabel?.font = UIFont.auto(font: 15)
        btn.addTarget(self, action: #selector(self.btnAct), for: .touchUpInside)
        self.view.addSubview(btn)
        
        
    }
    
    private var selectDate: LsqCalendarView.LsqCalendarDate?

    @objc private func btnAct() {
        let bb = BBViewController()
        bb.handler = { [weak self] (date,isok) in
            self?.selectDate = date
        }
        bb.startDate = self.selectDate?.start
        bb.endDate = self.selectDate?.end
        self.navigationController?.pushViewController(bb, animated: true)
    }

}

