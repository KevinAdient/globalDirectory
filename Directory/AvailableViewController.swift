//
//  AvailableViewController.swift
//  Directory
//
//  Created by Kevin on 5/3/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit

class AvailableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        let customTabBarItem:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Selectedcheck")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "Selectedcheck"))
        customTabBarItem.title = "Available"
        self.tabBarItem = customTabBarItem
        
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
