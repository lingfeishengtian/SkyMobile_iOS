//
//  LaunchingScreen.swift
//  SkyMobile
//
//  Created by Hunter Han on 5/14/19.
//  Copyright © 2019 Hunter Han. All rights reserved.
//

import UIKit

class LaunchingScreen: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var lblWelcom: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
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
        
        btnLogin.layer.borderWidth = 1.0
        btnLogin.layer.borderColor = UIColor.black.cgColor
        btnHelp.layer.borderWidth = 1.0
        btnHelp.layer.borderColor = UIColor.black.cgColor
        
        let startPos = self.view.frame.midX - (self.lblWelcom.frame.width/2)
        lblWelcom.frame = CGRect(x: self.view.frame.midX - self.lblWelcom.frame.width/2, y: self.view.frame.midY, width: lblWelcom.frame.width, height: lblWelcom.frame.height)
        btnLogin.layer.cornerRadius = 5.0
        btnHelp.layer.cornerRadius = 5.0
        
        btnLogin.frame = CGRect(x: (-self.btnLogin.frame.width), y: 250, width: self.btnLogin.frame.width, height: self.btnLogin.frame.height)
        btnHelp.frame = CGRect(x: (-self.btnHelp.frame.width), y: 350, width: self.btnLogin.frame.width, height: self.btnHelp.frame.height)
        
        UIView.animateKeyframes(withDuration: 2.5, delay: 0.5, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.lblWelcom.frame = CGRect(x: startPos, y: 100, width: self.lblWelcom.frame.width, height: self.lblWelcom.frame.height)})
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1.0, animations: {
                self.btnLogin.frame.origin.x += self.btnLogin.frame.width + (self.view.frame.midX - self.btnLogin.frame.width/2)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1.0, animations: {
                self.btnHelp.frame.origin.x += self.btnHelp.frame.width + (self.view.frame.midX - self.btnHelp.frame.width/2)
            })
        }, completion: nil)
    }
    
    @IBAction func launchLogin(_ sender: Any) {
        if ImportantUtils.isConnectedToNetwork(){
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let vc : ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            present(vc, animated: false, completion: nil)
        }else{
            importantUtils.DisplayErrorMessage(message: "Internet is required to login to SkyMobile.")
        }
    }
    
    @IBAction func needHelp(_ sender: Any) {
        importantUtils.DisplayErrorMessage(message: "Stress Relief has been taken down for this version due to its incompleteness.")
//        let storyboard = UIStoryboard(name: "StressReliefAndEncouragement", bundle: Bundle.main)
//        let vc : InhalationExercise = storyboard.instantiateViewController(withIdentifier: "InhalationExercise") as! InhalationExercise
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromRight
//        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//        view.window!.layer.add(transition, forKey: kCATransition)
//        present(vc, animated: false, completion: nil)
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
