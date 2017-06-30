//
//  VehicleService.swift
//  VehiclesDemo
//
//  Created by Marcelo Mogrovejo on 6/30/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import CoreData


class VehicleService {
    
    internal var moc: NSManagedObjectContext!
    internal let apiBaseUrl: String = "https://api.edmunds.com/api/vehicle/v2/makes?"
    internal let apiKey: String = "u7ahp8sdr8fzya566ncg6w82"
    
    
    internal init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    deinit {
        self.moc = nil
    }
    
    func populateLocalDataSource() {
        let privateContext = CoreDataStack().persistentContainer.newBackgroundContext()
        
        let filters = ["state": "used", "year": "2014", "view": "basic", "format": "json"]
        let apiUrl = getFullApiUrl(queryStringFilters: filters)

        let task = URLSession.shared.dataTask(with: apiUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            let httpResponse = response as! HTTPURLResponse
            
            if httpResponse.statusCode == 200 {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    let jsonArray = jsonResult.value(forKey: "makes") as! NSArray
                    
                    for json in jsonArray {
                        let vehicleData = json as! [String: AnyObject]
                        
                        let maker = Maker(context: privateContext)
                        
                        guard let makerId = vehicleData["id"] else { return }
                        maker.id = (makerId as? Int16)!
                        
                        guard let makerName = vehicleData["name"] else { return }
                        maker.name = makerName as? String
                        
                        guard let makerNiceName = vehicleData["niceName"] else { return }
                        maker.niceName = makerNiceName as? String
                        
                        let models = maker.models?.mutableCopy() as! NSMutableSet
                        
                        guard let modelArray = vehicleData["models"] as? NSArray else { return }
                        for mod in modelArray {
                            let modelData = mod as! [String: AnyObject]
                            
                            let model = Model(context: privateContext)
                            
                            let modelId = modelData["id"] as? Int16
                            model.id = modelId!

                            let modelName = modelData["name"] as? String
                            model.name = modelName
                            
                            let modelNiceName = modelData["niceName"] as? String
                            model.niceName = modelNiceName
                            
                            let years = model.years?.mutableCopy() as! NSMutableSet
                            
                            guard let yearArray = vehicleData["years"] as? NSArray else { return }
                            for modelYear in yearArray {
                                let yearData = modelYear as! [String: AnyObject]
                                
                                let year = Year(context: privateContext)
                                
                                let yearId = yearData["id"] as? Int16
                                year.id = yearId!
                                
                                let yearNumber = yearData["year"] as? Int16
                                year.year = yearNumber!
                                
                                years.add(year)
                            }
                            
                            // Set year into model for core data
                            model.years = years.copy() as? NSSet
                            
                            models.add(model)
                        }
                        
                        // Set the model into maker for core data
                        maker.models = models.copy() as? NSSet
                    }

                    try privateContext.save()
                    
                } catch let error as NSError {
                    print("Error in parsing JSON data: \(error.localizedDescription)")
                }
            }
            
            
        }
        task.resume()
    }
    
    // MARK: Private methods
    
    private func getFullApiUrl(queryStringFilters: [String: String]) -> URL {
        
        let state = queryStringFilters["state"] ?? "userd"
        let year = queryStringFilters["year"] ?? "2014"
        let view = queryStringFilters["view"] ?? "basic"
        let format = queryStringFilters["format"] ?? "json"
        let urlString = apiBaseUrl + "state=\(state)&year=\(year)&view=\(view)&fmt=\(format)&api_key=" + apiKey
        
        let url = URL(string: urlString)
        
        return url!
        
    }
}
