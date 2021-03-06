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
    var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragDismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        self.blurEffectView.addGestureRecognizer(panGestureRecognizer)
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
    @objc func dragDismissController(sender: UIPanGestureRecognizer) {
        let progress = abs(sender.translation(in: blurEffectView).x / blurEffectView.bounds.size.width)
        
        let translation = sender.translation(in: blurEffectView)
        
        guard translation.x <= 0 else { return }
        presentedView?.frame.origin = CGPoint(x: translation.x, y: 0)
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: blurEffectView)
            
            if dragVelocity.x <= -500 {
                
                self.presentedViewController.dismiss(animated: true, completion: nil)
            }else if progress > 0.55 {
                
                self.presentedViewController.dismiss(animated: true, completion: nil)
                
            }else {
                UIView.animate(withDuration: 0.3) {
                    self.presentedView?.frame.origin = CGPoint(x: 0, y: 0)
                }
            }
            
        }
    }
}
class CustomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPresenting {
            return UIDevice.isiPad ? 0.5 : 0.4
        }else {
            return UIDevice.isiPad ? 0.6 : 0.3
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
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),delay: 0,options: .curveEaseIn,animations: {
            toView.frame.origin.x += toView.bounds.width
        }) { completed in
            print(toView.frame.origin.x)
            //画面遷移が完了していない(x=0)場合画面を削除
            if toView.frame.origin.x == 0 {
                transitionContext.completeTransition(completed)
            }else {
                if transitionContext.transitionWasCancelled {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
    }
    func animateDissmissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),delay: 0,options: .curveEaseOut,animations: {
            fromView.frame.origin.x = -containerView.bounds.width
        }) { _ in
            if transitionContext.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}



