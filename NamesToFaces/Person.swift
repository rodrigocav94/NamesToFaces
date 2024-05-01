//
//  Person.swift
//  NamesToFaces
//
//  Created by Rodrigo Cavalcanti on 01/05/24.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
