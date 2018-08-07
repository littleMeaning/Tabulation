//
//  ReuseViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/8/6.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class ReuseViewController: UIViewController, TabulationViewDataSource {
    
    let reuseIdentifier = "text"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabulationView.backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tabulationView.dataSource = self
        view.addSubview(tabulationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.generateData()
        tabulationView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var rect = view.bounds
        rect = rect.insetBy(dx: 16, dy: 0)
        rect.size.height -= topLayoutGuide.length + 16 * 2
        rect.origin.y = topLayoutGuide.length + 16
        rect.size.width = min(rect.width, tabulationView.intrinsicContentSize.width)
        rect.size.height = min(rect.height, tabulationView.intrinsicContentSize.height)
        tabulationView.frame = rect
    }
    
    let rowCount = 100
    let colCount = 100
    
    func generateData() {
        for row in 0..<rowCount {
            var rowGrids = [Grid]()
            for col in 0..<colCount {
                let text = "\(row) - \(col)"
                let grid = Grid(content: text)
                rowGrids.append(grid)
            }
            grids.append(rowGrids)
        }
    }
    
    // MARK: TabulationViewDataSource
    
    func numberOfRows(in tabulationView: TabulationView) -> Int {
        return rowCount
    }
    
    func numberOfCols(in tabulationView: TabulationView) -> Int {
        return colCount
    }
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        
        guard let cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TextTabulationViewCell else {
            return nil
        }
        let grid = grids[indexPath.row][indexPath.col]
        cell.loadGrid(grid)
        return cell
    }
}
