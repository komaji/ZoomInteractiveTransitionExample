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
    let zoomInteractiveTransition = ZoomInteractiveTransition()
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer! {
        didSet {
            zoomInteractiveTransition.delegate = self
            screenEdgePanGestureRecognizer.delegate = self
            screenEdgePanGestureRecognizer.addTarget(zoomInteractiveTransition, action: #selector(zoomInteractiveTransition.handle(recognizer:)))
        }
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

extension ImageViewController: ZoomInteractiveTransitionDelegate {
    
    func zoomInteractiveTransitionBegan() {
        (navigationController as! NavigationController).zoomInteractiveTransition = zoomInteractiveTransition
        _ = navigationController?.popViewController(animated: true)
        (navigationController as! NavigationController).zoomInteractiveTransition = nil
    }
    
}

extension ImageViewController: ZoomAnimatedTransitioningDestinationDelegate {
    
    func zoomAnimatedTransitioningDestinationImageView() -> UIImageView {
        return imageView
    }
    
    func zoomAnimatedTransitioningDestinationImageViewFrame() -> CGRect {
        return imageView.convert(imageView.bounds, to: view)
    }
    
    func zoomAnimatedTransitioningDestinationWillBegin() {
        imageView.isHidden = true
    }
    
    func zoomAnimatedTransitioningDestinationDidEnd() {
        imageView.isHidden = false
    }
    
}
