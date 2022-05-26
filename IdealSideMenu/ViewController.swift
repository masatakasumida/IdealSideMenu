//
//  ViewController.swift
//  IdealSideMenu
//
//  Created by 住田雅隆 on 2022/05/15.
//

import UIKit

class ViewController: UIViewController {
    
    private var interactionController = UIPercentDrivenInteractiveTransition()
    private var interactionHasStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        panGesture.edges = .left
        view.addGestureRecognizer(panGesture)
        interactionController.completionCurve = .linear
        
    }
    
    @objc func panGestureRecognizerAction(sender: UIScreenEdgePanGestureRecognizer) {
        let progress = abs(sender.translation(in: view).x / view.bounds.size.width) + 0.3//開始位置の調整
        
        switch sender.state {
        case .began:
            interactionHasStarted = true
            
            showMiracle()
            
        case .changed:
            interactionController.update(progress)
           // print(progress)
        case .ended:
            
            interactionHasStarted = false
            let dragVelocity = sender.velocity(in: view)
            
            if dragVelocity.x >= 500 {                
                interactionController.finish()
            }else if progress > 0.58 {
                interactionController.finish()
            }else {
                interactionController.cancel()
            }
        case .cancelled:
            interactionHasStarted = false
            interactionController.cancel()
            
        default:
            break
        }
    }
    
    func showMiracle() {
        let sideMenuVC = storyboard?.instantiateViewController(identifier: "sideMenu")as! SideMenuViewController
        sideMenuVC.modalPresentationStyle = .custom
        
        sideMenuVC.transitioningDelegate = self
        present(sideMenuVC, animated: true, completion: nil)
    }
    
    @IBAction func onButton(_ sender: Any) {
        showMiracle()
    }
    
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimatedTransitioning(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimatedTransitioning(isPresenting: false)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard interactionHasStarted else { return nil }
        return  interactionController
    }
}
