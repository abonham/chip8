//
//  ViewController.swift
//  chip8iOS
//
//  Created by Aaron Bonham on 20/08/2016.
//  Copyright © 2016 Code Monastery. All rights reserved.
//

import UIKit

class ChipViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    let chip = chip8()

    override func viewDidLoad() {
        super.viewDidLoad()
        chip.initialize()
        DispatchQueue.global(qos: .userInitiated).async {
            var now = NSDate()
            while true {
                if now.timeIntervalSinceNow < -0.001
                {
                    self.chip.emulateCycle()
                    self.updateImageView(image: self.chip.backBuffer)
                    now = NSDate()
                }
            }
        }
    }
    
    func updateImageView(image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

