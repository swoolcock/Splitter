//
//  Split Table View.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa


//MARK - Number of Rows
extension ViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return currentSplits.count
	}
}

class myRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		if isSelected == true {
			NSColor(named: "CurrentSplitColor")!.set()
			dirtyRect.fill()
		   }
	   }
}


extension ViewController: NSTableViewDelegate {
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		
		let cRow = myRowView()
		
		return cRow
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		cellIdentifier = tableColumn?.identifier
		
		if let cell = tableView.makeView(withIdentifier: cellIdentifier!, owner: nil) as? NSTableCellView {
			cell.textField?.delegate = self
			
			if timerState != .stopped {
				tableView.rowView(atRow: currentSplitNumber, makeIfNecessary: false)?.backgroundColor = NSColor(named: "CurrentSplitColor")!
			}
			
			if let imageCell = cell as? ImageButtonCellView {
				imageCell.cellNumber = row
				if let currentImage = currentSplits[row].splitIcon {
					imageCell.imageButton.image = currentImage
				} else {
					imageCell.imageButton.image = #imageLiteral(resourceName: "Game Controller")
				}
				return imageCell
			}
			
			currentSplits[row].roundTo = self.roundTo
			
			switch tableColumn?.identifier {
			case STVColumnID.splitTitleColumn:
				let lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.splitName
			case STVColumnID.currentSplitColumn:
				let lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.currentSplit.timeString
			case STVColumnID.differenceColumn:
				let sDiff = currentSplits[row].splitDiff
				cell.textField?.stringValue = sDiff
				if sDiff.hasPrefix("+"){
					cell.textField?.textColor = .systemRed
				} else if sDiff.hasPrefix("-"){
					cell.textField?.textColor = .systemGreen
				} else {
					cell.textField?.textColor = .systemBlue
				}
			case STVColumnID.bestSplitColumn:
				let best = currentSplits[row].bestSplit
				if best.timeString == TimeSplit().timeString {
					cell.textField!.stringValue = "00:00:00.00"
				}
				cell.textField!.stringValue = best.timeString
			case STVColumnID.previousSplitColumn:
				let prev = currentSplits[row].previousSplit
				cell.textField!.stringValue = prev.timeString
			default:
					break
			}
			return cell
		}
		return nil
	}

}

extension ViewController: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ obj: Notification) {
		
		splitsTableView.reloadData()
	}
	
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {

		let colIndex = splitsTableView.column(for: control)
		let colID = splitsTableView.tableColumns[colIndex].identifier
		let r = splitsTableView.row(for: control)

		let cellrow = splitsTableView.rowView(atRow: r, makeIfNecessary: false)
		let cell = cellrow?.view(atColumn: colIndex) as! NSTableCellView
		var editedSplit = currentSplits[r]
		
		if colID == STVColumnID.splitTitleColumn {
			editedSplit.splitName = cell.textField!.stringValue
		}
		switch colID {
		case STVColumnID.splitTitleColumn:
			editedSplit.splitName = cell.textField!.stringValue
		case STVColumnID.currentSplitColumn:
			editedSplit.currentSplit = TimeSplit(timeString: cell.textField!.stringValue)
		case STVColumnID.bestSplitColumn:
			editedSplit.bestSplit = TimeSplit(timeString: cell.textField!.stringValue)
			editedSplit.previousBest = TimeSplit(timeString: cell.textField!.stringValue)
		default:
			break
		}
		currentSplits[r] = editedSplit
		if colID != STVColumnID.bestSplitColumn {
			let lSplit = currentSplits[r].currentSplit.copy() as! TimeSplit
			let rSplit = currentSplits[r].bestSplit.copy() as! TimeSplit
			addBestSplit(lSplit: lSplit, rSplit: rSplit, splitRow: r)
			if lSplit < rSplit {
				currentSplits[r].previousBest = lSplit.tsCopy()
			}
		}
		
			return true
	}

	

}
