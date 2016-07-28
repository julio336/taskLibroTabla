//
//  showBookViewController.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//


import UIKit
import CoreData


class showBookViewController: UIViewController, UITextFieldDelegate {
    
    var libro: book!
    var contexto: NSManagedObjectContext? = nil

    
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
        //empty string o pequena ni lo busco poner un alert
        if textField.text?.characters.count < 4 {
            alertar("ISBN con menos de 4 caracteres.")
            return true
        }
        
        //primero buscas si ya existe en la base de datos usando el isbn
        let libroEntidad = NSEntityDescription.entityForName("UnLibro", inManagedObjectContext: self.contexto!)
        let peticion = NSFetchRequest()
        peticion.entity = libroEntidad
        let predicado = NSPredicate(format: "isbn = %@", textField.text!)
        peticion.predicate = predicado
        
        do {
            let foundisbn = try self.contexto?.executeFetchRequest(peticion)
            if (foundisbn?.count > 0) {
                alertar("Ya existe el libro en tus favoritos.")
                return true
            }
        } catch _ { }
        
        let (titulo , portada , autores) = sincrono(ISBNtextField.text!)
        //no internet
        if portada == "errorInternet" {
            return true
        }
        
        if titulo == "noseencontro" {
            alertar("No existe ese ISBN in openlib.org")
            return true
        }
        //
        var stringAutores = ""
        let numerosdeElementos = autores.count
        
        if autores.count > 1 {
            
            for i in 1..<numerosdeElementos {
                stringAutores = stringAutores + autores[i]
                
            }
        } else { stringAutores = "Sin autor" }
        
        let imagePortada = getLaImagen(portada)
        
        
        tituloTextField.text = titulo
        AutorTextFiled.text = stringAutores
        portadaImageView.image = imagePortada
        
        //libro.autores = stringAutores
        //libro.titulo = titulo
        //libro.portada = imagePortada!
        
        libro =  book(titulo: titulo, autores: stringAutores, portada: imagePortada, ISBN: ISBNtextField.text! )
        saveLibroToDB(titulo, autores: stringAutores, portada: imagePortada, ISBN: ISBNtextField.text! )
        
        self.ISBNtextField.endEditing(true)
        return true
    }
    
    func saveLibroToDB(titulo: String, autores: String, portada: UIImage?, ISBN: String) {
        let ellibro = NSEntityDescription.insertNewObjectForEntityForName("UnLibro", inManagedObjectContext: self.contexto!)
        
        var portadaData: NSData? = nil
        
        if portada != nil {
            portadaData = UIImagePNGRepresentation(portada!)
        }
        
        ellibro.setValue(titulo, forKey: "titulo")
        ellibro.setValue(portadaData, forKey: "portada")
        ellibro.setValue(ISBN, forKey: "isbn")
        
        // ellibro.setValue(autores, forKeyPath: "tiene.nombre")
        let aut =  NSEntityDescription.insertNewObjectForEntityForName(
            "Autores", inManagedObjectContext: self.contexto!)
        
        aut.setValue(autores, forKey: "nombre")
        ellibro.setValue(aut, forKey: "tiene")
        
        do{
            print("try saving it..before")
            try self.contexto?.save()
        } catch _ {}
        
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
        // let urlstr = "http://dia.ccm.itesm.mx"
        let urlstr = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + ISBN
        let url = NSURL(string: urlstr)
        
        
        if let datos: NSData = NSData(contentsOfURL: url!) {
            //data to json
            return procesarDatum(datos, ISBN: ISBN)
            
        }
        
        alertar("Parece que no hay conexion al Internet")
        
        return ("error de internet", "errorInternet", ["error"])
    }
    
    func alertar(mensaje: String) {
        let alert = UIAlertController(title: "Atención", message: mensaje, preferredStyle: .Alert)
        // print(texto!)
        let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(accion)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func procesarDatum(datos: NSData, ISBN:String) -> (titulo: String, portada: String, autores: [String]) {
        var title = "Sin Titulo"
        var unaPortada = ""
        var nombreAutores = ["Sin Autor"]
        
        if ISBN.characters.count > 0 {
            
            do {
                let json =
                    try NSJSONSerialization.JSONObjectWithData(datos, options: NSJSONReadingOptions.MutableLeaves)
                //diccionario primario
                let dico1 = json as! NSDictionary
                //si dico1 no tiene no existe libro en DB
                if dico1.count < 1 { return ("noseencontro", unaPortada, nombreAutores) }
                let isbn = "ISBN:" + ISBN
                
                // el titulo
                
                
                title = dico1[isbn]!["title"] as! String
                //print("titulo es: \(title)")
                
                //los autores
                
                let autores = dico1[isbn]!["authors"] as! [NSDictionary]
                
                // varios test this 978-03-879-5584-1
                for author in autores {
                    let nombre = author["name"] as! String
                    nombreAutores.append(nombre)
                    //print("Nombre \(nombre)")
                }
                
                // print("Autores \(nombreAutores)")
                
                //la portada??  test this 978-01-560-3119-6
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
                
                
                // print(unaPortada)
                
                return (title, unaPortada, nombreAutores)
                //return
                
            }
            catch _ {
                // print("arrojo algo")
            }
            
        } //if ISBN.characters.count > 0 {
        return (title, unaPortada, nombreAutores)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        self.ISBNtextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
