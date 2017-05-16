//
//  PeopleDetailViewController.swift
//  Directory
//
//  Created by Kevin on 5/16/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit
import CoreData

class PeopleDetailViewController: UIViewController {
    
    var currentPerson : PeopleEntity = PeopleEntity()
    var toReprotingToManager : PeopleEntity = PeopleEntity()
    var reportSubs : [PeopleEntity] = [PeopleEntity]()
    
    @IBOutlet weak var currentPersonImgView: UIImageView!
    @IBOutlet weak var currentPersonNameLbl: UILabel!
    @IBOutlet weak var currentPersonPositioinLbl: UILabel!
    @IBOutlet weak var currentPersonEmailLbl: UILabel!
    @IBOutlet weak var currentPersonPhoneLbl: UILabel!
    @IBOutlet weak var currentPersonMobileLbl: UILabel!
    @IBOutlet weak var currentPersionDeptLbl: UILabel!
    @IBOutlet weak var currentPersonCompLbl: UILabel!
    @IBOutlet weak var currentPersonOfficeLbl: UILabel!
    
    @IBOutlet weak var reportingToLbl: UILabel!
    @IBOutlet weak var reprotingToManagerNameLbl: UILabel!
    @IBOutlet weak var reprotingToManagerPositionLbl: UILabel!
    @IBOutlet weak var reprotingToManagerImgButton: UIButton!
    
    @IBOutlet weak var peopleReportsToLbl: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
        self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.currentPersonImgView.image = UIImage(data: self.currentPerson.picture! as Data)
        
//        UIView.animate(withDuration: 2.0, animations: {() -> Void in
//            self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        }, completion: {(_ finished: Bool) -> Void in
//            UIView.animate(withDuration: 2.0, animations: {() -> Void in
//                self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 1, y: 1)
//            })
//        })
        UIView.animate(withDuration: 2.0, animations: {() -> Void in
            self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        if (currentPerson.middlename != nil) {
            currentPersonNameLbl.text = currentPerson.firstname! + " " + currentPerson.middlename! + " "  + currentPerson.lastname!
        } else {
            currentPersonNameLbl.text = currentPerson.firstname! + " " + currentPerson.lastname!
        }
        currentPersonPositioinLbl.text = currentPerson.title!
        currentPersonEmailLbl.text = currentPerson.email!
        currentPersonPhoneLbl.text = currentPerson.company?.phoneNumber!
        currentPersonMobileLbl.text = currentPerson.mobilephone!
        currentPersionDeptLbl.text = currentPerson.theirDepartment?.departmentName
        currentPersonCompLbl.text = currentPerson.company?.name
        currentPersonOfficeLbl.text = currentPerson.theirAddress?.city!
        
        reportingToLbl.text = currentPerson.firstname! + "'s Reporting Manager"
        
        peopleReportsToLbl.text = "People reports to " + currentPerson.firstname!
        
        
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reprotingToManagerImgBtn(_ sender: Any) {
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
