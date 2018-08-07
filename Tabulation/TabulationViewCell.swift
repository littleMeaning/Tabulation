//
//  TabulationViewCell.swift
//  Tabulation
//
//  Created by littleMeaning on 2018/7/19.
//  Copyright © 2018年 com.littlemeaning. All rights reserved.
//

import UIKit

public class TabulationViewCell: UIView {
    
    private(set) public var reuseIdentifier: String?
    public var indexPath: TabIndexPath!
    public var rowspan = 1
    public var colspan = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    required init(reuseIdentifier: String?) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: CGRect())
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        clipsToBounds = true
    }
    
    public static var placeholder: TabulationViewCell {
        return PlaceholderTabulationViewCell.instance
    }
    
    public func prepareForReuse() {
        backgroundColor = .white
    }
}

class PlaceholderTabulationViewCell: TabulationViewCell {
    static let instance = PlaceholderTabulationViewCell()
}

public class TextTabulationViewCell: TabulationViewCell {
    
    public var contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    public var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    public let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubviews()
    }
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadSubviews()
    }
    
    func loadSubviews() {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        addSubview(label)
    }
    
    override public func layoutSubviews() {
        label.frame = bounds.inset(by: contentInset)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var limitSize = size
        if size.width > 0 {
           limitSize.width -= (contentInset.left + contentInset.right)
        }
        if size.height > 0 {
            limitSize.height -= (contentInset.top + contentInset.bottom)
        }
        var size = label.sizeThatFits(limitSize)
        size.width += (contentInset.left + contentInset.right)
        size.height += (contentInset.top + contentInset.bottom)
        return size
    }
    
    var grid: Grid?
    public func loadGrid(_ grid: Grid) {
        self.grid = grid
        label.text = (grid.content as? String) ??  ""
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        textColor = UIColor.black
    }
}

public class ImageTabulationViewCell: TabulationViewCell {
    
    public let imageView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubviews()
    }
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadSubviews()
    }
    
    func loadSubviews() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    override public func layoutSubviews() {
        imageView.frame = bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        guard let image = imageView.image else {
            return CGSize()
        }
        var fitSize = image.size
        if fitSize.width > size.width && size.width > 0 {
            fitSize.height = (fitSize.height / fitSize.width) * size.width
            fitSize.width = size.width
        }
        if fitSize.height > size.height && size.height > 0 {
            fitSize.width = (fitSize.width / fitSize.height) * size.height
            fitSize.height = size.height
        }
        return fitSize
    }
    
    var grid: Grid?
    public func loadGrid(_ grid: Grid) {
        self.grid = grid
        if let image = grid.content as? UIImage {
            imageView.image = image
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
