//
//  showBookViewController.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//


import UIKit

class showBookViewController: UIViewController, UITextFieldDelegate {
    
    var libro: book!
    
    @IBOutlet weak var ISBNtextField: UITextField!
    
    @IBOutlet weak var tituloTextField: UITextField!
    
    @IBOutlet weak var AutorTextFiled: UITextField!
    
    @IBOutlet weak var portadaImageView: UIImageView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let mainTable = segue.destinationViewController as! libroTableViewController
        if libro != nil {
            mainTable.mislibros.append(libro)
            mainTable.tableView.reloadData()
        }
        
    }
    
    @IBAction func onAdicionar(sender: UIButton) {
        //  self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let (titulo , portada , autores) = sincrono(ISBNtextField.text!)
        var stringAutores = ""
        let numerosdeElementos = autores.count
        
        if autores.count > 1 {
            print(autores.count)
            for i in 1..<numerosdeElementos {
                stringAutores = stringAutores + autores[i]
                
            }
        } else { stringAutores = "Sin autor" }
        
        let imagePortada = getLaImagen(portada)
        
        tituloTextField.text = titulo
        AutorTextFiled.text = stringAutores
        portadaImageView.image = imagePortada
             libro =  book(titulo: titulo, autores: stringAutores, portada: imagePortada)
        
        self.ISBNtextField.endEditing(true)
        return true
    }
    
    func getLaImagen(direccion: String) -> UIImage? {
        
        let url = NSURL(string: direccion)
        
        if let datos: NSData = NSData(contentsOfURL: url!) {
            let imagenPortada = UIImage(data: datos)
            return imagenPortada
        }
        
        let noImage: UIImage? = nil
        
        return noImage
    }
    
    func sincrono(ISBN: String)   -> (titulo: String, portada: String, autores: [String] ) {
        let urlstr = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + ISBN
        let url = NSURL(string: urlstr)
        
        
        if let datos: NSData = NSData(contentsOfURL: url!) {
            return procesarDatum(datos, ISBN: ISBN)
            
        }else{
            //adding a loading alert
            let alert = UIAlertController(title: "Atención", message: "Ingresa un ISBN correcto.", preferredStyle: .Alert)
            
            alert.view.tintColor = UIColor.blackColor()
            let accionOK = UIAlertAction(title: "OK", style: .Default, handler:{
                accion in
            })
            alert.addAction(accionOK)
            self.presentViewController(alert, animated: true, completion: nil)
            ///////////////////////

        }
        
        let alert = UIAlertController(title: "Alerta", message: "No hay conexión a Internet.", preferredStyle: .Alert)
        // print(texto!)
        let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(accion)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        return ("Error de conexión", "error", ["error"])
    }
    
    func procesarDatum(datos: NSData, ISBN:String) -> (titulo: String, portada: String, autores: [String]) {
        var title = "Sin Titulo"
        var unaPortada = ""
        var nombreAutores = ["Sin Autor"]
        
        do {
            let json =
                try NSJSONSerialization.JSONObjectWithData(datos, options: NSJSONReadingOptions.MutableLeaves)
            let dico1 = json as! NSDictionary
            let isbn = "ISBN:" + ISBN
            
            title = dico1[isbn]!["title"] as! String
       
            
            let autores = dico1[isbn]!["authors"] as! [NSDictionary]
            
            for author in autores {
                let nombre = author["name"] as! String
                nombreAutores.append(nombre)
                //print("Nombre \(nombre)")
            }
            
          
            var urlDeportadas = ["Sin portada"]
            
            
            if let portadas = dico1[isbn]!["cover"] as! NSDictionary? {
                for ( _ , value) in portadas {
                    let frente = value as! String
                    urlDeportadas.append(frente)
                    
                }
                
                if urlDeportadas.count > 1 {
                    unaPortada = urlDeportadas[1]
                }
            }
            
            return (title, unaPortada, nombreAutores)
            
        }
        catch _ {
        }
        
        
        return (title, unaPortada, nombreAutores)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.ISBNtextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
