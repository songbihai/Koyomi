//
//  ViewController.swift
//  Example
//
//  Created by 宋碧海 on 2019/4/4.
//  Copyright © 2019 宋碧海. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var koyomi: Koyomi!

    @IBOutlet fileprivate weak var currentDateLabel: UILabel!
    
    fileprivate let invalidPeriodLength = 90
    
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Previous", forSegmentAt: 0)
            segmentedControl.setTitle("Next", forSegmentAt: 1)
        }
    }
    
    @IBOutlet weak var yearSegmentControl: UISegmentedControl! {
        didSet {
            yearSegmentControl.setTitle("Previous", forSegmentAt: 0)
            yearSegmentControl.setTitle("Next", forSegmentAt: 1)
        }
    }
    
    
    @IBAction func monthChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            koyomi.display(in: .previous)
        }else if sender.selectedSegmentIndex == 1 {
            koyomi.display(in: .next)
        }
        
    }
    
    
    @IBAction func yearChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            koyomi.display(of: .previous)
        }else if sender.selectedSegmentIndex == 1 {
            koyomi.display(of: .next)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            koyomi.calendarType = .chinaese
        }else {
            koyomi.calendarType = .gregorian
        }
        currentDateLabel.text = koyomi.currentDateString()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 10, y : 140, width: UIScreen.main.bounds.width-20, height: 300)
        koyomi = Koyomi(frame: frame, calendarType: .chinaese, sectionSpace: 1, cellSpace: 1, inset: .zero, weekCellHeight: 40)
        view.addSubview(koyomi)
        koyomi.circularViewDiameter = 0.6
        koyomi.calendarDelegate = self
        koyomi.inset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        koyomi.weeks = ("周日", "周一", "周二", "周三", "周四", "周五", "周六")
        koyomi.style = .standard
        koyomi.dayPosition = .center
        koyomi.selectionMode = .single(style: .circle)
        koyomi
            .setDayFont(size: 12)
            .setWeekFont(size: 12)
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

