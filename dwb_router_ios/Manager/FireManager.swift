//
//  FireManager.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FireManager {
    static let firebaseRef = FireManager()
    
    let databaseRef: DatabaseReference = Database.database().reference()
    
    func getUserInfo(id: String, success: @escaping ((UserModel) -> Void)) {
        databaseRef.child("user").child(id).observeSingleEvent(of: .value, with: {snapshot
            in
            let value = snapshot.value as? [String: AnyObject]
            let user: UserModel = UserModel()
            user.fromFirebase(data: value!)
            success(user)
        })
    }
    
    func getAllUsers(success: @escaping (([UserModel]) -> Void)) {
        var userModels: [UserModel] = [UserModel]()
        databaseRef.child("user").observeSingleEvent(of: .value, with: {snapshot in
            for snap in snapshot.children {
                let data = snap as! DataSnapshot
                let dict = data.value as! [String: AnyObject]
                let userModel: UserModel = UserModel()
                userModel.fromFirebase(data: dict)
                userModels.append(userModel)
            }
            success(userModels)
        })
    }
    
    func getHistoryInfo(date: String, success: @escaping (([HistoryModel]) -> Void)) {
        var hostories: [HistoryModel] = [HistoryModel]()
        databaseRef.child("history").child(date).observeSingleEvent(of: .value, with: {snapshot in
            for snap in snapshot.children {
                let post = snap as! DataSnapshot
                for postshot in post.children {
                    let postData = postshot as! DataSnapshot
                    let dict = postData.value as! [String: AnyObject]
                    let history: HistoryModel = HistoryModel()
                    history.fromFirebase(data: dict)
                    hostories.append(history)
                }
            }
            success(hostories)
        })
    }
    
    func setHistoryInfo(model: HistoryModel, success: @escaping ((String) -> Void)) {
        let key = databaseRef.child("history").child(model.date).child(model.id).childByAutoId().key
        model.key = key!
        databaseRef.child("history").child(model.date).child(model.id).child(key!).setValue(model.toFireBase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func updateHistoryInfo(model: HistoryModel, success: @escaping ((String) -> Void)) {
        databaseRef.child("history").child(model.date).child(model.id).child(model.key).setValue(model.toFireBase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func setCarRegion(model: CheckListModel, success: @escaping ((String) -> Void)) {
        let key = databaseRef.child("carRegion").child(model.year).child(model.numMonth).child(model.day).childByAutoId().key
        model.id = key!
        databaseRef.child("carRegion").child(model.year) .child(model.numMonth).child(model.day).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func getCarRegions(date: String, success: @escaping (([CheckListModel]) -> Void)) {
        var checkModels: [CheckListModel] = [CheckListModel]()
        databaseRef.child("carRegion").child(date.components(separatedBy: "-")[0]).child(date.components(separatedBy: "-")[1]).observeSingleEvent(of: .value, with: {snapshot in
            for snap in snapshot.children {
                let post = snap as! DataSnapshot
                let data = post.value as! [String: AnyObject]
                let checkModel: CheckListModel = CheckListModel()
                checkModel.fromFirebase(data: data)
                checkModels.append(checkModel)
            }
            success(checkModels)
        })
    }
    
    func carManager(add: @escaping ((CarServiceModel) -> Void), edit: @escaping ((CarServiceModel) -> Void), remove: @escaping ((CarServiceModel) -> Void)) {
        databaseRef.child("car").observe(.childAdded, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let car: CarServiceModel = CarServiceModel()
            car.fromFirebase(data: post)
            add(car)
        })
        
        databaseRef.child("car").observe(.childChanged, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let car: CarServiceModel = CarServiceModel()
            car.fromFirebase(data: post)
            edit(car)
        })
        
        databaseRef.child("car").observe(.childRemoved, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let car: CarServiceModel = CarServiceModel()
            car.fromFirebase(data: post)
            remove(car)
        })
    }
    
    func editCar(model: CarServiceModel, success: @escaping (String) -> Void) {
        databaseRef.child("car").child(model.id).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func removeCar(model: CarServiceModel, success: @escaping (String) -> Void) {
        databaseRef.child("car").child(model.id).removeValue(){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func addCar(model: CarServiceModel, success: @escaping (String) -> Void) {
        let key = databaseRef.child("car").childByAutoId().key
        model.id = key!
        model.regdate = Utils.covertDateToString(dateFormat: "dd-MM-yyyy", date: Date())
        databaseRef.child("car").child(model.id).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func getCarById(id: String, success: @escaping (CarServiceModel) -> Void) {
        databaseRef.child("car").child(id).observeSingleEvent(of: .value, with: {(dataSnap) in
            let model: CarServiceModel = CarServiceModel()
            if !dataSnap.exists() {
                model.name = "Unknown"
                success(model)
            } else {
                let data = dataSnap.value as! [String: AnyObject]
                model.fromFirebase(data: data)
                success(model)
            }
        })
    }
    
    func userManager(add: @escaping ((UserModel) -> Void), edit: @escaping ((UserModel) -> Void), remove: @escaping ((UserModel) -> Void)) {
        databaseRef.child("user").observe(.childAdded, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let user: UserModel = UserModel()
            user.fromFirebase(data: post)
            add(user)
        })
        
        databaseRef.child("user").observe(.childChanged, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let user: UserModel = UserModel()
            user.fromFirebase(data: post)
            edit(user)
        })
        
        databaseRef.child("user").observe(.childRemoved, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let user: UserModel = UserModel()
            user.fromFirebase(data: post)
            remove(user)
        })
    }
    
    func addUser(phone: String, id: String, success: @escaping(String) -> Void) {
        let user: UserModel = UserModel()
        user.phone = phone
        user.id = id
        user.regdate = Utils.covertDateToString(dateFormat: "yyyy-MM-dd", date: Date())
        databaseRef.child("user").child(id).setValue(user.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func editUser(model: UserModel, success: @escaping (String) -> Void) {
        databaseRef.child("user").child(model.id).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func removeUser(model: UserModel, success: @escaping (String) -> Void) {
        databaseRef.child("user").child(model.id).removeValue(){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func regionManager(add: @escaping ((RegionModel) -> Void), edit: @escaping ((RegionModel) -> Void), remove: @escaping ((RegionModel) -> Void)) {
        databaseRef.child("region").observe(.childAdded, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let region: RegionModel = RegionModel()
            region.fromFirebase(data: post)
            add(region)
        })
        
        databaseRef.child("region").observe(.childChanged, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let region: RegionModel = RegionModel()
            region.fromFirebase(data: post)
            edit(region)
        })
        
        databaseRef.child("region").observe(.childRemoved, with: {snapshot in
            let post = snapshot.value as! [String: AnyObject]
            let region: RegionModel = RegionModel()
            region.fromFirebase(data: post)
            remove(region)
        })
    }
    
    func addRegion(model: RegionModel, success: @escaping ((String) -> Void)) {
        databaseRef.child("region").child(model.title).setValue(model.toFirebase()) {(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func removeRegion(model: RegionModel, success: @escaping ((String) -> Void)) {
        databaseRef.child("region").child(model.title).removeValue() {(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func getDeliveryByMonth(yearMonth: String, result: @escaping (([CheckListModel]) -> Void)) {
        var checkModels: [CheckListModel] = [CheckListModel]()
        getAllUsers(success: {(users) in
            var index = 0
            for user in users {
                self.databaseRef.child("delivery").child(user.id).child(yearMonth).observeSingleEvent(of: .value, with: {(dataSnapshot) in
                    for snapshot in dataSnapshot.children {
                        let snap = snapshot as! DataSnapshot
                        for item in snap.children {
                            let itemVal = item as! DataSnapshot
                            let data = itemVal.value as! [String: AnyObject]
                            let model: CheckListModel = CheckListModel()
                            model.fromFirebase(data: data)
                            checkModels.append(model)
                        }
                    }
                    index += 1
                    if index == users.count {
                        result(checkModels)
                    }
                })
            }
        })
    }
    
    func getAllCar(success: @escaping(([CarServiceModel]) -> Void)) {
        databaseRef.child("car").observeSingleEvent(of: .value, with: {(dataSnap) in
            var models: [CarServiceModel] = [CarServiceModel]()
            for snapshot in dataSnap.children {
                let snap = snapshot as! DataSnapshot
                let data = snap.value as! [String: AnyObject]
                let model: CarServiceModel = CarServiceModel()
                model.fromFirebase(data: data)
                models.append(model)
            }
            success(models)
        })
    }
    
    func getAllRegion(success: @escaping(([RegionModel]) -> Void)) {
        databaseRef.child("region").observeSingleEvent(of: .value, with: {(dataSnap) in
            var models: [RegionModel] = [RegionModel]()
            for snapshot in dataSnap.children {
                let snap = snapshot as! DataSnapshot
                let data = snap.value as! [String: AnyObject]
                let model: RegionModel = RegionModel()
                model.fromFirebase(data: data)
                models.append(model)
            }
            success(models)
        })
    }
    
    func addDelivery(model: CheckListModel, success: @escaping((String) -> Void)) {
        let key = databaseRef.child("delivery").child(model.userid).child(model.year + "-" + model.numMonth).child(model.day).childByAutoId().key
        model.id = key!
        databaseRef.child("delivery").child(model.userid).child(model.year + "-" + model.numMonth).child(model.day).child(model.id).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func editDelivery(model: CheckListModel, success: @escaping((String) -> Void)) {
        databaseRef.child("delivery").child(model.userid).child(model.year + "-" + model.numMonth).child(model.day).child(model.id).setValue(model.toFirebase()){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func removeDelivery(userid: String, year: String, month: String, day: String, deliveryid: String, success: @escaping (String) -> Void) {
        databaseRef.child("delivery").child(userid).child(year + "-" + month).child(day).child(deliveryid).removeValue(){(error, ref) -> Void in
            if error == nil {
                success("success")
            } else {
                success("fail")
            }
        }
    }
    
    func getDeleiveryUserMonthYear(userid: String, monthYear: String, success: @escaping ([CheckListModel]) -> Void) {
        var models: [CheckListModel] = [CheckListModel]()
        databaseRef.child("delivery").child(userid).child(monthYear).observeSingleEvent(of: .value, with: {(snapshot) in
            for datasnap in snapshot.children {
                let datapost = datasnap as! DataSnapshot
                for post in datapost.children {
                    let item = post as! DataSnapshot
                    let data = item.value as! [String: AnyObject]
                    let model: CheckListModel = CheckListModel()
                    model.fromFirebase(data: data)
                    models.append(model)
                }
            }
            success(models)
        })
    }
    
    func getDeliveryUserDate(model: CheckListModel, completion: @escaping([CheckListModel]) -> Void) {
        var models: [CheckListModel] = [CheckListModel]()
        databaseRef.child("delivery").child(model.userid).child(model.year + "-" + model.numMonth).child(model.day).observeSingleEvent(of: .value, with: {(snapshot) in
            for datasnap in snapshot.children {
                let datapost = datasnap as! DataSnapshot
                let data = datapost.value as! [String: AnyObject]
                let model: CheckListModel = CheckListModel()
                model.fromFirebase(data: data)
                models.append(model)
            }
            completion(models)
        })
    }
}
