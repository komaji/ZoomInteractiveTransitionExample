//
//  NavigationController.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/02.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
//    var zoomInteractiveTransition: ZoomInteractiveTransition?
    var zoomAnimatedInteractiveTransition: ZoomAnimatedInteractiveTransition?
    
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
        if let fromVC = fromVC as? ZoomAnimatedTransitioningSourceDelegate, let toVC = toVC as? ZoomAnimatedTransitioningDestinationDelegate, operation == .push {
            zoomAnimatedInteractiveTransition?.sourceDelegate = fromVC
            zoomAnimatedInteractiveTransition?.destinationDelegate = toVC
            
            return ZoomAnimatedTransitioning(operation: operation, sourceDelegate: fromVC, destinationDelegate: toVC)
        } else if let toVC = toVC as? ZoomAnimatedTransitioningSourceDelegate, let fromVC = fromVC as? ZoomAnimatedTransitioningDestinationDelegate, operation == .pop {
            zoomAnimatedInteractiveTransition?.sourceDelegate = toVC
            zoomAnimatedInteractiveTransition?.destinationDelegate = fromVC

            return ZoomAnimatedTransitioning(operation: operation, sourceDelegate: toVC, destinationDelegate: fromVC)
        }
        
        return nil
    }
    
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return zoomInteractiveTransition
//    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let zoomAnimatedInteractiveTransition = zoomAnimatedInteractiveTransition else {
            return nil
        }
        
        return zoomAnimatedInteractiveTransition.isInteractive ? zoomAnimatedInteractiveTransition : nil
    }
}
