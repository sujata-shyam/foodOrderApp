//
//  menuItem.swift
//  foodOrderApp
//
//  Created by Sujata on 21/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

struct MenuItem:Codable
{
    let id: String?
    let name: String?
    let vegetarian: Bool?
    let category: String?
    let ingredients: String?
    let price: Double?
}

struct Cart:Codable
{
    let restaurantId: String?
    let cartItems : [String:CartItemDetail?]
}

struct CartItemDetail:Codable
{
    let name: String?
    let price: Double?
    var quantity: Int?
}

struct Checkout:Codable
{
    let restaurantId: String?
    let cartItems : [String:CartItemDetail?]
    let bill: Bill?
}

struct Bill:Codable
{
    let deliveryfee: Double?
    let subtotal: Double?
    let total: Double?
}
