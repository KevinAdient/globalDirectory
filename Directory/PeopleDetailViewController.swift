//
//  PeopleDetailViewController.swift
//  Directory
//
//  Created by Kevin on 5/16/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import MapKit


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
//        reportingToManagerImgView.layer.shadowColor = UIColor.blue.cgColor
//        reportingToManagerImgView.layer.shadowOpacity = 1
//        reportingToManagerImgView.layer.shadowOffset = CGSize(width: -1, height: 1)
//        reportingToManagerImgView.layer.shadowRadius = 5
//        
//        reportingToManagerImgView.layer.shadowPath = UIBezierPath(rect: reportingToManagerImgView.bounds).cgPath
//        reportingToManagerImgView.layer.shouldRasterize = true
        
//        reportingToManagerImgView.layer.borderWidth = 1
//        reportingToManagerImgView.layer.borderColor = UIColor(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0).cgColor
  
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.currentPersonImgView.image = UIImage(data: self.currentPerson.picture! as Data)
        
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.currentPersonImgView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        if (currentPerson.middlename != nil) {
            currentPersonNameLbl.text = currentPerson.firstname! + " " + currentPerson.middlename! + " "  + currentPerson.lastname!
        } else {
            currentPersonNameLbl.text = currentPerson.firstname! + " " + currentPerson.lastname!
        }
        currentPersonPositioinLbl.text = currentPerson.title!
        
        let underlineAttributeEmail = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedStringEmail = NSAttributedString(string: currentPerson.email!, attributes: underlineAttributeEmail)
        currentPersonEmailLbl.font = UIFont(name: "Domus-Regular", size: 15)
        currentPersonEmailLbl.attributedText = underlineAttributedStringEmail
        
        
        let underlineAttributePhone = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedStringPhone = NSAttributedString(string: currentPerson.deskphone!, attributes: underlineAttributePhone)
        currentPersonPhoneLbl.font = UIFont(name: "Domus-Regular", size: 15)
        currentPersonPhoneLbl.attributedText = underlineAttributedStringPhone
        
        let underlineAttributeMobile = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedStringMobile = NSAttributedString(string: currentPerson.mobilephone!, attributes: underlineAttributeMobile)
        currentPersonMobileLbl.font = UIFont(name: "Domus-Regular", size: 15)
        currentPersonMobileLbl.attributedText = underlineAttributedStringMobile
        
        currentPersionDeptLbl.text = currentPerson.theirDepartment?.departmentName
        currentPersonCompLbl.text = currentPerson.company?.name
        
        let underlineAttributeAddress = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedStringAddress = NSAttributedString(string: (currentPerson.theirAddress?.city!)! + " " + (currentPerson.theirAddress?.streetName1)!, attributes: underlineAttributeAddress)
        currentPersonOfficeLbl.font = UIFont(name: "Domus-Regular", size: 15)
        currentPersonOfficeLbl.attributedText = underlineAttributedStringAddress
        
        
        
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
                
                
                UIView.animate(withDuration: 0.5, animations: {() -> Void in
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
    
    
    //change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func reprotingToManagerImgBtn(_ sender: Any) {
        let selectedPeople = toReprotingToManager
        let PDVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleDetailViewController") as! PeopleDetailViewController
        PDVC.currentPerson = selectedPeople
        self.navigationController?.pushViewController(PDVC, animated: true)
    }
    
    @IBAction func callBusinessPhoneBtnClicked(_ sender: Any) {
        let businessPhone : String = (currentPerson.deskphone)!
        callNumber(phoneNumber: businessPhone)
    }
    @IBAction func callPersonalPhoneBtnClicked(_ sender: Any) {
        let personalPhone : String = (currentPerson.mobilephone)!
        callNumber(phoneNumber: personalPhone)
    }
    
    @IBAction func sendEmailBtnClicked(_ sender: Any) {
        self.sendEmail()
    }
    
    @IBAction func goToAddressClicked(_ sender: Any) {
        let lat = currentPerson.theirAddress?.gpsLatitude
        let long = currentPerson.theirAddress?.gpsLongitude
        let placeStr = (currentPerson.theirAddress?.city!)! + " " + (currentPerson.theirAddress?.streetName1)!
        openMapForPlace(lat: lat!, long: long!, placeName: placeStr)
    }
    
    //open map function
    func openMapForPlace(lat: CLLocationDegrees, long: CLLocationDegrees, placeName: String) {
        
        let myTargetCLLocation:CLLocation = CLLocation(latitude: lat, longitude: long) as CLLocation
        let coordinate = CLLocationCoordinate2DMake(myTargetCLLocation.coordinate.latitude,myTargetCLLocation.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    //make a call method
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func openSkypeClicked(_ sender: Any) {
//        let skype: NSURL = NSURL(string: String(format: "skype:"))! //add object skype like this
        let skype: NSURL = NSURL(string: String(format: "ms-sfb://start"))!
        if UIApplication.shared.canOpenURL(skype as URL) {
            UIApplication.shared.open(skype as URL, options: [:], completionHandler: nil)
        }
        else {
            // skype not Installed in your Device
            let itunes: NSURL = NSURL(string: String(format: "https://itunes.apple.com/us/app/skype-for-business-formerly-lync-2013/id605841731?mt=8"))!
            UIApplication.shared.open(itunes as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    
    //Mark: add shadow on round corner imgeview
    
    
    

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
//        cell.subEmpImgView.layer.borderWidth = 1
//        cell.subEmpImgView.layer.borderColor = UIColor(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0).cgColor
//        cell.subEmpImgView.layer.shadowColor = UIColor.blue.cgColor
//        cell.subEmpImgView.layer.shadowOpacity = 1
//        cell.subEmpImgView.layer.shadowOffset = CGSize.zero
//        cell.subEmpImgView.layer.shadowRadius = 5
//         cell.subEmpImgView.clipsToBounds = true
//        cell.subEmpImgView.layer.shadowPath = UIBezierPath(rect: cell.subEmpImgView.bounds).cgPath
        
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
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

extension PeopleDetailViewController : MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            let emailStr = currentPerson.email!
            mail.setToRecipients([emailStr])
            mail.setSubject("Hello!")
            mail.setMessageBody("<p>Hello from Adient!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}





