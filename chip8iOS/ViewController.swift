//
//  ViewController.swift
//  chip8iOS
//
//  Created by Aaron Bonham on 20/08/2016.
//  Copyright © 2016 Code Monastery. All rights reserved.
//

import UIKit

class ChipViewController: UIViewController {
    let chip = chip8()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chip.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

