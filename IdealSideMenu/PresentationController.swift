//
//  PresentationController.swift
//  IdealSideMenu
//
//  Created by 住田雅隆 on 2022/05/15.
//


import UIKit

class PresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerSize = containerView?.frame.size else {
            return CGRect.zero
        }
        let width = UIDevice.isiPad ? 300 : containerSize.width * 0.8
        return CGRect(x: 0, y: 0, width: width, height: containerSize.height)
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0.7
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
            
        })
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
class CustomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPresenting {
            return 0.4
        }else {
            return 0.2
        }
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard transitionContext.isAnimated else { return }
        
        if isPresenting {
            animatePresentTransition(using: transitionContext)
        } else {
            animateDissmissalTransition(using: transitionContext)
        }
    }
    func animatePresentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.frame.origin.x -= -toView.bounds.width
        }) { completed in
            print(toView.frame)
            transitionContext.completeTransition(completed)
        }
    }
    func animateDissmissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.frame.origin.x = -containerView.bounds.width
        }) { _ in
            if transitionContext.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}



