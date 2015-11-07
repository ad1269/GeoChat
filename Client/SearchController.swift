//
//  SearchController.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/17/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit

class SearchController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet var segment: UISegmentedControl!

    var placeArray = [String]()
    var filteredPlaces = [String]()
    var UserArray = [String?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UserArray = [User().username?,User().username?,User().username?,User().username?,User().username?]
        
        //Load from file
        placeArray = loadPlaceArray()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchFriends() {
        
        
    }
    
    func searchPlaces() {
        
    }
    
    func loadPlaceArray() -> [String] {
        let path = NSBundle.mainBundle().pathForResource("US", ofType: "txt")
        var text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        var infoArr : [String] = text.componentsSeparatedByString("\n")
        
        var cityArr = [String]()
        
        //Load the city names into a new array
        for p in infoArr {
            var pArr = p.componentsSeparatedByString("\t")
            cityArr.append(pArr[1])
        }
        
        return infoArr
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredPlaces = self.placeArray.filter({( place: String) -> Bool in
            let stringMatch = place.rangeOfString(searchText)
            return (stringMatch != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    @IBAction func switchView(sender: UISegmentedControl!) {
        switch segment.selectedSegmentIndex
        {
        case 0:
            searchPlaces()
        case 1:
            searchFriends()
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredPlaces.count
        } else {
            return self.placeArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Get the corresponding candy from our candies array
        var place : String
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            place = filteredPlaces[indexPath.row]
        } else {
            place = placeArray[indexPath.row]
        }
        
        // Configure the cell
        cell.textLabel!.text = place
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
}
