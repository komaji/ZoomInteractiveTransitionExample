//
//  ImageListViewController.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/01.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class ImageListViewController: UITableViewController {
    
    var transitioningImageView: UIImageView?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let imageView = cell?.imageView
        let imageViewController = UIStoryboard(name: String(describing: ImageViewController.self), bundle: nil).instantiateInitialViewController() as! ImageViewController
        imageViewController.image = imageView?.image
        transitioningImageView = imageView
        
        navigationController?.pushViewController(imageViewController, animated: true)
    }
    
}

extension ImageListViewController: ZoomAnimatedTransitioningSourceDelegate {
    
    func zoomAnimatedTransitioningSourceImageView() -> UIImageView {
        return transitioningImageView!
    }
    
    func zoomAnimatedTransitioningSourceImageViewFrame() -> CGRect {
        return transitioningImageView!.convert(transitioningImageView!.bounds, to: tableView.superview)
        
    }
    
}
