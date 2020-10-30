//
//  DatePickerVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import FSCalendar

protocol DatePickerVCDelegate {
    func selectedDate(strDate: String)
}

class DatePickerVC: UIViewController {

    @IBOutlet weak var calendarUV: FSCalendar!
    @IBOutlet var contentUV: UIView!
    
    var delegate: DatePickerVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        calendarUV.setShadowToUIView(radius: 8.0, type: .MEDIUM)
        calendarUV.delegate = self
        
        
        let contentGesture = UITapGestureRecognizer(target: self, action: #selector(onTapContentUV(sender:)))
        contentGesture.delegate = self
        contentUV.addGestureRecognizer(contentGesture)
    }
    
    @objc func onTapContentUV(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DatePickerVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: calendarUV))! {
            return false
        }
        return true
    }
}

extension DatePickerVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let strDate = Utils.covertDateToString(dateFormat: "dd-MM-yyyy", date:date)
        self.delegate?.selectedDate(strDate: strDate)
        self.dismiss(animated: true, completion: nil)
    }
}
