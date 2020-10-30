//
//  RegionManagerVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

private let reuseIdentifier = "PostalCell"
private let headerIdentifier = "RegionSectionUV"

class RegionManagerVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var regionList: [RegionModel] = [RegionModel]()
    
    let numberOfItemsPerRow: CGFloat = 4.0
    let leftAndRightPadding: CGFloat = 2.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let alignedFlowLayout = collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        initData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func initData() {
        Utils.onShowProgressView(name: "Loading...")
        FireManager.firebaseRef.regionManager(add: {(addModel) in
                Utils.onhideProgressView()
            if self.regionList.count == 0 {
                self.regionList.append(addModel)
                self.collectionView.reloadData()
                return
            }
            
            var isContainAvailable = true
            for model in self.regionList {
                if model.title == addModel.title {
                    isContainAvailable = false
                    break
                }
            }
            if isContainAvailable {
                self.regionList.append(addModel)
            }
            self.collectionView.reloadData()
        }, edit: {(editModel) in
            Utils.onhideProgressView()
            for model in self.regionList {
                if model.title == editModel.title {
                    model.postal = editModel.postal
                    model.color = editModel.color
                }
            }
            self.collectionView.reloadData()
        }, remove: {(removeModel) in
            Utils.onhideProgressView()
            for i in 0..<self.regionList.count {
                if self.regionList[i].title == removeModel.title {
                    self.regionList.remove(at: i)
                    break
                }
            }
            self.collectionView.reloadData()
        })
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return regionList.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return regionList[section].postal.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostalCell
        cell.initCell(model: regionList[indexPath.section], value: regionList[indexPath.section].postal[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! RegionSectionUV
        sectionHeaderView.initHeader(regionModel: regionList[indexPath.section])
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpcing = (numberOfItemsPerRow + 1) * leftAndRightPadding
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpcing) / numberOfItemsPerRow
            return CGSize(width: width, height: 38.0)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == regionList.count - 1 {
            return UIEdgeInsets(top: 4.0, left: 0.0, bottom: 50.0, right: 8.0)
        } else {
            return UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0, right: 8.0)
        }
        
    }
}
