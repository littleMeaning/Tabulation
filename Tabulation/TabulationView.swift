//
//  TabulationView.swift
//  Tabulation
//
//  Created by littleMeaning on 2018/7/17.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit

public struct TabIndexPath: Hashable {
    public let row: Int
    public let col: Int
}

public class Grid {
    
    public var rowspan = 1
    public var colspan = 1
    public var content: Any
    public var isEmpty: Bool {
        return (rowspan * colspan == 0)
    }
    
    static var _empty: Grid?
    
    public class var empty: Grid {
        guard _empty != nil else {
            _empty = Grid(content: 0)
            _empty!.colspan = 0
            _empty!.rowspan = 0
            return _empty!
        }
        return _empty!
    }
    
    public init(content: Any) {
        self.content = content
    }
}

struct Section {
    var index: Int
    var rect: CGRect
}

public protocol TabulationViewDataSource: NSObjectProtocol {
    
    func numberOfRows(in tabulationView: TabulationView) -> Int
    func numberOfCols(in tabulationView: TabulationView) -> Int
    func numberOfLockingRows(in tabulationView: TabulationView) -> Int
    func numberOfLockingCols(in tabulationView: TabulationView) -> Int
    func tabulationView(_ tabulationView: TabulationView, lengthForRow row: Int) -> CGFloat
    func tabulationView(_ tabulationView: TabulationView, lengthForCol col: Int) -> CGFloat
    func tabulationView(_ tabulationView: TabulationView, cellForIndexPath indexPath: TabIndexPath) -> TabulationViewCell?
}

public extension TabulationViewDataSource {
    
    func numberOfLockingRows(in tabulationView: TabulationView) -> Int {
        return 0
    }
    
    func numberOfLockingCols(in tabulationView: TabulationView) -> Int {
        return 0
    }
    
    func tabulationView(_ tabulationView: TabulationView, lengthForRow row: Int) -> CGFloat {
        return 40
    }
    
    func tabulationView(_ tabulationView: TabulationView, lengthForCol col: Int) -> CGFloat {
        return 80
    }
}

public protocol TabulationViewDelegate: NSObjectProtocol {
    
    func tabulationView(_ tabulationView: TabulationView, didSelectRowAt indexPath: TabIndexPath)
}

public class TabulationView: UIView, UIScrollViewDelegate {
    
    public static let autoLength = CGFloat(Int.max)
    
    private var tapGesture: UITapGestureRecognizer?
    @objc private func handleTap(tap: UITapGestureRecognizer) {
        
        let location = tap.location(in: self)
        guard let (indexPath, _) = visibleCells.first(where: { (indexPath, cell) in
            return self.convert(cell.bounds, from: cell).contains(location)
        }) else {
            return;
        }
        delegate?.tabulationView(self, didSelectRowAt: indexPath)
    }
    
    public weak var dataSource: TabulationViewDataSource?
    public weak var delegate: TabulationViewDelegate? {
        didSet {
            if delegate != nil && tapGesture == nil {
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                addGestureRecognizer(tapGesture!)
            }
            else if delegate == nil && tapGesture != nil {
                removeGestureRecognizer(tapGesture!)
                tapGesture = nil
            }
        }
    }
    
    public var style = TabulationStyle() {
        didSet {
            setNeedsLayout()
        }
    }
    
    let tlScrollView = UIScrollView()   // tl == top left, 将表格分成四个部分, tl 为左上角
    let trScrollView = UIScrollView()
    let blScrollView = UIScrollView()
    let brScrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        
        tlScrollView.isScrollEnabled = false
        tlScrollView.showsVerticalScrollIndicator = false
        tlScrollView.showsHorizontalScrollIndicator = false
        addSubview(tlScrollView)
        
        trScrollView.isScrollEnabled = false
        trScrollView.showsVerticalScrollIndicator = false
        trScrollView.showsHorizontalScrollIndicator = false
        addSubview(trScrollView)
        
        blScrollView.isScrollEnabled = false
        blScrollView.showsVerticalScrollIndicator = false
        blScrollView.showsHorizontalScrollIndicator = false
        addSubview(blScrollView)
        
        brScrollView.bounces = false
        brScrollView.showsVerticalScrollIndicator = false
        brScrollView.showsHorizontalScrollIndicator = false
        brScrollView.delegate = self
        addSubview(brScrollView)
    }
    
    // MARK: load views
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    public override var intrinsicContentSize: CGSize {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        colSections.forEach { width += $0.rect.width + style.colGap }
        rowSections.forEach { height += $0.rect.height + style.rowGap }
        width = max(width - style.colGap, 0)
        height = max(height - style.rowGap, 0)
        width += (style.borderWidth * 2)
        height += (style.borderWidth * 2)
        return CGSize(width: width, height: height)
    }
    
    public override func layoutSubviews() {
        
        if reloading {
            super.layoutSubviews()
            return
        }
        
        var rect = CGRect(x: style.borderWidth,
                          y: style.borderWidth,
                          width: lengthOfLockingCols,
                          height: lengthOfLockingRows)
        tlScrollView.frame = rect
        
        rect.origin.x =  numberOfLockingCols > 0 ? rect.maxX + style.colGap : rect.maxX
        rect.size.width = bounds.width - rect.minX - style.borderWidth
        trScrollView.frame = rect
        
        rect = tlScrollView.frame
        rect.origin.y = numberOfLockingRows > 0 ? rect.maxY + style.rowGap : rect.maxY
        rect.size.height = bounds.height - rect.minY - style.borderWidth
        blScrollView.frame = rect
        
        rect.origin.x = trScrollView.frame.minX
        rect.origin.y = blScrollView.frame.minY
        rect.size.width = trScrollView.frame.width
        rect.size.height = blScrollView.frame.height
        brScrollView.frame = rect
        
        updateSections()
        
        var size = intrinsicContentSize
        size.width -= (style.borderWidth * 2 + style.colGap + blScrollView.frame.width)
        size.height -= (style.borderWidth * 2 + style.rowGap + trScrollView.frame.height)
        brScrollView.contentSize = size
        
        trScrollView.contentSize = CGSize(width: size.width, height: 0)
        blScrollView.contentSize = CGSize(width: 0, height: size.height)
        
        updateTabulationBorder()
        updateTabulationGap()
        updateTabulationView()
        layoutTabulationView()
        
        super.layoutSubviews()
    }
    
    public var numberOfRows = 0
    public var numberOfCols = 0
    public var numberOfLockingRows = 0
    public var numberOfLockingCols = 0
    private var rowSections = [Section]()
    private var colSections = [Section]()
    private var rowLengths = [Int: CGFloat]()
    private var colLengths = [Int: CGFloat]()
    private var spans = [TabIndexPath : (rowspan: Int, colspan: Int)]()
    private var lengthOfLockingRows: CGFloat = 0
    private var lengthOfLockingCols: CGFloat = 0
    
    private func updateSections() {
        rowSections.removeAll()
        colSections.removeAll()
        
        guard let dataSource = self.dataSource else {
            return
        }
        numberOfLockingRows = dataSource.numberOfLockingRows(in: self)
        numberOfLockingCols = dataSource.numberOfLockingCols(in: self)
        
        if numberOfLockingRows > numberOfRows {
            fatalError("error: numberOfLockingRows > numberOfRows")
        }
        if numberOfLockingCols > numberOfCols {
            fatalError("error: numberOfLockingCols > numberOfCols")
        }
        
        var tmpRowLengths = [CGFloat]()
        var tmpColLengths = [CGFloat]()
        var height: CGFloat = 0
        var width: CGFloat = 0
        for row in 0..<numberOfRows {
            let rowHeight = rowLengths[row] ?? dataSource.tabulationView(self, lengthForRow: row)
            tmpRowLengths.append(rowHeight)
            height += rowHeight
        }
        height += CGFloat(numberOfRows - 1) * style.rowGap
        for col in 0..<numberOfCols {
            let colWidth = colLengths[col] ?? dataSource.tabulationView(self, lengthForCol: col)
            tmpColLengths.append(colWidth)
            width += colWidth
        }
        width += CGFloat(numberOfCols - 1) * style.colGap
        
        for row in 0..<numberOfRows {
            var y = rowSections.last?.rect.maxY ?? 0
            if row > 0 { y += style.rowGap }
            let rowHeight = tmpRowLengths[row]
            let rect = CGRect(x: 0, y: y, width: width, height: rowHeight)
            rowSections.append(Section(index:row, rect: rect))
        }
        for col in 0..<numberOfCols {
            var x = colSections.last?.rect.maxX ?? 0
            if col > 0 { x += style.colGap }
            let colWidth = tmpColLengths[col]
            let rect = CGRect(x: x, y: 0, width: colWidth, height: height)
            colSections.append(Section(index: col, rect: rect))
        }
        
        lengthOfLockingRows = numberOfLockingRows > 0 ? CGFloat(numberOfLockingRows - 1) * style.rowGap : 0
        lengthOfLockingCols = numberOfLockingCols > 0 ? CGFloat(numberOfLockingCols - 1) * style.colGap : 0
        for i in 0..<numberOfLockingRows {
            lengthOfLockingRows += rowSections[i].rect.height
        }
        for i in 0..<numberOfLockingCols {
            lengthOfLockingCols += colSections[i].rect.width
        }
    }
    
    private var visibleCells = [TabIndexPath : TabulationViewCell]()
    private var cachedCells = [TabIndexPath : TabulationViewCell]()
    private var reusableCells = Set<TabulationViewCell>()
    
    private func updateTabulationView() {
        
        var visibleRect = brScrollView.bounds
        guard visibleRect.width * visibleRect.height > 0 else {
            return
        }
        visibleRect.origin = CGPoint()
        visibleRect.origin.x = brScrollView.contentOffset.x + lengthOfLockingCols + style.colGap
        visibleRect.origin.y = brScrollView.contentOffset.y + lengthOfLockingRows + style.rowGap
        
        var availableCells = visibleCells
        visibleCells.removeAll()
        
        let visibleRowSections = rowSections.filter { (section) -> Bool in
            return section.rect.intersects(visibleRect) || section.index < numberOfLockingRows
        }
        let visibleColSections = colSections.filter { (section) -> Bool in
            return section.rect.intersects(visibleRect) || section.index < numberOfLockingCols
        }

        // 得到所有在可视区域内的 cell 的 indexPaths
        var indexPaths = [TabIndexPath]()
        for rowSection in visibleRowSections {
            for colSection in visibleColSections {
                let indexPath = TabIndexPath(row: rowSection.index, col: colSection.index)
                indexPaths.append(indexPath)
            }
        }
        // 添加由于跨行列产生的额外的可视 cell
        let extraIndexPaths = spans.filter { (indexPath, span) in
            if (indexPaths.contains(indexPath)) {
                return false
            }
            let (rowspan, colspan) = span
            var rect = CGRect()
            rect.origin.x = colSections[indexPath.col].rect.minX
            rect.origin.y = rowSections[indexPath.row].rect.minY
            rect.size.width = CGFloat(colspan - 1) * style.colGap
            for i in 0..<colspan {
                rect.size.width += colSections[indexPath.col + i].rect.width
            }
            rect.size.height = CGFloat(rowspan - 1) * style.rowGap
            for i in 0..<colspan {
                rect.size.height += rowSections[indexPath.row + i].rect.height
            }
            if indexPath.row < numberOfLockingRows {
                let range1 = (rect.minX...rect.maxX)
                let range2 = (visibleRect.minX...visibleRect.maxX)
                return range1.overlaps(range2)
            }
            if indexPath.col < numberOfLockingCols {
                let range1 = (rect.minY...rect.maxY)
                let range2 = (visibleRect.minY...visibleRect.maxY)
                return range1.overlaps(range2)
            }
            return rect.intersects(visibleRect)
        }
        indexPaths.append(contentsOf: extraIndexPaths.keys)
        // 依然在可视区域的 cell 不做处理
        indexPaths.forEach { (indexPath) in
            guard let cell = availableCells[indexPath] else {
                return
            }
            cachedCells[indexPath] = cell
            availableCells.removeValue(forKey: indexPath)
        }
        
        let reusableCells = Set(availableCells.filter { return $0.value.reuseIdentifier != nil }.values)
        self.reusableCells = reusableCells.union(reusableCells)
        
        indexPaths.forEach { (indexPath) in
            
            var superview: UIView!
            let inTop = indexPath.row < numberOfLockingRows
            let inLeft = indexPath.col < numberOfLockingCols
            switch (inTop, inLeft) {
            case (true, true):
                superview = tlScrollView
            case (true, false):
                superview = trScrollView
            case (false, true):
                superview = blScrollView
            case (false, false):
                superview = brScrollView
            }
            guard let cell =  dataSource?.tabulationView(self, cellForIndexPath: indexPath) else {
                fatalError()
            }
            if cell.isKind(of: type(of: TabulationViewCell.placeholder)) {
                return
            }
            if cell.superview != nil && cell.superview != superview {
                cell.removeFromSuperview()
            }
            if (cell.rowspan > 1 || cell.colspan > 1) {
                spans[indexPath] = (cell.rowspan, cell.colspan)
            }
            superview.addSubview(cell)
            visibleCells[indexPath] = cell
        }
        cachedCells.removeAll()
        
        self.reusableCells.forEach {
            $0.removeFromSuperview()
            $0.prepareForReuse()
        }
    }
    
    private func layoutTabulationView() {
        
        visibleCells.forEach { (indexPath, cell) in
            
            guard (indexPath.col + cell.colspan - 1) < colSections.count else {
                fatalError("colspan 超出, indexPath:(\(indexPath.row),\(indexPath.col))")
            }
            guard (indexPath.row + cell.rowspan - 1) < rowSections.count else {
                fatalError("rowspan 超出, indexPath:(\(indexPath.row),\(indexPath.col))")
            }
            
            var x = colSections[indexPath.col].rect.minX
            var y = rowSections[indexPath.row].rect.minY
            
            let inTop = indexPath.row < numberOfLockingRows
            let inLeft = indexPath.col < numberOfLockingCols
            switch (inTop, inLeft) {
            case (true, true):
                break
            case (true, false):
                x -= (brScrollView.frame.minX - style.borderWidth)
            case (false, true):
                y -= (brScrollView.frame.minY - style.borderWidth)
            case (false, false):
                x -= (brScrollView.frame.minX - style.borderWidth)
                y -= (brScrollView.frame.minY - style.borderWidth)
            }
            
            var w: CGFloat = 0
            for i in 1...cell.colspan {
                w = w + colSections[indexPath.col + i - 1].rect.width
            }
            w += CGFloat(cell.colspan - 1) * style.colGap
            var h: CGFloat = 0
            for i in 1...cell.rowspan {
                h = h + rowSections[indexPath.row + (i - 1)].rect.height
            }
            h += CGFloat(cell.rowspan - 1) * style.rowGap
            cell.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
    private var borderView: UIView?
    private func updateTabulationBorder() {
        if let borderColor = style.borderColor {
            let borderView = self.borderView ?? UIView()
            let mask = (borderView.layer.mask as? CAShapeLayer) ?? CAShapeLayer()
            borderView.layer.mask = mask
            borderView.backgroundColor = borderColor
            addSubview(borderView)
            sendSubviewToBack(borderView)
            let path = UIBezierPath(rect: bounds)
            path.append(UIBezierPath(rect: bounds.insetBy(dx: style.borderWidth, dy: style.borderWidth)))
            mask.path = path.cgPath
            mask.fillRule = .evenOdd
            borderView.frame = bounds
            self.borderView = borderView
        }
        else {
            borderView?.removeFromSuperview()
            borderView = nil
        }
    }
    
    private var background: UIView?
    private func updateTabulationGap() {
        if let gapColor = style.gapColor {
            let background = self.background ?? UIView()
            background.backgroundColor = gapColor
            addSubview(background)
            sendSubviewToBack(background)
            var frame = CGRect()
            frame.size = brScrollView.contentSize
            background.frame = frame
            self.background = background
        }
        else {
            background?.removeFromSuperview()
            background = nil
        }
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: TabIndexPath) -> TabulationViewCell? {
        
        var cell = cachedCells[indexPath]
        if cell == nil {
            cell = reusableCells.first(where: { $0.reuseIdentifier == identifier })
            if cell != nil {
                cell!.prepareForReuse()
                reusableCells.remove(cell!)
            }
            else {
                if let cls = reuseMapper[identifier] as? TabulationViewCell.Type {
                    cell = cls.init(reuseIdentifier: identifier)
                }
            }
        }
        cell?.indexPath = indexPath
        return cell
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        trScrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        blScrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        setNeedsLayout()
    }
    
    // MARK: public
    
    private var reloading = false
    
    public func reloadData() {
        reloadData(waitUntilDone: false)
    }
    
    // waitUntilDone: 自适应时，等待行高和列宽计算完成后 reload
    public func reloadData(waitUntilDone: Bool) {
        
        guard let dataSource = self.dataSource else {
            setNeedsLayout()
            return
        }
        
        rowLengths.removeAll()
        colLengths.removeAll()
        spans.removeAll()
        numberOfRows = dataSource.numberOfRows(in: self)
        numberOfCols = dataSource.numberOfCols(in: self)
        
        if waitUntilDone {
            reloading = true
            for row in 0..<self.numberOfRows {
                var height = dataSource.tabulationView(self, lengthForRow: row)
                if height == TabulationView.autoLength {
                    height = 0
                    for col in 0..<self.numberOfCols {
                        let indexPath = TabIndexPath(row: row, col: col)
                        guard let cell = dataSource.tabulationView(self, cellForIndexPath: indexPath) else {
                            fatalError()
                        }
                        let width = dataSource.tabulationView(self, lengthForCol: col)
                        let calculatedHeight = cell.sizeThatFits(CGSize(width: width, height: 0)).height
                        height = max(height, calculatedHeight)
                    }
                }
                self.rowLengths[row] = height
            }
            for col in 0..<self.numberOfCols {
                var width = dataSource.tabulationView(self, lengthForCol: col)
                if width == TabulationView.autoLength {
                    width = 0
                    for row in 0..<self.numberOfRows {
                        let indexPath = TabIndexPath(row: row, col: col)
                        guard let cell = dataSource.tabulationView(self, cellForIndexPath: indexPath) else {
                            fatalError()
                        }
                        let height = dataSource.tabulationView(self, lengthForRow: row)
                        let calculatedWidth = cell.sizeThatFits(CGSize(width: 0, height: height)).width
                        width = max(width, calculatedWidth)
                    }
                }
                self.colLengths[col] = width
            }
            self.reloading = false
            self.setNeedsLayout()
        }
        else {
            setNeedsLayout()
        }
    }
    
    var reuseCache = [String: Array<TabulationView>]()
    var reuseMapper = [String: AnyClass]()
    
    public func register(_ cellClass: TabulationViewCell.Type, forCellReuseIdentifier identifier: String) {
        reuseMapper[identifier] = cellClass
    }
}
