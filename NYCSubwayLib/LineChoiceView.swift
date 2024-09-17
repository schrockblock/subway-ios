//
//  LineCoiceView.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 11/4/15.
//  Copyright © 2015 Thryv. All rights reserved.
//

import UIKit

protocol LineChoiceViewDelegate {
    func didSelectLineWithColor(_ color: UIColor)
    func didDeselectLineWithColor(_ color: UIColor)
}

class LineChoiceView: UIView {
    var delegate: LineChoiceViewDelegate?
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backgroundView: UILabel!
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var lineLabel: UILabel!
    fileprivate var _isSelected: Bool = false
    var isSelected: Bool {
        set(shouldBeSelected) {
            _isSelected = shouldBeSelected
            setupView()
        }
        get {
            return _isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupXib()
    }
    
    func setupXib(){
        Bundle(for: Self.self).loadNibNamed("LineChoiceView", owner: self, options: nil)
        addSubview(self.view)
        
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions.alignmentMask, metrics: nil, views: ["view" : view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions.alignmentMask, metrics: nil, views: ["view" : view]))
        
        clipsToBounds = true
        view.clipsToBounds = true
        
        setupView()
    }
    
    func setupView(){
        if isSelected {
            lineLabel.textColor = UIColor.darkGray
            
            backgroundView.layer.borderWidth = 0
            backgroundView.backgroundColor = UIColor.white
        }else{
            lineLabel.textColor = UIColor.white
            
            backgroundView.layer.borderColor = UIColor.white.cgColor
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.cornerRadius = view.bounds.size.height / 2
            backgroundView.backgroundColor = UIColor.clear
        }
        backgroundView.clipsToBounds = true
    }
    
    @IBAction func toggleSelectedPressed() {
        isSelected = !isSelected
        if isSelected {
            delegate?.didSelectLineWithColor(dotImageView.tintColor)
        }else{
            delegate?.didDeselectLineWithColor(dotImageView.tintColor)
        }
    }
}
