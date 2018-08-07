//
//  ViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/7/17.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var vc: UIViewController?
        switch indexPath.row {
        case 0:
            vc = ReuseViewController()
            break
        case 1:
            vc = StylesViewController()
            break
        case 2:
            vc = SpanViewController()
            break
        case 3:
            vc = CustomGridViewController()
            break
        case 4:
            vc = TouchEventViewController()
            break
        case 5:
            vc = SizeToFitViewController()
            break
        default:
            break
        }
        guard let viewController = vc else {
            return
        }
        viewController.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

