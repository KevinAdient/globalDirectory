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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var toReprotingToManager : PeopleEntity = PeopleEntity()
    var currentPerson : PeopleEntity = PeopleEntity()
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
    @IBOutlet weak var reportingToManagerImgView: UIImageView!
    @IBOutlet weak var reprotingToManagerImgButton: UIButton!
    
    @IBOutlet weak var peopleReportsToLbl: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
        reportingToManagerImgView.layer.borderWidth = 1
        reportingToManagerImgView.layer.borderColor = UIColor(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
        self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.currentPersonImgView.image = UIImage(data: self.currentPerson.picture! as Data)
        
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
        currentPersonOfficeLbl.text = (currentPerson.theirAddress?.city!)! + " " + (currentPerson.theirAddress?.streetName1)!
        
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getManagedContext()
        
        //report manager
        let managerFetch : NSFetchRequest<PeopleEntity> = PeopleEntity.fetchRequest()
        
        let managerId: Int64? = currentPerson.theirDepartment?.reportsToId
        if (managerId != nil) {
            managerFetch.predicate = NSPredicate(format: "employeeId == %@", "\(managerId!)")
        }
        
        do {
            let toReportManagers = try context.fetch(managerFetch)
            
            if (toReportManagers.count > 0) {
                toReprotingToManager = toReportManagers[0]
                
                if (toReprotingToManager.middlename != nil) {
                    reprotingToManagerNameLbl.text = (toReprotingToManager.firstname!) + " " + (toReprotingToManager.middlename!) + " "  + (toReprotingToManager.lastname!)
                } else {
                    reprotingToManagerNameLbl.text = (toReprotingToManager.firstname!) + " " + (toReprotingToManager.lastname!)
                }
                
                reprotingToManagerPositionLbl.text = toReprotingToManager.title!
                self.reportingToManagerImgView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.reportingToManagerImgView.image = UIImage(data: self.toReprotingToManager.picture! as Data)
                
                UIView.animate(withDuration: 2.0, animations: {() -> Void in
                    self.reportingToManagerImgView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
                
            } else {
                reprotingToManagerImgButton.isEnabled = false
                reportingToManagerImgView.isHidden = true
            }
            
        } catch {
            print(error)
        }
        
        reportingToLbl.text = currentPerson.firstname! + "'s Reporting Manager"
        
        
        
        //MARK: subs
        let managerFetchSubs : NSFetchRequest<PeopleEntity> = PeopleEntity.fetchRequest()
        let myempId: Int64 = currentPerson.employeeId
        
        do {
            let reportToThis = try context.fetch(managerFetchSubs)
            
            for thisEmp in reportToThis{
                if (thisEmp.theirDepartment?.reportsToId == myempId) {
                    reportSubs.append(thisEmp)
                }
            }
            
        } catch {
            print(error)
        }

        peopleReportsToLbl.text = "People reports to " + currentPerson.firstname!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reprotingToManagerImgBtn(_ sender: Any) {
        let selectedPeople = toReprotingToManager
        let PDVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleDetailViewController") as! PeopleDetailViewController
        PDVC.currentPerson = selectedPeople
        self.navigationController?.pushViewController(PDVC, animated: true)
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

extension PeopleDetailViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportSubs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentSubEmp = reportSubs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subEmpCell", for: indexPath) as! SubEmpCollectionViewCell
        
        if (currentSubEmp.middlename != nil) {
            cell.subEmpNameLbl.text = currentSubEmp.firstname! + " " + currentSubEmp.middlename! + " "  + currentSubEmp.lastname!
        } else {
            cell.subEmpNameLbl.text = currentSubEmp.firstname! + " " + currentSubEmp.lastname!
        }
        
        cell.subEmpImgView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        cell.subEmpImgView.image = UIImage(data: currentSubEmp.picture! as Data)
        cell.subEmpImgView.layer.borderWidth = 1
        cell.subEmpImgView.layer.borderColor = UIColor(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0).cgColor
        UIView.animate(withDuration: 2.0, animations: {() -> Void in
            cell.subEmpImgView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100);
    }
}

extension PeopleDetailViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPeople = reportSubs[indexPath.row]
        let PDVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleDetailViewController") as! PeopleDetailViewController
        PDVC.currentPerson = selectedPeople
        self.navigationController?.pushViewController(PDVC, animated: true)
    }
    
}




