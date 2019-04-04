//
//  ViewController.swift
//  Example
//
//  Created by 宋碧海 on 2019/4/4.
//  Copyright © 2019 宋碧海. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet fileprivate weak var currentDateLabel: UILabel!
    
    fileprivate let invalidPeriodLength = 90
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Previous", forSegmentAt: 0)
            segmentedControl.setTitle("Current", forSegmentAt: 1)
            segmentedControl.setTitle("Next", forSegmentAt: 2)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 10, y : 140, width: UIScreen.main.bounds.width-20, height: 300)
        let koyomi = Koyomi(frame: frame, calendarType: .gregorian, sectionSpace: 1, cellSpace: 1, inset: .zero, weekCellHeight: 40)
        view.addSubview(koyomi)
        koyomi.circularViewDiameter = 0.2
        koyomi.calendarDelegate = self
        koyomi.inset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        koyomi.weeks = ("周日", "周一", "周二", "周三", "周四", "周五", "周六")
        koyomi.style = .standard
        koyomi.dayPosition = .center
        koyomi.selectionMode = .sequence(style: .semicircleEdge)
        koyomi.selectedStyleColor = UIColor(red: 203/255, green: 119/255, blue: 223/255, alpha: 1)
        koyomi
            .setDayFont(size: 14)
            .setWeekFont(size: 10)
        currentDateLabel.text = koyomi.currentDateString()
    }
    
    // MARK: - Utility -
    
    fileprivate func date(_ date: Date, later: Int) -> Date {
        var components = DateComponents()
        components.day = later
        return (Calendar.current as NSCalendar).date(byAdding: components, to: date, options: NSCalendar.Options(rawValue: 0)) ?? date
    }
}

// MARK: - KoyomiDelegate -

extension ViewController: KoyomiDelegate {
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {
        print("You Selected: \(String(describing: date))")
    }
    
    func koyomi(_ koyomi: Koyomi, currentDateString dateString: String) {
        currentDateLabel.text = dateString
    }
    
    @objc(koyomi:shouldSelectDates:to:withPeriodLength:)
    func koyomi(_ koyomi: Koyomi, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool {
        if length > invalidPeriodLength {
            print("More than \(invalidPeriodLength) days are invalid period.")
            return false
        }
        return true
    }
}

