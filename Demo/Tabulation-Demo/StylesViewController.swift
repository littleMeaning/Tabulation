//
//  StylesViewController.swift
//  Tabulation-Demo
//
//  Created by littleMeaning on 2018/7/20.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit
import Tabulation

class StylesViewController: UIViewController, TabulationViewDataSource {

    enum StyleCode {
        case blue
        case green
    }
    
    var decorator: ((TabulationViewCell) -> Void)?
    let reuseIdentifier = "text"
    var grids = [[Grid]]()
    let tabulationView = TabulationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tabulationView.register(TextTabulationViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tabulationView.dataSource = self
        setStyle(.green)
        view.addSubview(tabulationView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "样式", style: .plain, target: self, action: #selector(selectStyle(_:)))
    }
    
    @objc func selectStyle(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "选择样式", message: nil, preferredStyle: .actionSheet)
        let actionBlue = UIAlertAction(title: "蓝色", style: .default) { _ in self.setStyle(.blue) }
        let actionGreen = UIAlertAction(title: "绿色", style: .default) { _ in self.setStyle(.green) }
        alert.addAction(actionBlue)
        alert.addAction(actionGreen)
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
    
    let rowCount = 20
    let colCount = 10
    
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
    
    private func setStyle(_ code: StyleCode) {
        
        let style = TabulationStyle()
        var backgroundColor = UIColor(red: 170/255, green: 200/255, blue: 230/255, alpha: 1)
        switch code {
        case .blue:
            style.colGap = 5
            style.rowGap = 5
            style.borderWidth = 5
            decorator = { cell in
                let headerBgColor = UIColor(red: 57/255, green: 152/255, blue: 216/255, alpha: 1)
                let headerTextColor = UIColor.white
                if cell.indexPath.row == 0 {
                    cell.backgroundColor = headerBgColor
                    (cell as? TextTabulationViewCell)?.textColor = headerTextColor
                }
                else {
                    cell.backgroundColor = .white
                    (cell as? TextTabulationViewCell)?.textColor = .black
                }
            }
        case .green:
            style.colGap = 1
            style.rowGap = 1
            style.borderWidth = 1
            backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.6, alpha: 1)
            decorator = { cell in
                let headerBgColor = UIColor(red: 0.086, green: 0.627, blue: 0.521, alpha: 1)
                let headerTextColor = UIColor.white
                if cell.indexPath.row == 0 {
                    cell.backgroundColor = headerBgColor
                    (cell as? TextTabulationViewCell)?.textColor = headerTextColor
                }
                else {
                    cell.backgroundColor = .white
                    (cell as? TextTabulationViewCell)?.textColor = cell.indexPath.row % 2 == 0 ? UIColor(red: 0.8, green: 0, blue: 0, alpha: 1) : .black
                }
            }
        }
        tabulationView.backgroundColor = backgroundColor
        tabulationView.style = style
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
    
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell? {
        
        guard let cell = tabulationView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TextTabulationViewCell else {
            return nil
        }
        let grid = grids[indexPath.row][indexPath.col]
        cell.loadGrid(grid)
        decorator?(cell)
        return cell
    }
}
