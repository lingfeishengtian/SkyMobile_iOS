//
//  InhalationExercise.swift
//  SkyMobile
//
//  Created by Hunter Han on 5/18/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import UIKit

class InhalationExercise: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var announcementLabel: UILabel!
    
    let importantUtils = ImportantUtils()
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientColorSet =
        [UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1).cgColor,
         UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor,
         UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor,
         UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1).cgColor,
         UIColor(red: 108/255, green: 91/255, blue: 123/255, alpha: 1).cgColor,
         UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 1).cgColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func organizeGradients(){
        for gradIndex in 0...gradientColorSet.count - 1{
            if gradIndex == gradientColorSet.count - 1{
                gradientSet.append([gradientColorSet[gradIndex], gradientColorSet[0]])
            }else{
                gradientSet.append([gradientColorSet[gradIndex], gradientColorSet[gradIndex + 1]])
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        organizeGradients()
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        self.view.layer.insertSublayer(gradient, at: 0)
        
        animateGradient()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
    
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.delegate = self
        gradientChangeAnimation.duration = 5.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    }
}
