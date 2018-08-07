//
//  SpanViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/7/26.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class SpanViewController: UIViewController, TabulationViewDataSource {
    
    let reuseIdentifier = "text"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabulationView.backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tabulationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.generateData()
        tabulationView.dataSource = self
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
    
    let rowCount = 10
    let colCount = 10
    
    func generateData() {
        for row in 0..<rowCount {
            var rowGrids = [Grid]()
            for col in 0..<colCount {
                let text = "\(row) - \(col)"
                let grid = Grid(content: text)
                
                if (row, col) == (0, 0) {
                    grid.colspan = 1
                    grid.rowspan = 2
                }
                if (row, col) == (1, 0) {
                    grid.rowspan = 0
                }
                if (row, col) == (0, 1) {
                    grid.colspan = 2
                }
                if (row, col) == (0, 2) {
                    grid.colspan = 0
                }
                if (row, col) == (0, 3) {
                    grid.colspan = 3
                }
                if (row, col) == (0, 4) {
                    grid.colspan = 0
                }
                if (row, col) == (0, 5) {
                    grid.colspan = 0
                }
                if (row, col) == (0, 6) {
                    grid.colspan = 4
                }
                if (row, col) == (0, 7) {
                    grid.colspan = 0
                }
                if (row, col) == (0, 8) {
                    grid.colspan = 0
                }
                if (row, col) == (0, 9) {
                    grid.colspan = 0
                }
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
    
    func numberOfLockingRows(in tabulationView: TabulationView) -> Int {
        return 2
    }
    
    func numberOfLockingCols(in tabulationView: TabulationView) -> Int {
        return 1
    }
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        
        let grid = grids[indexPath.row][indexPath.col]
        if grid.isEmpty {
            return TabulationViewCell.placeholder
        }
        guard let cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TextTabulationViewCell else {
            return nil
        }
        if (indexPath.row < tabulationView.numberOfLockingRows) {
            cell.backgroundColor = UIColor(red: 104/255, green: 173/255, blue: 213/255, alpha: 1)
            cell.textColor = .white
        }
        cell.rowspan = grid.rowspan
        cell.colspan = grid.colspan
        cell.loadGrid(grid)
        return cell
    }
}
