//
//  SocketIOManager.swift
//  foodOrderApp
//
//  Created by Sujata on 17/02/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject
{
    static let sharedInstance = SocketIOManager()
    var socket:SocketIOClient!
    
    //let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
    
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true)])
    
    override init()
    {
        super.init()
        socket = manager.defaultSocket
    }

    func establishConnection()
    {
        socket.connect()
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket Connected!")
            
            self.socket.on("order approved") { data, ack in
                NotificationCenter.default.post(name: NSNotification.Name("gotOrderApproved"), object: nil)
                
//                DispatchQueue.main.async
//                {
//                    self.btnPlaceOrder.isHidden = true
//                    self.lblTitle.text = "Your order is being processed."
//                }
            }
            
            self.socket.on("order location"){ data, ack in
                
                do
                {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let receivedLocation = try JSONDecoder().decode([Location].self, from: jsonData)
                    
                    if let dpLocation = receivedLocation.first
                    {
                        //self.deliveryPersonLocation = dpLocation
                        
                        NotificationCenter.default.post(name: NSNotification.Name("gotDPLocation"), object: dpLocation)
                    }
                }
                catch
                {
                    print(error)
                }
            }
            
            self.socket.on("task accepted") { data, ack in
                //returns DP's ph. no.
                //PASS THIS PHONE NUMBER THRU SEGUE
                
                NotificationCenter.default.post(name: NSNotification.Name("gotTaskAccepted"), object: nil)
                
                //self.performSegue(withIdentifier: "goToOrderProcess", sender: self)
            }
            
            self.socket.on("order pickedup") { data, ack in
                NotificationCenter.default.post(name: NSNotification.Name("gotOrderPickedup"), object: nil)
            }
            
            self.socket.on("order delivered") { data, ack in
                NotificationCenter.default.post(name: NSNotification.Name("gotOrderDelivered"), object: nil)
            }
        }
    }
    
    func closeConnection()
    {
        socket.disconnect()
        socket.on(clientEvent: .disconnect)
        {data, ack in
            print("Socket Disconnected!")
        }
    }
    
    func emitActiveUser(_ userId:String)
    {
        self.socket.emit("active user", userId)
    }
    
    func emitActiveOrder(_ orderId: String)
    {
        self.socket.emit("active order", orderId)
    }
}
