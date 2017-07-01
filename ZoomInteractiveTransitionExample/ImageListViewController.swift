//
//  ImageListViewController.swift
//  ZoomInteractiveTransitionExample
//
//  Created by KojimaTatsuya on 2017/07/01.
//  Copyright © 2017年 KojimaTatsuya. All rights reserved.
//

import UIKit

class ImageListViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let image = cell?.imageView?.image
        let imageViewController = UIStoryboard(name: String(describing: ImageViewController.self), bundle: nil).instantiateInitialViewController() as! ImageViewController
        imageViewController.image = image
        
        navigationController?.pushViewController(imageViewController, animated: true)
    }
    
}
