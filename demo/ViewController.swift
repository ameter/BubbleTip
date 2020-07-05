//
//  ViewController.swift
//  demo
//
//  Created by Chris on 5/5/18.
//  Copyright © 2018 CodePika. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnTest: UIButton!
    
    var tipTest:BubbleTip! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        // Show 'New Hand' bubble tip
        tipTest = BubbleTip(target: btnTest, text: "Tap this button to do absolutely nothing.")
        tipTest.fillColor = UIColor.blue
        tipTest.alpha = 0.5
        view.addSubview(tipTest)
        view.bringSubviewToFront(tipTest)
    }


}

