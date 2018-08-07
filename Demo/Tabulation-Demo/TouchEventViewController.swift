//
//  TouchEventViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/8/7.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class TouchEventViewController: UIViewController, TabulationViewDataSource, TabulationViewDelegate {
    
    let reuseIdentifier = "text"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    let noticeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabulationView.backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tabulationView.dataSource = self
        tabulationView.delegate = self
        view.addSubview(tabulationView)
        
        noticeLabel.text = "点击第一行进行排序;"
        noticeLabel.textColor = .lightGray
        noticeLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(noticeLabel)
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
        
        noticeLabel.sizeToFit()
        rect.origin.y = rect.maxY + 16
        rect.size = noticeLabel.frame.size
        noticeLabel.frame = rect
    }
    
    let rowCount = 10
    let colCount = 10
    
    func generateData() {
        for row in 0..<rowCount {
            var rowGrids = [Grid]()
            for col in 0..<colCount {
                if row == 0 {
                    let grid = Grid(content: "第\(col)列")
                    rowGrids.append(grid)
                    continue
                }
                if col == 0 {
                    let grid = Grid(content: "第\(row)行")
                    rowGrids.append(grid)
                    continue
                }
                
                let text = "\(Int.random(in: 0...100))"
                let grid = Grid(content: text)
                rowGrids.append(grid)
            }
            grids.append(rowGrids)
        }
    }
    

    var sortingCol: Int?
    var sortord = ComparisonResult.orderedSame
    
    func sort(inCol col: Int) {
        guard col < colCount else {
            return
        }
        
        let firstRow = grids.first
        
        if let sortingCol = self.sortingCol {
            
            let grid = firstRow![sortingCol]
            var text = grid.content as! String
            text.removeLast()
            grid.content = text
            
            if sortingCol == col {
                sortord = (sortord == .orderedAscending) ? .orderedDescending : .orderedAscending
            }
            else {
                sortord = .orderedAscending
            }
        }
        else {
            sortord = .orderedAscending
        }
        
        let grid = firstRow![col]
        var text = grid.content as! String
        text.append(sortord == .orderedAscending ? "↑" : "↓")
        grid.content = text
        self.sortingCol = col
        
        grids.remove(at: 0)
        grids.sort { (rowGrids1, rowGrids2) -> Bool in
            let value1 = Int(rowGrids1[col].content as! String)
            let value2 = Int(rowGrids2[col].content as! String)
            return (self.sortord == .orderedAscending) ? (value1! < value2!) : (value1! > value2!)
        }
        grids.insert(firstRow!, at: 0)
        tabulationView.reloadData()
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
    
    func tabulationView(_ tabulationView: TabulationView, lengthForRow row: Int) -> CGFloat {
        return 40
    }
    
    func tabulationView(_ tabulationView: TabulationView, lengthForCol col: Int) -> CGFloat {
        return 88
    }
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        
        guard let cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TextTabulationViewCell else {
            return nil
        }
        let grid = grids[indexPath.row][indexPath.col]
        cell.loadGrid(grid)
        return cell
    }
    
    func tabulationView(_ tabulationView: TabulationView, didSelectRowAt indexPath: TabIndexPath) {
        if indexPath.row == 0 && indexPath.col > 0 {
            sort(inCol: indexPath.col)
        }
    }
}
