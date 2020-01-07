//
//  place.swift
//  foodOrderApp
//
//  Created by Sujata on 19/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//


struct Place:Codable
{
    let status : String?
    let predictions : [Predictions]?
}

struct Predictions:Codable
{
    let name : String?
    let type : String?
    let lat : String?
    let lon : String?
    let id : String?
    let city : String?
    let housenumber : String?
    let postcode : String?
    let street : String?
    let description : String?
}
