//
//  CustomGridViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/8/6.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class CustomGridViewController: UIViewController, TabulationViewDataSource {
    
    let reuseIdentifierText = "text"
    let reuseIdentifierImage = "image"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabulationView.backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifierText)
        tabulationView.register(ImageTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifierImage)
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
    
    let rowCount = 7
    let colCount = 4
    
    func generateData() {
        for row in 0..<rowCount {
            var rowGrids = [Grid]()
            for col in 0..<colCount {
                if col == 3 {
                    if row % 2 == 0 {
                        if row == 0 {
                            let grid = Grid(content: "图片")
                            rowGrids.append(grid)
                        }
                        else {
                            rowGrids.append(.empty)
                        }
                    }
                    else {
                        let image = UIImage(named: "image-\((row + 1) / 2)")
                        let grid = Grid(content: image!)
                        grid.rowspan = 2
                        rowGrids.append(grid)
                    }
                    continue
                }
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
    
    func numberOfLockingRows(in tabulationView: TabulationView) -> Int {
        return 1
    }
    
    func numberOfLockingCols(in tabulationView: TabulationView) -> Int {
        return 1
    }
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        
        let grid = grids[indexPath.row][indexPath.col]
        if grid.isEmpty {
            return TabulationViewCell.placeholder
        }
        
        var cell: TabulationViewCell?
        if (indexPath.col == 3 && indexPath.row > 0) {
            // 图片
            cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifierImage, for: indexPath)
            (cell as? ImageTabulationViewCell)?.loadGrid(grid)
            (cell as? ImageTabulationViewCell)?.imageView.contentMode = .scaleAspectFill
        }
        else {
            // 文字
            cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifierText, for: indexPath)
            (cell as? TextTabulationViewCell)?.loadGrid(grid)
        }
        cell?.rowspan = grid.rowspan
        cell?.colspan = grid.colspan
        return cell
    }
}
