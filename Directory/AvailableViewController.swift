//
//  AvailableViewController.swift
//  Directory
//
//  Created by Kevin on 5/3/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit


@objc class statusObj: NSObject {
    
    static let sharedInstance = statusObj()
    
    public override init(){}
    
    var statusBoolArray = [true, false, false, false]
    
}

class AvailableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myStatusArray = ["Available", "Busy", "Do not distrub", "Appear away"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AvailableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myStatusArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as! StatusTableViewCell
        cell.statusLbl.text = myStatusArray[indexPath.row]
        cell.statusImgView.image = UIImage(named: myStatusArray[indexPath.row])
        if (statusObj.sharedInstance.statusBoolArray[indexPath.row]) {
            cell.isSelectedImgView.image = UIImage(named: "dotselected")
        } else {
            cell.isSelectedImgView.image = nil
        }
        return cell
    }
    
}

extension AvailableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0...3 {
            statusObj.sharedInstance.statusBoolArray[i] = false
        }
        statusObj.sharedInstance.statusBoolArray[indexPath.row] = true
        
        if let items = self.tabBarController?.tabBar.items {
            
            let tabBarItem = items[4]
            let tabBarImage = UIImage(named: myStatusArray[indexPath.row])!
            tabBarItem.image = tabBarImage.withRenderingMode(.alwaysOriginal)
            tabBarItem.selectedImage = tabBarImage.withRenderingMode(.alwaysOriginal)
        }
        
        tableView.reloadData()
    }
    
}
