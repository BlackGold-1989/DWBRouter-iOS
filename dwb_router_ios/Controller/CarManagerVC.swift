//
//  CarManagerVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class CarManagerVC: UITableViewController {

    var carModelList: [CarServiceModel] = [CarServiceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    func initData() {
        Utils.onShowProgressView(name: "Loading...")
        FireManager.firebaseRef.carManager(add: {(addModel) in
            Utils.onhideProgressView()
            if self.carModelList.count == 0 {
                self.carModelList.append(addModel)
                self.tableView.reloadData()
                return
            }
            
            var isContainAvailable = true
            for model in self.carModelList {
                if model.id == addModel.id {
                    isContainAvailable = false
                    break
                }
            }
            if isContainAvailable {
                self.carModelList.append(addModel)
            }
            self.tableView.reloadData()
        }, edit: {(editModel) in
            Utils.onhideProgressView()
            for model in self.carModelList {
                if model.id == editModel.id {
                    model.name = editModel.name
                    model.regdate = editModel.regdate
                }
            }
            self.tableView.reloadData()
        }, remove: {(removeModel) in
            Utils.onhideProgressView()
            for i in 0..<self.carModelList.count {
                if self.carModelList[i].id == removeModel.id {
                    self.carModelList.remove(at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carModelList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        cell.initCell(carModel: carModelList[indexPath.row])
        return cell
    }
}
