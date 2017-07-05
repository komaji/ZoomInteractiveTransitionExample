//
//  ZoomAnimatedTransitioning.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/01.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

protocol ZoomAnimatedTransitioningSourceDelegate: class {
    
    func zoomAnimatedTransitioningSourceImageView() -> UIImageView
    func zoomAnimatedTransitioningSourceImageViewFrame() -> CGRect

}

protocol ZoomAnimatedTransitioningDestinationDelegate: class {
    
    func zoomAnimatedTransitioningDestinationImageView() -> UIImageView
    func zoomAnimatedTransitioningDestinationImageViewFrame() -> CGRect
    
}

class ZoomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let operation: UINavigationControllerOperation
    
    required init(operation: UINavigationControllerOperation) {
        self.operation = operation
        
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            pushAnimateTransition(using: transitionContext)
        case .pop:
            popAnimateTransition(using: transitionContext)
        default:
            return
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
}

// MARK: - fileprivate
extension ZoomAnimatedTransitioning {
    
    func pushAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = transitionContext.view(forKey: .from),
            let sourceDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningSourceDelegate,
            let destinationView = transitionContext.view(forKey: .to),
            let destinationDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningDestinationDelegate else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = sourceView.backgroundColor
        
        sourceView.alpha = 1.0
        destinationView.alpha = 0.0
        
        let transitioningImageView = UIImageView()
        transitioningImageView.image = sourceDelegate.zoomAnimatedTransitioningSourceImageView().image
        transitioningImageView.frame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
        transitioningImageView.contentMode = sourceDelegate.zoomAnimatedTransitioningSourceImageView().contentMode
        
        containerView.insertSubview(destinationView, belowSubview: sourceView)
        containerView.addSubview(transitioningImageView)
        
        sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = true
        destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                sourceView.alpha = 0.0
                destinationView.alpha = 1.0
                transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
            },
            completion: { _ in
                transitioningImageView.removeFromSuperview()
                
                sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = false
                destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = false

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    func popAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = transitionContext.view(forKey: .to),
            let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate,
            let destinationView = transitionContext.view(forKey: .from),
            let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = sourceView.backgroundColor
        
        sourceView.alpha = 0.0
        destinationView.alpha = 1.0
        
        let transitioningImageView = UIImageView()
        transitioningImageView.image = destinationDelegate.zoomAnimatedTransitioningDestinationImageView().image
        transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
        transitioningImageView.contentMode = destinationDelegate.zoomAnimatedTransitioningDestinationImageView().contentMode
        
        containerView.insertSubview(sourceView, belowSubview: sourceView)
        containerView.addSubview(transitioningImageView)
        
        sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = true
        destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = true
        
        if transitioningImageView.frame.maxY.isLess(than: 0.0) {
            transitioningImageView.frame.origin.y = -transitioningImageView.frame.height
        }
        
        let animations = {
            sourceView.alpha = 1.0
            destinationView.alpha = 0.0
            transitioningImageView.frame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
        }
        
        let completion = {
            transitioningImageView.removeFromSuperview()
            
            sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = false
            destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = false
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        if #available(iOS 10.0, *) {
            let animator = UIViewPropertyAnimator(
                duration: transitionDuration(using: transitionContext),
                curve: .easeOut,
                animations: animations
            )
            animator.addCompletion { _ in completion() }
            
            animator.startAnimation()
        } else {
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0.0,
                options: .curveEaseOut,
                animations: animations,
                completion: { _ in completion() }
            )
        }
    }
    
}
