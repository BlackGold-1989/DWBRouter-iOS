//
//  UserManagerVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class UserManagerVC: UITableViewController {

    var userModelList: [UserModel] = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    func initData() {
        Utils.onShowProgressView(name: "Loading...")
        FireManager.firebaseRef.userManager(add: {(addModel) in
            Utils.onhideProgressView()
            if self.userModelList.count == 0 {
                self.userModelList.append(addModel)
                self.tableView.reloadData()
                return
            }
            
            var isContainAvailable = true
            for model in self.userModelList {
                if model.id == addModel.id {
                    isContainAvailable = false
                    break
                }
            }
            if isContainAvailable {
                self.userModelList.append(addModel)
            }
            self.tableView.reloadData()
        }, edit: {(editModel) in
            Utils.onhideProgressView()
            for model in self.userModelList {
                if model.id == editModel.id {
                    model.name = editModel.name
                    model.regdate = editModel.regdate
                    model.phone = editModel.phone
                    model.address = editModel.address
                    model.type = editModel.type
                }
            }
            self.tableView.reloadData()
        }, remove: {(removeModel) in
            Utils.onhideProgressView()
            for i in 0..<self.userModelList.count {
                if self.userModelList[i].id == removeModel.id {
                    self.userModelList.remove(at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userModelList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.initCell(userModel: userModelList[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension UserManagerVC: UserCellDelegate {
    func didSelectEditDelegate(model: UserModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "UserDetailVC") as! UserDetailVC
        vc.userInfo = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
