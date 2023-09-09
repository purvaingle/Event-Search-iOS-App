////
////  EventTable.swift
////  trial3
////
////  Created by Purva Ingle on 4/15/23.
////
//
//import Foundation
//import Alamofire
//
//public struct EventTable: Codable, Identifiable {
//    public var id : UUID
//    var name: String = ""
//    var date: String = ""
//    var time: String = ""
//    var genre: String = ""
//    // add any other properties you want to display
//
//
//    func search(keyword: String, distance: String, category: String, location: String, lat: Double, lng: Double, geoloc: Int, completion: @escaping (_ events: [EventTable]?, _ error: Error?) -> Void) {
//
//
//
//    //
//            let url = "https://finalsubhw8.uw.r.appspot.com/getdata?keyword=\(keyword)&distance=\(distance)&category=\(category)&location=\(location)&lat=\(lat)&long=\(lng)"
//
//                AF.request(url, method: .get)
//                    .validate(statusCode: 200..<300)
//                    .responseJSON { response in
//                        switch response.result {
//                        case .success(let value):
//                            print(value)
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//            }
//
//
//
//}
