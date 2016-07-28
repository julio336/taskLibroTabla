//
//  libroTableViewController.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//

import UIKit
import CoreData

class libroTableViewController: UITableViewController {

    var mislibros: [book] = [book]()
    var contexto: NSManagedObjectContext? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Mis libros"
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let libroEntidad = NSEntityDescription.entityForName("UnLibro", inManagedObjectContext: self.contexto!)
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
        var contarLibros = 0
        do {
            let librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
            
            if librosEntidad != nil {
                contarLibros = (librosEntidad?.count)!
            }
            
        } catch _ {}
        
        //return mislibros.count
        return contarLibros
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IdentCelda", forIndexPath: indexPath)
        
        let libroEntidad = NSEntityDescription.entityForName("UnLibro", inManagedObjectContext: self.contexto!)
        
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
        var librosEntidad: [AnyObject]? = nil
        do {
            librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
            if librosEntidad != nil {
                
                let librox = librosEntidad![indexPath.row]
                
                let titulox = librox.valueForKey("titulo") as! String
                cell.textLabel?.text = titulox
                
            }
        } catch _ {}
        
        
        return cell

    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetalleSegue" {
            let mostrarDetalle = segue.destinationViewController as! DetallesViewController
            
            let ip = self.tableView.indexPathForSelectedRow?.row
            
            let libroEntidad = NSEntityDescription.entityForName("UnLibro", inManagedObjectContext: self.contexto!)
            let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
            var librosEntidad: [AnyObject]? = nil
            var libroSeleccionado: book? = nil
            do {
                librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
                if librosEntidad != nil {
                    
                    let librox = librosEntidad![ip!]
                    
                    let titulox = librox.valueForKey("titulo") as! String
                    print("de DB titulox es \(titulox)")
                    let isbnx = librox.valueForKey("isbn") as! String
                    print("de DB ISBNx es \(isbnx)")
                    let autorx = librox.valueForKeyPath("tiene.nombre") as? String
                    print("de DB autorx es \(autorx)")
                    let imaDatax = librox.valueForKey("portada") as? NSData
                    var imax:UIImage? = nil
                    if imaDatax != nil {
                        imax = UIImage(data: imaDatax!)
                    }
                    libroSeleccionado = book(titulo: titulox, autores: autorx!, portada: imax, ISBN: isbnx)
                }
            } catch _ {}
            
            // mostrarDetalle.elLibro = mislibros[(ip?.row)!]
            mostrarDetalle.elLibro = libroSeleccionado
        }
    }


}
