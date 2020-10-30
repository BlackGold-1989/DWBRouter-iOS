//
//  OrderVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class OrderVC: UIViewController {

    @IBOutlet weak var printUB: UIButton!
    @IBOutlet weak var routeUB: UIButton!
    @IBOutlet weak var contentTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUIView()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOrderDetail" {
            let destinationVC = segue.destination as! OrderDetailVC
            destinationVC.orders = sender as? [OrderModel]
        } else if segue.identifier == "goToPDF" {
            let destinationVC = segue.destination as! PdfVC
            destinationVC.url = sender as? Data
        }
    }
    
    
    func initUIView() {
        self.title = "Order List (\(Utils.gOrders.count))"
        
        printUB.layer.cornerRadius = 8.0
        routeUB.layer.cornerRadius = 8.0
        
        contentTV.rowHeight = UITableView.automaticDimension
        contentTV.estimatedRowHeight = 98.0
        contentTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTV.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        contentTV.dataSource = self
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapCheckUB(_ sender: Any) {
        for orderModel in Utils.gOrders {
            orderModel.isCheck = true
        }
        contentTV.reloadData()
    }
    
    @IBAction func onTapPrintUB(_ sender: Any) {
        var selectedOrders: [OrderModel] = [OrderModel]()
        Utils.gProcessing.removeAll()
        
        for order in Utils.gOrders {
            if order.isCheck {
                selectedOrders.append(order)
            }
        }
        
        if selectedOrders.count > 0 {
            let strFile = Utils.createPDFFile(data: selectedOrders)
            
            print(strFile)
            self.performSegue(withIdentifier: "goToPDF", sender: strFile)
        } else {
            self.view.makeToast("Please select some orders.")
        }
    }
    
    @IBAction func onTapRouteUB(_ sender: Any) {
        var selectedOrders: [OrderModel] = [OrderModel]()
        Utils.gProcessing.removeAll()
        
        for order in Utils.gOrders {
            if order.isCheck {
                selectedOrders.append(order)
                Utils.gProcessing.append("Processing")
            }
        }
        
        if selectedOrders.count > 0 {
            self.performSegue(withIdentifier: "goToOrderDetail", sender: selectedOrders)
        } else {
            self.view.makeToast("Please select some orders.")
        }
    }
}

extension OrderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utils.gOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        cell.initWithCell(model: Utils.gOrders[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension OrderVC: OrderCellDelegat {
    func didCheckOrder(isChecked: Bool, model: OrderModel) {
        model.isCheck = isChecked
    }
}
