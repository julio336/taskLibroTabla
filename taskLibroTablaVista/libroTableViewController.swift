//
//  libroTableViewController.swift
//  taskLibroTablaVista
//
//  Created by Julio Ahuactzin on 14/07/16.
//  Copyright © 2016 Julio Ahuactzin. All rights reserved.
//

import UIKit

class libroTableViewController: UITableViewController {

    var mislibros: [book] = [book]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Mis libros"
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
        return mislibros.count

    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IdentCelda", forIndexPath: indexPath)
        cell.textLabel?.text = self.mislibros[indexPath.row].titulo
        return cell

    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetalleSegue" {
            let mostrarDetalle = segue.destinationViewController as! DetallesViewController
            
            let ip = self.tableView.indexPathForSelectedRow
            
            mostrarDetalle.elLibro = mislibros[(ip?.row)!]
        }
        
        
        
    }
    
  
}
