//
//  SizeToFitViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/8/7.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class SizeToFitViewController: UIViewController, TabulationViewDataSource {
    
    enum FitMode {
        case none
        case rowHeight
        case colWidth
    }
    
    let reuseIdentifier = "text"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    private var fitMode = FitMode.none {
        didSet {
            tabulationView.reloadData(waitUntilDone: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabulationView.backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tabulationView.dataSource = self
        view.addSubview(tabulationView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自适应方式", style: .plain, target: self, action: #selector(showActionSheet(_:)))
    }
    
    @objc func showActionSheet(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "选择方式", message: nil, preferredStyle: .actionSheet)
        let actionNone = UIAlertAction(title: "无", style: .default) { _ in self.fitMode = .none }
        let actionRow = UIAlertAction(title: "行高自适应", style: .default) { _ in self.fitMode = .rowHeight }
        let actionCol = UIAlertAction(title: "列宽自适应", style: .default) { _ in self.fitMode = .colWidth }
        alert.addAction(actionNone)
        alert.addAction(actionRow)
        alert.addAction(actionCol)
        present(alert, animated: true, completion: nil)
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
    
    let rowCount = 16
    let colCount = 8
    
    func generateData() {
        for _ in 0..<rowCount {
            var rowGrids = [Grid]()
            let specialCol = Int.random(in: 0...colCount)
            for col in 0..<colCount {
                let text = col == specialCol ? "000001111122222333334444455555" : "0"
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
    
    func tabulationView(_ tabulationView: TabulationView, lengthForRow row: Int) -> CGFloat {
        return fitMode == .rowHeight ? TabulationView.autoLength : 40
    }
    
    func tabulationView(_ tabulationView: TabulationView, lengthForCol col: Int) -> CGFloat {
        return fitMode == .colWidth ? TabulationView.autoLength : 80
    }
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        let cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let grid = grids[indexPath.row][indexPath.col]
        (cell as? TextTabulationViewCell)?.loadGrid(grid)
        return cell
    }
}
