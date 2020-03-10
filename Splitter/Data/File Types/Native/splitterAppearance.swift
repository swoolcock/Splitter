//
//  splitterAppearance.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

struct splitterAppearance: Codable {
	var hideTitlebar: Bool?
	var hideButtons: Bool?
	var keepOnTop: Bool?
	var showBestSplits: Bool?
	var showColumns: [String: Bool]?  = [:]
	var columnSizes: [String: CGFloat]? = [:]
	var windowWidth: CGFloat?
	var windowHeight: CGFloat?
	var roundTo: Int?
	
	
	
	init(viewController: ViewController) {
		self.hideTitlebar = viewController.titleBarHidden
		self.hideButtons = viewController.UIHidden
		self.keepOnTop = viewController.windowFloat
//		self.showBestSplits = viewController.showBestSplits
		self.showColumns = [:]
		self.columnSizes = [:]
		for c in colIds {
			let colIndex = viewController.splitsTableView.column(withIdentifier: c.value)
			let col = viewController.splitsTableView.tableColumns[colIndex]
			let hidden = col.isHidden
			self.showColumns?[c.key] = hidden
			
			var size = col.width
			self.columnSizes?[c.key] = size
		}
		self.windowWidth = viewController.view.window?.frame.width
		self.windowHeight = viewController.view.window?.frame.height
		self.roundTo = viewController.roundTo.rawValue
	}
	
//	func decodeSplitterAppearance(viewController: ViewController) {
//		viewController.titleBarHidden = self.hideTitlebar ?? Settings.hideTitleBar
//		viewController.UIHidden = self.hideButtons ?? Settings.hideUIButtons
//		viewController.windowFloat = self.keepOnTop ?? Settings.floatWindow
//		viewController.showBestSplits = self.showBestSplits ?? Settings.showBestSplits
//
//	}
}

enum SplitterAppearanceError: Error {
	case encodeError
}

extension ViewController {
	///Sets the appearance of the VC to the contents of a SplitterAppearance object
	func setSplitterAppearance(appearance: splitterAppearance) {
		titleBarHidden = appearance.hideTitlebar ?? Settings.hideTitleBar
		UIHidden = appearance.hideButtons ?? Settings.hideUIButtons
		windowFloat = appearance.keepOnTop ?? Settings.floatWindow
//		showBestSplits = appearance.showBestSplits ?? Settings.showBestSplits
		
		showHideTitleBar()
		showHideUI()
		setFloatingWindow()
		showHideBestSplits()
		
		if let sc = appearance.showColumns {
			for c in sc {
				if let id = colIds[c.key] {
					let cIndex = splitsTableView.column(withIdentifier: id)
					splitsTableView.tableColumns[cIndex].isHidden = c.value
				}
			}
		} else {
			for c in splitsTableView.tableColumns {
				switch c.identifier {
				case STVColumnID.previousSplitColumn:
					c.isHidden = true
				default:
					c.isHidden = false
				}
			}
		}
		
		if let cSizes = appearance.columnSizes {
			for c in cSizes {
				if let id = colIds[c.key] {
					let cIndex = splitsTableView.column(withIdentifier: id)
					splitsTableView.tableColumns[cIndex].width = c.value
				}
			}
		}
		
		if view.window != nil && appearance.windowWidth != nil && appearance.windowHeight != nil {
		
			let windowFrame = NSRect(x: view.window!.frame.origin.x, y: view.window!.frame.origin.y, width: appearance.windowWidth!, height: appearance.windowHeight!)
			view.window?.setFrame(windowFrame, display: true)
		}
		
		roundTo = SplitRounding(rawValue: appearance.roundTo ?? 0) ?? SplitRounding.tenths
	}
}