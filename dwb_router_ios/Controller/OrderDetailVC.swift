//
//  OrderDetailVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SendGrid_Swift
import Contacts
import MapKit
import CoreLocation
import CRNotifications

class OrderDetailVC: UIViewController {

    @IBOutlet weak var topUV: UIView!
    @IBOutlet weak var distanceLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var playUB: UIImageView!
    @IBOutlet weak var orderTV: UITableView!
    @IBOutlet weak var mapUV: GMSMapView!
    @IBOutlet weak var missingUV: UIView!
    @IBOutlet weak var missingLB: UILabel!
    
    var orders: [OrderModel]?
    var showOrders: [OrderModel] = [OrderModel]()
    
    var isShowCheckMark: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        initUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawPolyLines()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNavigation" {
            let destinationVC = segue.destination as! NavigationVC
            destinationVC.index = sender as? Int
        }
    }
    
    func initMap() {
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 8.0)
        mapUV.camera = camera
    }
    
    func initUIView() {
        topUV.layer.cornerRadius = 4.0
        
        let playGesture = UITapGestureRecognizer(target: self, action: #selector(onTapPlayUB))
        playUB.addGestureRecognizer(playGesture)
        
        orderTV.rowHeight = UITableView.automaticDimension
        orderTV.estimatedRowHeight = 95.0
        orderTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        orderTV.register(UINib(nibName: "OrderDetailCell", bundle: nil), forCellReuseIdentifier: "OrderDetailCell")
        orderTV.dataSource = self
        
        missingUV.isHidden = true
        missingLB.text = "Missing Orders: "
        var i: Int = 0
        
        for order in orders! {
            _ = CLGeocoder()
            let str_address: String = order.shippingPerson.street + " " + order.shippingPerson.city

            let postalCode: String = order.shippingPerson.postalCode.replacingOccurrences(of: " ", with: "").lowercased()
            let prefPostal = postalCode.prefix(4)
            let sufPostal = postalCode.suffix(2)
            let realPostalCode: String = prefPostal + " " + sufPostal
            
            let param = [
                "address": realPostalCode.replacingOccurrences(of: " ", with: "") + " nl",
                "key": AppConst.GOOGLE_MAP_KEY
            ]
            let url: String = "https://maps.googleapis.com/maps/api/geocode/json"
            APIManager.apiConnectionReturn(param: param, url: url, method: .get, success: {(json, isSuccess) in
                i += 1
                if isSuccess && json["status"].stringValue == "OK"{
                    let results = json["results"].arrayValue
                    let result = results[0].dictionaryValue
                    let geometry = result["geometry"]?.dictionaryValue
                    let location = geometry!["location"]!.dictionary
                    let lat = location!["lat"]!.stringValue
                    let lon = location!["lng"]!.stringValue
                    order.shippingPerson.lat = lat
                    order.shippingPerson.lan = lon
                    if i == self.orders?.count {
                        self.drawPolyLines()
                    }
                    
                } else {
                    let param1 = [
                        "address": str_address,
                        "key": AppConst.GOOGLE_MAP_KEY
                    ]
                    APIManager.apiConnectionReturn(param: param1, url: url, method: .get, success: {(json, isSuccess) in
                        if isSuccess && json["status"].stringValue == "OK"{
                            let results = json["results"].arrayValue
                            let result = results[0].dictionaryValue
                            let geometry = result["geometry"]?.dictionaryValue
                            let location = geometry!["location"]!.dictionary
                            let lat = location!["lat"]!.stringValue
                            let lon = location!["lng"]!.stringValue
                            order.shippingPerson.lat = lat
                            order.shippingPerson.lan = lon
                            if i == self.orders?.count {
                                self.drawPolyLines()
                            }
                        } else {
                            order.shippingPerson.lat = "Unknown"
                            order.shippingPerson.lan = "Unknown"
                            self.missingUV.isHidden = false
                            let missingOrder: String = order.orderNumber
                            self.missingLB.text = self.missingLB.text! + " " + missingOrder
                            if i == self.orders?.count {
                                self.drawPolyLines()
                            }
                        }
                    })
                }
            })

        }
        
    }
    
    func drawPolyLines() {
        Utils.onShowProgressView(name: "Sever Connection...")
        let param = getDirectionUrl()
        let url: String = "https://maps.googleapis.com/maps/api/directions/json"
        APIManager.apiConnection(param: param, url: url, method: .get, success: {(json) in
            Utils.onhideProgressView()
            
            self.onUpdateGoogleMap(object: json)
            
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                DispatchQueue.main.async {
                    // Run UI Updates
                    if json["status"].stringValue == "OK" {
                        if let routes = json["routes"].array {
                            if let route = routes.first {
                                let routeOverviewPolyline = route["overview_polyline"].dictionary
                                let points = routeOverviewPolyline?["points"]?.string
                                if let path = GMSPath.init(fromEncodedPath: points!) {
                                    self.setPath(path: path)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func setPath(path: GMSPath) {
        let polyline = GMSPolyline.init(path: path)
        polyline.strokeColor = .red
        polyline.strokeWidth = 5
        polyline.map = self.mapUV
        
        var bounds = GMSCoordinateBounds()
        
        for index in 1...path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        self.mapUV.moveCamera(GMSCameraUpdate.fit(bounds))
    }
    
    func onUpdateGoogleMap(object: JSON) {
        if let routes = object["routes"].array {
            if let route = routes.first {
                if let legs = route["legs"].array {
                    var dis = 0
                    var dur = 0
                    showOrders.removeAll()
                    Utils.gAllRouters.removeAll()
                    Utils.gAllLatLang.removeAll()
                    for i in 0..<legs.count {
                        let leg = legs[i]
                        let distance  = leg["distance"]
                        let dis_one = distance["value"].intValue
                        dis = dis + dis_one
                        
                        let duration = leg["duration"]
                        let dur_one = duration["value"].intValue
                        dur = dur + dur_one
                        
                        let routerInfo: RouterInfoModel = RouterInfoModel()
                        routerInfo.distance = dis_one
                        routerInfo.during = dur
                        
                        Utils.gAllRouters.append(routerInfo)
                        
                        let loc_start = leg["start_location"]
                        let start_location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: loc_start["lat"].doubleValue, longitude: loc_start["lng"].doubleValue)
                        
                        let loc_end = leg["end_location"]
                        let end_location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: loc_end["lat"].doubleValue, longitude: loc_end["lng"].doubleValue)
                        
                        let address_start = leg["start_address"].stringValue
                        let addr_start = address_start.components(separatedBy: ",")[0]
                        
                        let address_end = leg["end_address"].stringValue
                        _ = address_end.components(separatedBy: ",")[0]
                        
                        if i == 0 {
                            let m1 = GMSMarker(position: start_location)
                            m1.title = addr_start
                            m1.icon = GMSMarker.markerImage(with: .green)
                            m1.map = mapUV
                            
                            let title = getMarkerFromAddress(address: end_location)
                            let m2 = GMSMarker(position: end_location)
                            m2.title = title
                            m2.icon = GMSMarker.markerImage(with: .red)
                            m2.map = mapUV
                            
                            Utils.gAllLatLang.append(start_location)
                            Utils.gAllLatLang.append(end_location)
                        } else if i == legs.count - 1 {
                            let m1 = GMSMarker(position: end_location)
                            m1.title = title
                            m1.icon = GMSMarker.markerImage(with: .blue)
                            m1.map = mapUV
                            
                            Utils.gAllLatLang.append(end_location)
                        } else {
                            let title = getMarkerFromAddress(address: end_location)
                            let m1 = GMSMarker(position: end_location)
                            m1.title = title
                            m1.icon = GMSMarker.markerImage(with: .red)
                            m1.map = mapUV
                            
                            Utils.gAllLatLang.append(end_location)
                        }
                    }
                    orderTV.reloadData()
                    Utils.gSelOrders.removeAll()
                    Utils.gSelOrders = showOrders
                    distanceLB.text = String(format: "%.1f Km", Float(dis) / 1000.0)
                    
                    let hour = dur / 3600
                    let min = (dur - hour * 3600) / 60
                    var duringTime = ""
                    if (hour == 0) {
                        duringTime = "\(min) min"
                    } else {
                        duringTime = "\(hour) h \(min) m";
                    }
                    timeLB.text = duringTime
                }
            }
        }
    }
    
    func getDirectionUrl() -> [String: String] {
        var params: [String: String] = [String: String]()
        // Origin of route
        let origin: String = "Van Zeggelenlaan 112"
        
        var waypoints: String = "optimize:true"
        var streets: [String] = [String]()

        for model in orders! {
            if model.shippingPerson.lat == "Unknown" {
                continue
            }
            let street: String = model.shippingPerson.lat + " " + model.shippingPerson.lan
            if streets.count == 0 {
                streets.append(street)
            } else {
                if !streets.contains(street) {
                    streets.append(street)
                }
            }
        }

        for street in streets {
            waypoints = waypoints + "|" + street
        }
        
        params = [
            "origin": origin,
            "destination": Utils.gUser!.address,
            "sensor": "false",
            "mode": "driving",
            "waypoints": waypoints,
            "provideRouteAlternatives": "true",
            "key": AppConst.GOOGLE_MAP_KEY
        ]
        return params
    }
    
    func getMarkerFromAddress(address: CLLocationCoordinate2D) -> String{
        
        for model in orders! {
            let lat = Double(model.shippingPerson.lat)
            let lng = Double(model.shippingPerson.lan)
            let firstPoint: CLLocation = CLLocation(latitude: lat!, longitude: lng!)
            let secondPoint: CLLocation = CLLocation(latitude: address.latitude, longitude: address.longitude)
            let delta = firstPoint.distance(from: secondPoint)
            
            if delta < 100 && !showOrders.contains(model) {
                showOrders.append(model);
                return "#" + model.orderNumber + ", " + model.shippingPerson.name;
            }
        }
        return "Not Found"
    }
    
    @objc func onTapPlayUB() {
        var emails: [String] = [String]()
        var text: [String] = [String]()
        let timestamp = NSDate().timeIntervalSince1970
        _ = TimeInterval(timestamp)
        
        for i in 0..<showOrders.count {
            emails.append(showOrders[i].email)
            let date = Date()
            let calendar = Calendar.current
            let addStart = Utils.gAllRouters[i].during / 60 + i * 5
            let startDate = calendar.date(byAdding: .minute, value: addStart, to: date)
            let addEnd = Utils.gAllRouters[i].during / 60 + 60 + i * 5
            let endDate = calendar.date(byAdding: .minute, value: addEnd, to: date)
            
            let strStart = Utils.covertDateToString(dateFormat: "HH:mm", date: startDate!)
            let strEnd = Utils.covertDateToString(dateFormat: "HH:mm", date: endDate!)
            
            let send_msg: String = "Uw bestelling wordt tussen " + strStart + " en " + strEnd + " bezorgd. \n" + " met vriendelijke groet, \n" + " De Westlandse Bezorgslager";
            text.append(send_msg)
            
        }
        
        
        
        let sendGrid = SendGrid(withAPIKey: AppConst.SENDGRID_APIKEY)
        var j: Int = 0
        for i in 0..<emails.count {
            let content = SGContent(type: .plain, value: text[i])
            let from = SGAddress(email: "info@dewestlandsebezorgslager.nl")
            let personalization = SGPersonalization(to: [ SGAddress(email: emails[i]) ])            
            
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: "De bezorger is onderweg", content: [content])
            
            sendGrid.send(email: email) { (response, error) in
                if error != nil {
                    j += 1
                } else {
                    j += 1
                    if j == emails.count {
                        self.onShowNotificaiton()
                    }
                }
            }
            
        }
        
    }
    
    func onShowNotificaiton() {
        DispatchQueue.main.async {
            CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "email naar klanten zijn verzonden", dismissDelay: 2.0)
        }
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onTapRightUB(_ sender: Any) {
        if isShowCheckMark {
            var delvieriedModels: [OrderModel] = [OrderModel]()
            for orderModel in showOrders {
                if orderModel.isCheckDeliver {
                    delvieriedModels.append(orderModel)
                }
            }
            
            if delvieriedModels.count > 0 {
                let checkListModel: CheckListModel = CheckListModel()
                checkListModel.amount = ""
                checkListModel.color = ""
                checkListModel.region = ""
                
                for regionModel in Utils.gRegions {
                    var cnt: Int = 0
                    for order in delvieriedModels {
                        if order.shippingPerson.region == regionModel.title {
                            cnt += 1
                        }
                    }
                    
                    if cnt > 0 {
                        checkListModel.amount += ",\(cnt)"
                        checkListModel.color += "," + regionModel.color.lowercased().replacingOccurrences(of: "#ff", with: "#")
                        checkListModel.region +=  "," + regionModel.title
                    }
                }
                
                checkListModel.amount = checkListModel.amount.substring(from: 1)
                checkListModel.color = checkListModel.color.substring(from: 1)
                checkListModel.region = checkListModel.region.substring(from: 1)
                checkListModel.day = Utils.covertDateToString(dateFormat: "dd", date: Date())
                checkListModel.numMonth = Utils.covertDateToString(dateFormat: "MM", date: Date())
                checkListModel.month = Utils.covertDateToString(dateFormat: "MMM", date: Date())
                checkListModel.week = Utils.covertDateToString(dateFormat: "EEE", date: Date())
                checkListModel.year = Utils.covertDateToString(dateFormat: "yyyy", date: Date())
                checkListModel.userid = Utils.gUser!.id
                checkListModel.carid = Utils.gUser!.id
                
                Utils.onShowProgressView(name: "Uploading...")
                FireManager.firebaseRef.getDeliveryUserDate(model: checkListModel, completion: {(result) in
                    if result.count > 0 {
                        Utils.onhideProgressView()
                        CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Already added data.", dismissDelay: 2.0)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        FireManager.firebaseRef.addDelivery(model: checkListModel, success: {(result) in
                            if result == "success" {
                                Utils.onhideProgressView()
                                CRNotifications.showNotification(type: CRNotifications.success, title: "Info", message: "Success history.", dismissDelay: 2.0)
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                Utils.onhideProgressView()
                                CRNotifications.showNotification(type: CRNotifications.error, title: "Error", message: "Failed add data.", dismissDelay: 2.0)
                            }
                        })
                    }
                })
            } else {
                CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Select Delivery.", dismissDelay: 2.0)
            }
        } else {
            isShowCheckMark = !isShowCheckMark
            orderTV.reloadData()
        }
    }
}

extension OrderDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell", for: indexPath) as! OrderDetailCell
        cell.initCell(model: showOrders[indexPath.row], processing: Utils.gProcessing[indexPath.row], index: indexPath.row, showCheckMark: isShowCheckMark)
        cell.delegate = self
        return cell
    }
}

extension OrderDetailVC: OrderDetailCellDelegate{
    func didSelectCell(index: Int) {
//        self.performSegue(withIdentifier: "goToNavigation", sender: index)
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
//            let url = "comgooglemaps://?q=\(Utils.gAllLatLang[index + 1].latitude), \(Utils.gAllLatLang[index + 1].longitude)"
            let str_address: String = showOrders[index].shippingPerson.street + ", " + showOrders[index].shippingPerson.city + ", " + showOrders[index].shippingPerson.postalCode + ", " + showOrders[index].shippingPerson.countryName
            let url = "comgooglemaps://?daddr=\(str_address)"
            if let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                UIApplication.shared.open(NSURL(string: encodedURL)! as URL, options: [:], completionHandler: nil)
            }
        } else {
            print("aaaaa")
        }
    }
}

