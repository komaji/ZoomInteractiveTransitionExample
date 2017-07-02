//
//  ZoomInteractiveTransition.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/02.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

protocol ZoomInteractiveTransitionDelegate: class {
    
    func zoomInteractiveTransitionBegan()
    func zoomInteractiveTransitionFinish()
    
}

class ZoomInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var context: UIViewControllerContextTransitioning?
    var operation: UINavigationControllerOperation?
    
    weak var delegate: ZoomInteractiveTransitionDelegate?
    
    @objc func handle(recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            delegate?.zoomInteractiveTransitionBegan()
        case .changed:
            guard let view = recognizer.view else {
                return
            }
            
            let progress = recognizer.translation(in: view).x / view.bounds.width
            update(progress)
        case .cancelled, .ended:
            guard let view = recognizer.view else {
                return
            }
            
            let progress = recognizer.translation(in: view).x / view.bounds.width
            let velocity = recognizer.velocity(in: view).x
            if progress > 0.33 || velocity > 1000.0 {
                finish()
            } else {
//                cancel()
                cancelTransition(transitionContext: context!, operation: operation!, progress: progress)
            }
            
            delegate?.zoomInteractiveTransitionFinish()
        default:
            break
        }
    }
    
    func cancelTransition(transitionContext: UIViewControllerContextTransitioning, operation: UINavigationControllerOperation, progress: CGFloat) {
        guard let transitioningImageViewIndex = transitionContext.containerView.subviews.index(where: { $0 is UIImageView}) else {
                transitionContext.cancelInteractiveTransition()
                
                return
        }
        
        let transitioningImageView = transitionContext.containerView.subviews[transitioningImageViewIndex]
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        if toVC is ZoomAnimatedTransitioningDestinationDelegate,
            let fromVC = fromVC as? ZoomAnimatedTransitioningSourceDelegate,
            operation == .push {
            
            guard let sourceView = transitionContext.view(forKey: .from),
                let destinationView = transitionContext.view(forKey: .to) else {
                    transitionContext.cancelInteractiveTransition()
                    
                    return
            }
            
            UIView.animate(
                withDuration: TimeInterval(CGFloat(0.3) * (CGFloat(1.0) - progress)),
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    sourceView.alpha = 1.0
                    destinationView.alpha = 0.0
                    transitioningImageView.frame = fromVC.zoomAnimatedTransitioningSourceImageViewFrame()
                },
                completion: { _ in
                    transitionContext.cancelInteractiveTransition()
                }
            )
            
        } else if toVC is ZoomAnimatedTransitioningSourceDelegate,
            let fromVC = fromVC as? ZoomAnimatedTransitioningDestinationDelegate,
            operation == .pop {
            
            guard let sourceView = transitionContext.view(forKey: .to),
                let destinationView = transitionContext.view(forKey: .from) else {
                    transitionContext.cancelInteractiveTransition()
                    
                    return
            }
            
            UIView.animate(
                withDuration: TimeInterval(CGFloat(0.3) * (CGFloat(1.0) - progress)),
                delay: 0.0,
                options: .curveEaseOut,
                animations: {
                    sourceView.alpha = 0.0
                    destinationView.alpha = 1.0
                    transitioningImageView.frame = fromVC.zoomAnimatedTransitioningDestinationImageViewFrame()
                },
                completion: { _ in
                    transitionContext.cancelInteractiveTransition()
                }
            )

        } else {
            transitionContext.cancelInteractiveTransition()
        }
    }
    
}
