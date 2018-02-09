import UIKit
import Firebase

class TableContainerView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refreshControl: UIRefreshControl!
    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    
    var recs:[AnyObject] = []
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        readDataFromFB()
        
        refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        } // not required when using UITableViewController
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        readDataFromFB()
        refreshControl.endRefreshing()
    }
    
    func readDataFromFB(){
        var res:[NSDictionary]=[]
        let ref = FIRDatabase.database().reference().child("putcygov").child("Recs").queryLimited(toLast: 10)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                //                print(rest.value!)
                var val:[String] =  rest.value! as! [String]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                let date = dateFormatter.date(from: val[0] as String)
                
                res.append(["time":date!, "type":val[1]])
            }
            print(res)
            self.recs = res
            self.tableView.reloadData()
        })
    }
    
    func getDate(nsdate:NSDate)->String{
        let date = nsdate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        _ = formatter.string(from: date as Date)
        // "2014-07-23 11:01:35 -0700" <-- same date, local, but with seconds
        formatter.timeZone = TimeZone.current
        let utcTimeZoneStr = formatter.string(from: date as Date)
        return utcTimeZoneStr
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recs.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
//        print(type(of: self.recs[indexPath.row]["time"]! as! NSDate) )
        let dstrraw:String = getDate(nsdate: self.recs[indexPath.row]["time"]! as! NSDate)
        let dstr:String = NSString.convertFormatOfDate(date: dstrraw, originalFormat: "yyyy-MM-dd HH:mm:ss ZZZ", destinationFormat: "EEEE dd MMMM, HH:mm")
        cell.textLabel?.text = dstr
        let position:String = self.recs[indexPath.row]["type"]! as! String
        if position == "leave" {
            cell.textLabel?.textAlignment = .right
        }
        else {
            cell.textLabel?.textAlignment = .left
        }
//        cell.detailTextLabel?.textAlignment = .right
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}

extension NSString {
    
    class func convertFormatOfDate(date: String, originalFormat: String, destinationFormat: String) -> String! {
        
        // Orginal format :
        let dateOriginalFormat = DateFormatter()
        dateOriginalFormat.dateFormat = originalFormat      // in the example it'll take "yy MM dd" (from our call)
        
        // Destination format :
        let dateDestinationFormat = DateFormatter()
        dateDestinationFormat.dateFormat = destinationFormat // in the example it'll take "EEEE dd MMMM yyyy" (from our call)
        
        // Convert current String Date to NSDate
        let dateFromString = dateOriginalFormat.date(from: date)
        
        // Convert new NSDate created above to String with the good format
        let dateFormated = dateDestinationFormat.string(from: dateFromString!)
        
        return dateFormated
        
    }
}
