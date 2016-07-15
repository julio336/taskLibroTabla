//
//  book.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//

import Foundation
import UIKit

struct book {
    
    var titulo: String
    var autores: String
    var portada: UIImage?
    
    init(titulo: String, autores: String, portada: UIImage?) {
        
        self.titulo = titulo
        self.autores = autores
        self.portada = portada
    }
}