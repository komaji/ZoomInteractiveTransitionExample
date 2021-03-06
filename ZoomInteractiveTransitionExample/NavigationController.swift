//
//  NavigationController.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/02.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
//    var zoomAnimatedInteractiveTransition = ZoomAnimatedInteractiveTransition()
    var zoomAnimatedInteractiveTransition = ZoomPercentDrivenInteractiveTransition()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        delegate = self
    }
    
}

extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomAnimatedTransitioningSourceDelegate
            && toVC is ZoomAnimatedTransitioningDestinationDelegate
            && operation == .push {
            return ZoomAnimatedTransitioning(operation: operation)
        } else if toVC is ZoomAnimatedTransitioningSourceDelegate
            && fromVC is ZoomAnimatedTransitioningDestinationDelegate
            && operation == .pop {
            return ZoomAnimatedTransitioning(operation: operation)
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return zoomAnimatedInteractiveTransition.isInteractive ? zoomAnimatedInteractiveTransition : nil
    }
}
