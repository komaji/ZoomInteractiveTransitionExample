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
    var view: UIView?
    var isInteractive = false
    var transitionContext: UIViewControllerContextTransitioning?
    var percentComplete: CGFloat = 0.0
    var transitionDuration: TimeInterval = 0.0
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        guard let transitionCoordinator = fromVC.transitionCoordinator else {
            return
        }
        
        transitionDuration = transitionCoordinator.transitionDuration
    }
    
    var completionSpeed: CGFloat = 1.0
    
    func updateInteractiveTransition(withTranslation translation: CGPoint) {
        guard let transitionContext = transitionContext else {
            return
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        var frame = fromVC.view.frame
        frame.origin.x = translation.x
        frame.origin.y = translation.y
        fromVC.view.frame = frame
        
        if frame.origin.x < 0 {
            percentComplete = 0.0
        } else {
            percentComplete = frame.origin.x / frame.size.width
        }
    }
    
    func finishInteractiveTransition(withVelocity velocity: CGPoint) {
        guard let transitionContext = transitionContext else {
            return
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let frame = fromVC.view.frame
        var finalFrame = frame
        let width = frame.size.width
        let height = frame.size.height
        let dx = width - frame.origin.x
        let dy: CGFloat
        
        if velocity.y < 0 {
            dy = -(height + frame.origin.y)
        } else {
            dy = height - frame.origin.y
        }
        
        if velocity.y.isZero || fabsf(Float(dx / dy)) < fabsf(Float(velocity.x / velocity.y)) { // 右に消える
            finalFrame.origin.x = width
            finalFrame.origin.y += dx * velocity.y / velocity.x
        } else { // 上または下に消える
            finalFrame.origin.x += dy * velocity.x / velocity.y
            finalFrame.origin.y = velocity.y < 0 ? -height : height
        }
        
        // アニメーション時間の計算
        let duration = transitionDuration + TimeInterval((1.0 - percentComplete) / completionSpeed)
        
        // インタラクティブ画面遷移終了
        transitionContext.finishInteractiveTransition()
        
        // 残りのアニメーションを実行
        UIView.animate(
            withDuration: duration,
            animations: {
              fromVC.view.frame = finalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
    
    func cancelInteractiveTransition() {
        guard let transitionContext = transitionContext else {
            return
        }
        
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        
        let frame = transitionContext.initialFrame(for: fromVC)
        
        // アニメーション時間の計算
        let duration = transitionDuration * TimeInterval(percentComplete / completionSpeed)
        
        // インタラクティブ画面遷移キャンセル
        transitionContext.cancelInteractiveTransition()
        
        // キャンセル時のアニメーションを実行
        UIView.animate(
            withDuration: duration,
            animations: {
                fromVC.view.frame = frame
            },
            completion: { _ in
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
