//
//  ZoomPercentDrivenInteractiveTransition.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/05.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class ZoomPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    weak var delegate: ZoomAnimatedInteractiveTransitionDelegate?
    
    var isInteractive = false
    
    @objc func handle(gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            isInteractive = true
            delegate?.zoomAnimatedInteractiveTransitionBegan(at: CGPoint())
        case .changed:
            guard let view = gesture.view else {
                return
            }
            
            let progress = gesture.translation(in: view).x / view.bounds.width
            update(progress)
        case .cancelled:
            isInteractive = false
            break
        case .ended:
            guard let view = gesture.view else {
                return
            }
            
            let progress = gesture.translation(in: view).x / view.bounds.width
            let velocity = gesture.velocity(in: view).x
            if progress.isLess(than: 0.2) && velocity.isLess(than: 1000) {
                cancel()
            } else {
                finish()
            }
            
            isInteractive = false
        default:
            break
        }
    }
    
}
