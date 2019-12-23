//
//  menuItem.swift
//  foodOrderApp
//
//  Created by Sujata on 21/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

struct menuItem:Codable
{
    let id: String?
    let name: String?
    let vegetarian: Bool?
    let category: String?
    let ingredients: String?
    let price: Double?
}
