//
//  user.swift
//  foodOrderApp
//
//  Created by Sujata on 25/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

struct LoginRequest:Codable
{
    let phone : String?
}

struct LoginResponse:Codable
{
    let msg: String?
    let session: String?
    let id: String?
    let username: String?
    let phone: String?
    let email: String?
}

struct SignUpRequest:Codable
{
    let username : String?
    let password : String?
    let email : String?
    let phone : String?
}

struct SignUpResponse:Codable
{
    let id : String?
    let username : String?
    let email : String?
    let phone : String?
}

