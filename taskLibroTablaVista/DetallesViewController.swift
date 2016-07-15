//
//  DetallesViewController.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//

import UIKit

import UIKit

class DetallesViewController: UIViewController {
    
    var elLibro: book!
    
    @IBOutlet weak var tituloTextView: UITextField!

    @IBOutlet weak var autorTextView: UITextField!
    
    @IBOutlet weak var portadaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tituloz = elLibro.titulo + elLibro.autores
        print(tituloz)
        
        tituloTextView.text = elLibro.titulo
        autorTextView.text = elLibro.autores
        portadaImageView.image = elLibro.portada
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
