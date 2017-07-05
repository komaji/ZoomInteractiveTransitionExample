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
    weak var sourceDelegate: ZoomAnimatedTransitioningSourceDelegate?
    weak var destinationDelegate: ZoomAnimatedTransitioningDestinationDelegate?
    
    var view: UIView?
    var isInteractive = false
    var transitionContext: UIViewControllerContextTransitioning?
    var transitioningImageView: UIImageView?
    var percentComplete: CGFloat = 0.0
    var transitionDuration: TimeInterval = 0.0
    var completionSpeed: CGFloat = 0.7
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let destinationDelegate = destinationDelegate else {
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
        
        sourceDelegate?.zoomAnimatedTransitioningSourceWillBegin()
        destinationDelegate.zoomAnimatedTransitioningDestinationWillBegin(context: transitionContext)
        
        if transitioningImageView.frame.maxY.isLess(than: 0.0) {
            transitioningImageView.frame.origin.y = -transitioningImageView.frame.height
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let transitionCoordinator = fromVC.transitionCoordinator else {
            return
        }

        transitionDuration = transitionCoordinator.transitionDuration
    }
    
    func updateInteractiveTransition(withTranslation translation: CGPoint) {
        guard let transitionContext = transitionContext else {
            return
        }
    
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let transitioningImageView = transitioningImageView,
            let sourceDelegate = sourceDelegate,
            let destinationDelegate = destinationDelegate else {
                return
        }
        
        sourceView.alpha = (1.0 * percentComplete)
        destinationView.alpha = 1.0 - (1.0 * percentComplete)
        
        let sourceImageViewFrame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
        let destinationImageViewFrame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
        
        let dx = sourceImageViewFrame.origin.x - destinationImageViewFrame.origin.x
        let dy = sourceImageViewFrame.origin.y - destinationImageViewFrame.origin.y
        let dw = sourceImageViewFrame.width - destinationImageViewFrame.width
        let dh = sourceImageViewFrame.height - destinationImageViewFrame.height
        
        transitioningImageView.frame = CGRect(
            x: destinationImageViewFrame.minX + dx * percentComplete,
            y: destinationImageViewFrame.minY + dy * percentComplete,
            width: destinationImageViewFrame.width + dw * percentComplete,
            height: destinationImageViewFrame.height + dh * percentComplete
        )
        
        percentComplete = translation.x / sourceView.bounds.width
    }
    
    func finishInteractiveTransition(withVelocity velocity: CGPoint) {
        guard let transitionContext = transitionContext else {
            return
        }
        
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let transitioningImageView = transitioningImageView else {
                return
        }
        
        // アニメーション時間の計算
        let duration = transitionDuration + TimeInterval((1.0 - percentComplete) / completionSpeed)
        
        // インタラクティブ画面遷移終了
        transitionContext.finishInteractiveTransition()
        
        // 残りのアニメーションを実行
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let sourceDelegate = self?.sourceDelegate else { return }
                
                sourceView.alpha = 1.0
                destinationView.alpha = 0.0
                transitioningImageView.frame = sourceDelegate.zoomAnimatedTransitioningSourceImageViewFrame()
            },
            completion: { [weak self] _ in
                self?.sourceDelegate?.zoomAnimatedTransitioningSourceDidEnd()
                self?.destinationDelegate?.zoomAnimatedTransitioningDestinationDidEnd()
                
                transitioningImageView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            }
        )
    }
    
    func cancelInteractiveTransition() {
        guard let transitionContext = transitionContext else {
            return
        }
        
        guard let sourceView = transitionContext.view(forKey: .to),
            let destinationView = transitionContext.view(forKey: .from),
            let transitioningImageView = transitioningImageView else {
                return
        }
        
        // アニメーション時間の計算
        let duration = transitionDuration * TimeInterval(percentComplete / completionSpeed)
        
        // インタラクティブ画面遷移キャンセル
        transitionContext.cancelInteractiveTransition()
        
        // キャンセル時のアニメーションを実行
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let destinationDelegate = self?.destinationDelegate else { return }
                
                sourceView.alpha = 0.0
                destinationView.alpha = 1.0
                transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
            },
            completion: { [weak self] _ in
                self?.sourceDelegate?.zoomAnimatedTransitioningSourceDidEnd()
                self?.destinationDelegate?.zoomAnimatedTransitioningDestinationDidEnd()
                
                transitioningImageView.removeFromSuperview()
                
                transitionContext.completeTransition(false)
            }
        )
    }
    
    func handle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: view)
            isInteractive = true
            delegate?.zoomAnimatedInteractiveTransitionBegan(at: point)
        case .changed:
            let translation = gesture.translation(in: view)
            updateInteractiveTransition(withTranslation: translation)
        case .cancelled:
            break
        case .ended:
            let velocity = gesture.velocity(in: view)
            if velocity.x <= 0 {
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
