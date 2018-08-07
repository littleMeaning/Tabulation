//
//  TabulationTests.swift
//  TabulationTests
//
//  Created by littleMeaning on 2018/7/20.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import XCTest

class TabulationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
    }
    
    func testPerformanceExample() {
        
        var grids = [Grid]()
        let rowCount = 200
        let colCount = 200
        for row in 0...rowCount {
            for col in 0...colCount {
                if (row == 0) {
                    cols.append(.absolute(84))
                }
                let area = Grid.Area(row: row, col: col, rowspan: 1, colspan: 1)
                let text = "\(row * colCount + col + 1)"
                let grid = Grid(area: area, content: text)
                grids.append(grid)
            }
            rows.append(.absolute(40))
        }
        
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
