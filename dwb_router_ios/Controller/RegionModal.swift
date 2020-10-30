//
//  RegionModal.swift
//  dwb_router_ios
//
//  Created by Aira on 7/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol RegionModalDelegate {
    func onTapOkUBDelegate(regions: [RegionModel], isFirstCell: Bool)
}

class RegionModal: UIViewController {

    @IBOutlet weak var mainUV: UIView!
    @IBOutlet weak var containerUV: UIView!
    @IBOutlet weak var carNameLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    var isFirstCell = true
    var strCarName = ""
    var strDate = ""
    var regionModels: [RegionModel] = [RegionModel]()
    var delegate: RegionModalDelegate?
    
    let colors: [UIColor] = [UIColor.mainRoosterRed(), UIColor.mainRoosterBlue(), UIColor.mainRoosterGreen(), UIColor.mainRoosterYellow(), UIColor.mainRoosterPink()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUIView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initUIView() {
        mainUV.layer.cornerRadius = 8.0
        carNameLB.text = strCarName
        dateLB.text = strDate
        
//        for i in 1..<AppConst.regions.count {
//            let regionModel: RegionModel = RegionModel()
//            regionModel.id = "\(i)"
//            regionModel.title = AppConst.regions[i]
//            regionModel.isCheck = false
//            regionModels.append(regionModel)
//        }
        
        for i in 0..<regionModels.count{
            containerUV.layoutIfNeeded()
           let cateUV = Bundle.main.loadNibNamed("CheckBoxUV", owner: self, options: nil)?.first as! CheckBoxUV
            cateUV.initWithRegionModel(model: regionModels[i], color: colors[i])
            cateUV.translatesAutoresizingMaskIntoConstraints = false
            containerUV.addSubview(cateUV)
            NSLayoutConstraint.activate([
                cateUV.centerXAnchor.constraint(equalTo: containerUV.centerXAnchor),
                cateUV.topAnchor.constraint(equalTo: containerUV.topAnchor, constant: (CGFloat)(i * 44)),
                cateUV.widthAnchor.constraint(equalToConstant: containerUV.frame.width),
                cateUV.heightAnchor.constraint(equalToConstant: 44.0)
            ])
        }
        containerUV.autoresizesSubviews = true
        containerHeight.constant = (CGFloat)(44 * (regionModels.count))
        containerUV.needsUpdateConstraints()
    }
    
    @IBAction func onTapCancelUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOkUB(_ sender: Any) {
        var selectedRegions: [RegionModel] = [RegionModel]()
        for model in regionModels {
            if model.isCheck {
                selectedRegions.append(model)
            }
        }
        delegate?.onTapOkUBDelegate(regions: selectedRegions, isFirstCell: isFirstCell)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
