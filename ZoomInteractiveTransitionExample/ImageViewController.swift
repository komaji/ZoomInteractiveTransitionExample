//
//  ImageViewController.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/01.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage?
//    let zoomInteractiveTransition = ZoomInteractiveTransition()
//    var context: UIViewControllerContextTransitioning?
    let zoomAnimatedInteractiveTransition = ZoomAnimatedInteractiveTransition()
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer! {
        didSet {
//            zoomInteractiveTransition.delegate = self
            screenEdgePanGestureRecognizer.delegate = self
//            screenEdgePanGestureRecognizer.addTarget(zoomInteractiveTransition, action: #selector(zoomInteractiveTransition.handle(recognizer:)))
            screenEdgePanGestureRecognizer.addTarget(zoomAnimatedInteractiveTransition, action: #selector(zoomAnimatedInteractiveTransition.handle(gesture:)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        zoomAnimatedInteractiveTransition.view = view
        zoomAnimatedInteractiveTransition.delegate = self
        (navigationController as? NavigationController)?.zoomAnimatedInteractiveTransition = zoomAnimatedInteractiveTransition
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (navigationController as? NavigationController)?.zoomAnimatedInteractiveTransition = nil
    }
    
}

extension ImageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}

//extension ImageViewController: ZoomInteractiveTransitionDelegate {
//    
//    func zoomInteractiveTransitionBegan() {
//        (navigationController as! NavigationController).zoomInteractiveTransition = zoomInteractiveTransition
//        _ = navigationController?.popViewController(animated: true)
//        (navigationController as! NavigationController).zoomInteractiveTransition = nil
//        
//        if let transitionCoordinator = transitionCoordinator, transitionCoordinator.initiallyInteractive {
//            transitionCoordinator.notifyWhenInteractionChanges { [weak self] _ in
//                if transitionCoordinator.isCancelled {
//                    guard let context = self?.context else {
//                        return
//                    }
//                    
//                    guard let toVC = context.viewController(forKey: .to),
//                        let fromVC = context.viewController(forKey: .from) else {
//                        return
//                    }
//                    
//                    guard let sourceDelegate = toVC as? ZoomAnimatedTransitioningSourceDelegate,
//                        let destinationDelegate = fromVC as? ZoomAnimatedTransitioningDestinationDelegate,
//                        let transitioningImageViewIndex = context.containerView.subviews.index(where: { $0 is UIImageView }) else {
//                        return
//                    }
//                    
//                    guard let sourceView = context.view(forKey: .to),
//                        let destinationView = context.view(forKey: .from) else {
//                        return
//                    }
//                    
//                    let transitioningImageView = context.containerView.subviews[transitioningImageViewIndex]
//                    
//                    UIView.animate(
//                        withDuration:  0.3,
//                        delay: 0.0,
//                        options: .curveEaseOut,
//                        animations: {
//                            sourceView.alpha = 1.0
//                            destinationView.alpha = 0.0
//                            transitioningImageView.frame = destinationDelegate.zoomAnimatedTransitioningDestinationImageViewFrame()
//                            print("FUGA FUGA")
//                        },
//                        completion: { _ in
//                            sourceView.alpha = 0.0
//                            destinationView.alpha = 1.0
//                            transitioningImageView.removeFromSuperview()
//                            print("HOGE HOGE")
//                        }
//                    )
//                }
//            }
//        }
//    }
//    
//}

extension ImageViewController: ZoomAnimatedTransitioningDestinationDelegate {
    
    func zoomAnimatedTransitioningDestinationImageView() -> UIImageView {
        return imageView
    }
    
    func zoomAnimatedTransitioningDestinationImageViewFrame() -> CGRect {
        return imageView.convert(imageView.bounds, to: view)
    }
    
    func zoomAnimatedTransitioningDestinationWillBegin(context: UIViewControllerContextTransitioning) {
        imageView.isHidden = true
    }
    
    func zoomAnimatedTransitioningDestinationDidEnd() {
        imageView.isHidden = false
    }
    
}

extension ImageViewController: ZoomAnimatedInteractiveTransitionDelegate {
    
    func zoomAnimatedInteractiveTransitionBegan(at point: CGPoint) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
