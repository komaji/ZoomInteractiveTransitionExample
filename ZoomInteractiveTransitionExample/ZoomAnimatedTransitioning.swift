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
    func zoomAnimatedTransitioningSourceWillBegin()
    func zoomAnimatedTransitioningSourceDidEnd()

}

protocol ZoomAnimatedTransitioningDestinationDelegate: class {
    
    func zoomAnimatedTransitioningDestinationImageView() -> UIImageView
    func zoomAnimatedTransitioningDestinationImageViewFrame() -> CGRect
    func zoomAnimatedTransitioningDestinationWillBegin(context: UIViewControllerContextTransitioning)
    func zoomAnimatedTransitioningDestinationDidEnd()
    
}

class ZoomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let operation: UINavigationControllerOperation
    fileprivate weak var sourceDelegate: ZoomAnimatedTransitioningSourceDelegate?
    fileprivate weak var destinationDelegate: ZoomAnimatedTransitioningDestinationDelegate?
    
    required init(operation: UINavigationControllerOperation, sourceDelegate: ZoomAnimatedTransitioningSourceDelegate, destinationDelegate: ZoomAnimatedTransitioningDestinationDelegate) {
        self.operation = operation
        self.sourceDelegate = sourceDelegate
        self.destinationDelegate = destinationDelegate
        
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
        return 3.3
    }
    
}

// MARK: - fileprivate
extension ZoomAnimatedTransitioning {
    
    func pushAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = transitionContext.view(forKey: .from),
            let destinationView = transitionContext.view(forKey: .to),
            let sourceDelegate = sourceDelegate else {
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
        
        sourceDelegate.zoomAnimatedTransitioningSourceWillBegin()
        destinationDelegate?.zoomAnimatedTransitioningDestinationWillBegin(context: transitionContext)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let destinationDelegate = self?.destinationDelegate else { return }
                
                sourceView.alpha = 0.0
                destinationView.alpha = 1.0
                transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
            },
            completion: { [weak self] _ in
                guard let destinationDelegate = self?.destinationDelegate else { return }
                
                transitioningImageView.removeFromSuperview()
                
                sourceDelegate.zoomAnimatedTransitioningSourceDidEnd()
                destinationDelegate.zoomAnimatedTransitioningDestinationDidEnd()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    func popAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let destinationDelegate = destinationDelegate else {
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
        
        sourceDelegate?.zoomAnimatedTransitioningSourceWillBegin()
        destinationDelegate.zoomAnimatedTransitioningDestinationWillBegin(context: transitionContext)
        
        if transitioningImageView.frame.maxY.isLess(than: 0.0) {
            transitioningImageView.frame.origin.y = -transitioningImageView.frame.height
        }
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let sourceDelegate = self?.sourceDelegate else { return }
                
                sourceView.alpha = 1.0
                destinationView.alpha = 0.0
                transitioningImageView.frame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
            },
            completion: { [weak self] _ in
                guard let sourceDelegate = self?.sourceDelegate else { return }
                
                transitioningImageView.removeFromSuperview()
                
                sourceDelegate.zoomAnimatedTransitioningSourceDidEnd()
                destinationDelegate.zoomAnimatedTransitioningDestinationDidEnd()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
}
