//
//  MainVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var filterUB: UIButton!
    @IBOutlet weak var roosterUB: UIButton!
    @IBOutlet weak var checkUB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        filterUB.layer.cornerRadius = 8.0
        roosterUB.layer.cornerRadius = 8.0
        checkUB.layer.cornerRadius = 8.0
        
        if Utils.gUser?.type != "owner" {
            checkUB.isHidden = true
        }
        
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initData() {
        FireManager.firebaseRef.getAllUsers(success: {(users) in
            Utils.gUsers.removeAll()
            Utils.gUsers = users
        })
        
        FireManager.firebaseRef.getAllCar(success: {(cars) in
            Utils.gCars.removeAll()
            Utils.gCars = cars
        })
        
        FireManager.firebaseRef.getAllRegion(success: {(regions) in
            Utils.gRegions.removeAll()
            Utils.gRegions = regions
        })
    }

}
