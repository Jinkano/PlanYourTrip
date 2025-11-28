//
//  User.swift
//  PlanYourTrip
//
//  Created by Mananas on 26/11/25.
//

import Foundation

struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let gender: Int
    let dateBirth: Int64?
}
