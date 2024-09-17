//
//  Styles.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/20/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import LithoOperators
import Prelude
import fuikit

public extension UIColor {
    static func primary() -> UIColor {
        return UIColor(hex: 0x4d55a2)
    }
    
    static func primaryDark() -> UIColor {
        return UIColor(hex: 0x333972)
    }
    
    static func accent() -> UIColor {
        return UIColor(hex: 0xdf03a6)
    }
    
    static func background() -> UIColor? {
        return UIColor(named: "backgroundColor")
    }
    
    static func primaryBg() -> UIColor? {
        return UIColor(named: "primaryBgColor")
    }
}

let setupVCBG = ^\UIViewController.view >>> setupBackgroundColor
let setupPDFBG = ^\PDFMapper.pdfView >>> setupBackgroundColor
let setEdges = set(\UIViewController.edgesForExtendedLayout, UIRectEdge())
let setAppTitle = set(\UIViewController.title, Bundle.main.infoDictionary!["AppTitle"] as? String)
let setupPDFMap = union(setupPDFBG, setupPdfMap(for:), disableLongPresses(for:))
let setupVCTableView = ^\FUITableViewViewController.tableView >?> setupTableView(_:)
let setupBottomButton = ^\PDFMapViewController.buttonBottomConstaint >?> setupActionButtonPosition

let setupEdges = set(\UIViewController.edgesForExtendedLayout, UIRectEdge())

let setupBackgroundColor = set(\UIView.backgroundColor, .background())
let setupPrimaryBackgroundColor = set(\UIView.backgroundColor, .primaryBg())

let setupBarColor = set(\UISearchBar.barTintColor, .background())

func setupCircleCappedView(_ view: UIView) {
    view.layer.cornerRadius = view.bounds.size.height / 2
    view.clipsToBounds = true
}

func setupTableView(_ tableView: UITableView?) {
    tableView?.tableFooterView = UIView()
    tableView?.backgroundColor = UIColor(named: "backgroundColor")
    tableView?.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 216, right: 0)
}

func setupActionButtonPosition(_ actionButtonBottomConstraint: NSLayoutConstraint?) { actionButtonBottomConstraint?.constant = Current.adsEnabled ? 62 : 12 }
