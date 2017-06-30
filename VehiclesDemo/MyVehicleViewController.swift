//
//  MyVehicleViewController.swift
//  VehiclesDemo
//
//  Created by Marcelo Mogrovejo on 6/30/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import CoreData


class MyVehicleViewController: UIViewController {

    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request:  NSFetchRequest<Maker> = Maker.fetchRequest()
        request.predicate = NSPredicate(format: "make = 'Subaru'")
        
        do {
//            let results = try moc.fetch(request)
//            let firstResult = results.first
//            print("Maker: \(firstResult.make))
        } catch {
            fatalError()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

