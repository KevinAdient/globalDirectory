//
//  ViewController.swift
//  Directory
//
//  Created by Peter Michael Gits on 4/25/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.createResources()
        appDelegate.importPlants()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

