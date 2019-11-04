//
//  LsqCalendarView.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

public let LsqScreenWidth = UIScreen.main.bounds.width
public let LsqScreenHeight = UIScreen.main.bounds.height
public let LsqScale375 = LsqScreenWidth / 375

enum LsqCalendarSelectType {
    
    case start//已选中开始时间
    case end//已选中结束时间，必须先选定开始时间
}

class LsqCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    public typealias LsqCalendarDate = (start: Int?, end: Int?)
    //true为点击确定，false为选中时间回调
    public var dateHandler: ((LsqCalendarDate,Bool)->Swift.Void)?
    
    private var showChineseHoliday : Bool = true
    private var showChineseCalendar: Bool = true
    private var startDate: Int?//选中的开始时间
    private var endDate: Int?//选中的结束时间
    private var type: LsqSenctionScalendarType = .middle
    private var limitMonth: Int = 12 // 可选择的月份数量
    
    private var dataArray = [LsqSectionCalendarHeaderModel]()
    
    private var myCollectionView: UICollectionView!
    
    private var headView: LsqCalendarHeadView!
    
    //记录当前选中日期状态
    private var selectType: LsqCalendarSelectType = .start
    
    init(frame: CGRect, showChineseHoliday: Bool = true, showChineseCalendar: Bool = true, startDate: Int? = nil, endDate: Int? = nil, type: LsqSenctionScalendarType = .past, limitMonth: Int = 12 * 1) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.showChineseHoliday = showChineseHoliday
        self.showChineseCalendar = showChineseCalendar
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.limitMonth = limitMonth
        
        if let _ = startDate {
            if let _ = endDate {
                self.selectType = .start
            }else{
                self.selectType = .end
            }
        }else{
            self.selectType = .start
        }
 
        self.loadSomeView()
        
        let d1 = Date().timeIntervalSince1970 * 1000
        print("开始时间:",d1)
        self.initDataSource { [weak self] (datas,manager) in
            let d2 = Date().timeIntervalSince1970 * 1000
            print("完成时间:",d2)
            print("生成日历数据总时间:",d2 - d1)
            self?.dataArray = datas
            
            self?.showStartIndexPath(manager.startIndexpath)
        }
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSomeView() {
        
        headView = LsqCalendarHeadView(frame: CGRect(x: 0, y: 0, width: self.width, height: 90 * LsqScale375))
        headView.dateSelectHandler = { [weak self](index) in
            self?.selectMonth(index)
        }
        switch self.type {
        case .past:
            self.headView.leftEnable = true
            self.headView.rightEnable = false
        case .middle:
            self.headView.leftEnable = true
            self.headView.rightEnable = true
        case .future:
            self.headView.leftEnable = false
            self.headView.rightEnable = true
        }
        self.addSubview(headView)
        

        let bottomV = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 85 * LsqScale375))
        bottomV.backgroundColor = UIColor.white
        bottomV.bottom = self.height
        self.addSubview(bottomV)
        
        let space: CGFloat = 25 * LsqScale375
        let oneW = (bottomV.width - space * 3) / 2
        let restBtn = UIButton(frame: CGRect(x: space, y: space, width: oneW, height: 35 * LsqScale375))
        restBtn.setTitle("重置", for: .normal)
        restBtn.setTitleColor(UIColor.hexColor(with: "#2196F3"), for: .normal)
        restBtn.titleLabel?.font = UIFont.auto(font: 16)
        restBtn.tag = -1
        restBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        restBtn.layer.cornerRadius = restBtn.height / 2
        restBtn.layer.masksToBounds = true
        restBtn.layer.borderWidth = 1
        restBtn.layer.borderColor = UIColor.hexColor(with: "#2196F3")?.cgColor
        bottomV.addSubview(restBtn)
        
        let okBtn = UIButton(frame: CGRect(x: restBtn.right + space, y: space, width: oneW, height: 35 * LsqScale375))
        okBtn.setTitle("确定", for: .normal)
        okBtn.setTitleColor(UIColor.white, for: .normal)
        okBtn.backgroundColor = UIColor.hexColor(with: "#2196F3")
        okBtn.titleLabel?.font = UIFont.auto(font: 16)
        okBtn.tag = 1
        okBtn.addTarget(self, action: #selector(self.someBtnAct(_:)), for: .touchUpInside)
        okBtn.layer.cornerRadius = okBtn.height / 2
        okBtn.layer.masksToBounds = true
        bottomV.addSubview(okBtn)
        
        
        let allH = bottomV.top - headView.bottom
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.width, height: allH)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0 //上下间隔
        layout.minimumInteritemSpacing = 0 //左右间隔
        layout.headerReferenceSize = CGSize(width: 0, height: 0) //头部间距
        layout.footerReferenceSize = CGSize(width: 0, height: 0) //尾部间距
        layout.sectionInset.left = 0
        layout.sectionInset.right = 0
        
        
        let rect = CGRect(x: 0, y: headView.bottom, width: self.frame.width, height: allH)
        myCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        myCollectionView?.backgroundColor = UIColor.white
        myCollectionView?.delegate = self
        myCollectionView?.dataSource = self
        myCollectionView.isPagingEnabled = true
        myCollectionView.bounces = false
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.showsVerticalScrollIndicator = false
        self.addSubview(myCollectionView!)
        
        myCollectionView.register(LsqMonthCell.self, forCellWithReuseIdentifier: "LsqMonthCell")
    }
    @objc private func someBtnAct(_ send: UIButton) {
        let tag = send.tag
        
        if tag == -1{//重置
            self.startDate = nil
            self.endDate = nil
            let date: LsqCalendarDate = (start: nil, end: nil)
            self.dateHandler?(date,false)
            self.myCollectionView.reloadData()
        }else if tag == 1 {//确定
            
            guard let start = self.startDate else {
                print("请选择开始时间")
                return
            }
            guard let end = self.endDate else {
                print("请选择结束时间")
                return
            }
            let date: LsqCalendarDate = (start: start, end: end)
            self.dateHandler?(date,true)
        }
    }
    //设置月份
    private func selectMonth(_ index: Int) {
        //-1上月,1下月
        let page = Int(self.myCollectionView.contentOffset.x / self.myCollectionView.width)
        
        if index == -1 {
            let endPage = page - 1
            if endPage >= 0 {
                self.headView.dateStr = self.dataArray[endPage].headerText
                self.setLeftRightEnable(with: endPage)
                self.myCollectionView.scrollToItem(at: IndexPath(item: endPage, section: 0), at: .left, animated: true)
            }
        }else{
            let endPage = page + 1
            if endPage < self.dataArray.count {
                self.headView.dateStr = self.dataArray[endPage].headerText
                self.setLeftRightEnable(with: endPage)
                self.myCollectionView.scrollToItem(at: IndexPath(item: endPage, section: 0), at: .right, animated: true)
            }
        }
        
    }
    
    func initDataSource(handler: (([LsqSectionCalendarHeaderModel],LsqCalendarManager)->Swift.Void)?) {
        DispatchQueue.global().async {
            let manager = LsqCalendarManager(showChineseHoliday: self.showChineseHoliday, showChineseCalendar: self.showChineseCalendar, startDate: self.startDate ?? 0)
            let tempDataArray = manager.getCalendarDataSoruce(limitMonth: self.limitMonth, type: self.type)
            
            DispatchQueue.main.async {
                handler?(tempDataArray,manager)
            }
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LsqMonthCell", for: indexPath) as! LsqMonthCell
        let dts = self.dataArray[indexPath.row].calendarItemArray
        cell.setDatas(dts, startDate: self.startDate, endDate: self.endDate)
        cell.dateTouchHandler = { [weak self] (model,row) in
            self?.dealTouch(model: model)
        }
        
        return cell
    }
    
    
    private func dealTouch(model: LsqSectionCalendarModel) {
        switch self.selectType {
        case .start:
            self.selectType = .end
            self.endDate = nil
            self.startDate = model.dateInterval
        case .end:
            self.selectType = .start
            guard let start = self.startDate else {return}
            guard let current = model.dateInterval else {return}
            
            if current >= start {
                self.endDate = current
            }else{
                self.endDate = self.startDate
                self.startDate = current
            }
        }
        let date: LsqCalendarDate = (start: self.startDate, end: self.endDate)
        self.dateHandler?(date,false)
        self.myCollectionView.reloadData()
    }
    
  
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / scrollView.frame.width)
        if index < 0 || index >= self.dataArray.count {
            return
        }
        let model = self.dataArray[index]
        self.headView.dateStr = model.headerText
        
        self.setLeftRightEnable(with: index)
    }
    
    private func setLeftRightEnable(with index: Int) {
        if index == 0 {
            self.headView.rightEnable = true
            self.headView.leftEnable = false
        } else if index == self.dataArray.count - 1 {
            self.headView.rightEnable = false
            self.headView.leftEnable = true
        } else {
            self.headView.rightEnable = true
            self.headView.leftEnable = true
        }
    }
    
    
    private func showStartIndexPath(_ indexPath: IndexPath) {
        
        if self.dataArray.isEmpty {
            return
        }
        switch self.type {
        case .past:
            let row = self.dataArray.count - 1
            self.myCollectionView.reloadData()
            let offsetX = self.myCollectionView.width * CGFloat(row)
            self.myCollectionView.contentOffset.x = offsetX
        case .middle:
            
            self.myCollectionView.reloadData()
            let row = (self.dataArray.count - 1) / 2
            let offsetX = self.myCollectionView.width * CGFloat(row)
            self.myCollectionView.contentOffset.x = offsetX
        case .future:
            self.myCollectionView.reloadData()
            let offsetX = self.myCollectionView.width * CGFloat(0)
            self.myCollectionView.contentOffset.x = offsetX
        }
        
    }
 
}
class LsqMonthCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var dateTouchHandler: ((LsqSectionCalendarModel,Int)->Swift.Void)?
    
    private var dataArray = [LsqSectionCalendarModel]()
    private var startDate: Int?
    private var endDate: Int?
    
    public func setDatas(_ datas: [LsqSectionCalendarModel], startDate: Int?, endDate: Int?) {
        self.dataArray = datas
        self.startDate = startDate
        self.endDate = endDate
        self.layout.itemSize.height = self.getItemHeight(count: self.dataArray.count)
        self.myCollectionView.collectionViewLayout = layout
        self.myCollectionView.reloadData()
        
    }
    
    private var myCollectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.loadSomeView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSomeView() {
  
        let oneW = CGFloat(Int(50 * LsqScale375))
        
        let sy = self.width - oneW * 7
        let left = CGFloat(Int(sy / 2))
        let right = sy - left
        
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: oneW, height: 20)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0 //上下间隔
        layout.minimumInteritemSpacing = 0 //左右间隔
        layout.headerReferenceSize = CGSize(width: 0, height: 0) //头部间距
        layout.footerReferenceSize = CGSize(width: 0, height: 0) //尾部间距
        layout.sectionInset.left = left
        layout.sectionInset.right = right
        
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.height)
        myCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        myCollectionView?.backgroundColor = UIColor.white
        myCollectionView?.delegate = self
        myCollectionView?.dataSource = self
        myCollectionView.isScrollEnabled = false
        myCollectionView.bounces = false
        self.addSubview(myCollectionView!)
        
        myCollectionView.register(LsqCalendarViewCell.self, forCellWithReuseIdentifier: "LsqCalendarViewCell")
    }
    
    private func getItemHeight(count: Int) ->CGFloat {
           let weekCount = 7
           var line = count / weekCount
           if count % weekCount != 0 {
               line += 1
           }
           let h = self.height / CGFloat(line)
           
           return h
       }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LsqCalendarViewCell", for: indexPath) as! LsqCalendarViewCell
        let data = self.dataArray[indexPath.row]
        cell.setData(data, startDate: self.startDate, endDate: self.endDate)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = self.dataArray[indexPath.row]
        if let day = model.day, day != 0 {
            self.dateTouchHandler?(model,indexPath.row)
        }else{
            print("点击无效")
        }
    }

}




class LsqCalendarViewCell: UICollectionViewCell {
    
    private var shapLayer: CAShapeLayer?
    public func setData(_ data: LsqSectionCalendarModel, startDate: Int?, endDate: Int?) {
        
        self.shapLayer?.removeFromSuperlayer()
        self.shapLayer = nil
        
        if let d = data.day, d != 0 {
            self.dataLabel.text = "\(d)"
            self.bgView.isHidden = false
        }else{
            self.dataLabel.text = nil
            self.bgView.isHidden = true
        }
        self.bgView.width = self.width
        self.bgView.height = self.height - 6 * LsqScale375 * 2
        self.bgView.center = CGPoint(x: self.width / 2, y: self.height / 2)
        self.dataLabel.width = self.bgView.width
        self.dataLabel.center.y = self.bgView.height / 2
        
        let current = data.dateInterval ?? 0
        if let start = startDate {
            if let end = endDate {
                if start == end {//单选
                    if current == start {
                        self.bgView.backgroundColor = UIColor.hexColor(with: "#BBDEFB")
                        self.bgView.layer.cornerRadius = 4 * LsqScale375
                    }else{
                        self.bgView.backgroundColor = UIColor.clear
                        self.bgView.layer.cornerRadius = 0
                    }
                }else{//多选
                    
                    if current == start {
                        self.bgView.backgroundColor = UIColor.hexColor(with: "#BBDEFB")
                        self.bgView.layer.cornerRadius = 0
                        self.shapLayer = self.bgView.setRoundBorder(rectCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 4 * LsqScale375, height: 4 * LsqScale375))
                    }else if current == end {
                        self.bgView.backgroundColor = UIColor.hexColor(with: "#BBDEFB")
                        self.shapLayer = self.bgView.setRoundBorder(rectCorners: [.topRight,.bottomRight], cornerRadii: CGSize(width: 4 * LsqScale375, height: 4 * LsqScale375))
                        self.bgView.layer.cornerRadius = 0
                    }else if current < start || current > end {//未选中部分
                        self.bgView.backgroundColor = UIColor.clear
                        self.bgView.layer.cornerRadius = 0
                    }else{//中间部分
                        self.bgView.backgroundColor = UIColor.hexColor(with: "#BBDEFB")
                        self.bgView.layer.cornerRadius = 0
                    }
                }
            }else{//单选
                if current == start {
                    self.bgView.backgroundColor = UIColor.hexColor(with: "#BBDEFB")
                    self.bgView.layer.cornerRadius = 4 * LsqScale375
                }else{
                    self.bgView.backgroundColor = UIColor.clear
                    self.bgView.layer.cornerRadius = 0
                }
            }
        }else{
            self.bgView.backgroundColor = UIColor.clear
            self.bgView.layer.cornerRadius = 0
        }
        
    }
    
    private var bgView: UIView!
    private var dataLabel : UILabel!
    private var subLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.loadSomeView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSomeView() {
        bgView = UIView(frame: CGRect(x: 0, y: 6 * LsqScale375, width: self.width, height: self.height - 6 * LsqScale375 * 2))
        bgView.center.y = self.height / 2
        self.addSubview(bgView)
        
        
        dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bgView.width, height: 23 * LsqScale375))
        dataLabel.text = "12"
        dataLabel.center.y = bgView.height / 2
        dataLabel.textColor = UIColor.hexColor(with: "#202D3C")
        dataLabel.font = UIFont.auto(font: 16)
        dataLabel.textAlignment = .center
//        dataLabel.backgroundColor = UIColor.red
        bgView.addSubview(dataLabel)
        
        subLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bgView.width, height: 23 * LsqScale375))
        subLabel.text = "12"
        subLabel.textColor = UIColor.hexColor(with: "#202D3C")
        subLabel.font = UIFont.auto(font: 16)
        subLabel.textAlignment = .center
        subLabel.isHidden = true
        bgView.addSubview(subLabel)
        
    }
    
    
}
