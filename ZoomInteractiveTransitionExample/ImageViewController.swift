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
    let zoomAnimatedInteractiveTransition = ZoomAnimatedInteractiveTransition()
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer! {
        didSet {
            screenEdgePanGestureRecognizer.delegate = self
            screenEdgePanGestureRecognizer.addTarget(zoomAnimatedInteractiveTransition, action: #selector(zoomAnimatedInteractiveTransition.handle(gesture:)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
