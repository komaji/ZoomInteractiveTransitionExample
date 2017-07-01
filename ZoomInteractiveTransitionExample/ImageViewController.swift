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
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
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
