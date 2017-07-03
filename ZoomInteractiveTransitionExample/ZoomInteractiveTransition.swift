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
    
}

class ZoomInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
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
                cancel()
            }
        default:
            break
        }
    }
    
}
