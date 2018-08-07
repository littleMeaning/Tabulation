//
//  LayoutManager.swift
//  Tabulation
//
//  Created by littleMeaning on 2018/7/27.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import Foundation

public class TabulationStyle {
    
    public var rowGap: CGFloat = 1
    public var colGap: CGFloat = 1
    public var gapColor: UIColor?
    
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor?
    
    static var _appearance: TabulationStyle?
    public static var appearance: TabulationStyle {
        guard let appearance = _appearance else {
            _appearance = TabulationStyle()
            return _appearance!
        }
        return appearance
    }
    
    public init() {
        if let appearance = TabulationStyle._appearance {
            rowGap = appearance.rowGap
            colGap = appearance.colGap
            borderWidth = appearance.borderWidth
            borderColor = appearance.borderColor
            gapColor = appearance.gapColor
        }
    }
}
