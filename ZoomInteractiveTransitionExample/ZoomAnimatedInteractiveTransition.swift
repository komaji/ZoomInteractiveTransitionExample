//
//  ZoomAnimatedInteractiveTransition.swift
//  ZoomInteractiveTransitionExample
//
//  Created by kojima.t on 2017/07/03.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

protocol ZoomAnimatedInteractiveTransitionDelegate: class {
    
    func zoomAnimatedInteractiveTransitionBegan(at point: CGPoint)
    
}

class ZoomAnimatedInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    weak var delegate: ZoomAnimatedInteractiveTransitionDelegate?
    
    var isInteractive = false
    var transitionContext: UIViewControllerContextTransitioning?
    var transitioningImageView: UIImageView?
    var progress: CGFloat = 0.0
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate,
            let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
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
        self.transitioningImageView = transitioningImageView
        
        containerView.insertSubview(sourceView, belowSubview: sourceView)
        containerView.addSubview(transitioningImageView)
        
        sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = true
        destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = true
        
        if transitioningImageView.frame.maxY.isLess(than: 0.0) {
            transitioningImageView.frame.origin.y = -transitioningImageView.frame.height
        }
        
        self.transitionContext = transitionContext
    }
    
    func updateInteractiveTransition(withTranslation translation: CGPoint) {
        guard let transitionContext = transitionContext,
            let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let transitioningImageView = transitioningImageView,
            let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate,
            let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
                return
        }
        
        progress = translation.x / destinationView.bounds.width
        
        sourceView.alpha = (1.0 * progress)
        destinationView.alpha = 1.0 - (1.0 * progress)
        
        let sourceImageViewFrame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
        let destinationImageViewFrame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
        
        let dx = sourceImageViewFrame.origin.x - destinationImageViewFrame.origin.x
        let dy = sourceImageViewFrame.origin.y - destinationImageViewFrame.origin.y
        let dw = sourceImageViewFrame.width - destinationImageViewFrame.width
        let dh = sourceImageViewFrame.height - destinationImageViewFrame.height
        
        transitioningImageView.frame = CGRect(
            x: destinationImageViewFrame.minX + dx * progress,
            y: destinationImageViewFrame.minY + dy * progress,
            width: destinationImageViewFrame.width + dw * progress,
            height: destinationImageViewFrame.height + dh * progress
        )
    }
    
    func finishInteractiveTransition(withVelocity velocity: CGPoint) {
        guard let transitionContext = transitionContext,
            let transitionCoordinator = transitionContext.viewController(forKey: .to)?.transitionCoordinator else {
            return
        }
        
        // アニメーション時間の計算
        let duration = transitionCoordinator.transitionDuration * TimeInterval(1.0 - progress)
        
        // インタラクティブ画面遷移終了
        transitionContext.finishInteractiveTransition()
        
        // 残りのアニメーションを実行
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let transitionContext = self?.transitionContext,
                    let sourceView = transitionContext.view(forKey: .to),
                    let destinationView = transitionContext.view(forKey: .from),
                    let transitioningImageView = self?.transitioningImageView,
                    let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate else {
                        return
                }
                
                sourceView.alpha = 1.0
                destinationView.alpha = 0.0
                transitioningImageView.frame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
            },
            completion: { [weak self] _ in
                guard let transitionContext = self?.transitionContext,
                    let transitioningImageView = self?.transitioningImageView,
                    let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate,
                    let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
                        return
                }
                
                sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = false
                destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = false
                
                transitioningImageView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            }
        )
    }
    
    func cancelInteractiveTransition() {
        guard let transitionContext = transitionContext,
            let transitionCoordinator = transitionContext.viewController(forKey: .to)?.transitionCoordinator else {
                return
        }
        
        // アニメーション時間の計算
        let duration = transitionCoordinator.transitionDuration * TimeInterval(progress)
        
        // インタラクティブ画面遷移キャンセル
        transitionContext.cancelInteractiveTransition()
        
        // キャンセル時のアニメーションを実行
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let transitionContext = self?.transitionContext,
                    let sourceView = transitionContext.view(forKey: .to),
                    let destinationView = transitionContext.view(forKey: .from),
                    let transitioningImageView = self?.transitioningImageView,
                    let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
                        return
                }
                
                sourceView.alpha = 0.0
                destinationView.alpha = 1.0
                transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
            },
            completion: { [weak self] _ in
                guard let transitionContext = self?.transitionContext,
                    let transitioningImageView = self?.transitioningImageView,
                    let sourceDelegate = transitionContext.viewController(forKey: .to) as? ZoomAnimatedTransitioningSourceDelegate,
                    let destinationDelegate = transitionContext.viewController(forKey: .from) as? ZoomAnimatedTransitioningDestinationDelegate else {
                        return
                }
                
                sourceDelegate.zoomAnimatedTransitioningSourceImageView().isHidden = false
                destinationDelegate.zoomAnimatedTransitioningDestinationImageView().isHidden = false
                
                transitioningImageView.removeFromSuperview()
                
                transitionContext.completeTransition(false)
            }
        )
    }
    
    func handle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let view = gesture.view else {
                return
            }
            
            isInteractive = true
            let point = gesture.location(in: view)
            delegate?.zoomAnimatedInteractiveTransitionBegan(at: point)
        case .changed:
            guard let view = gesture.view else {
                return
            }
            
            let translation = gesture.translation(in: view)
            updateInteractiveTransition(withTranslation: translation)
        case .cancelled:
            break
        case .ended:
            guard let view = gesture.view else {
                return
            }
            
            let velocity = gesture.velocity(in: view)
            let progress = gesture.translation(in: view).x / view.bounds.width
            
            if progress.isLess(than: 0.2) && velocity.x.isLess(than: 1000) {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition(withVelocity: velocity)
            }
            
            isInteractive = false
        default:
            break
        }
        
    }

}
