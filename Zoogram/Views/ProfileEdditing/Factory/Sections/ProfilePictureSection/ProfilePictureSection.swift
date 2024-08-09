//
//  ProfilePictureSectionController.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 10.01.2024.
//

import UIKit.UITableView

class ProfilePictureSection: TableSectionController {

    override func header() -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
    }

    override func headerHeight() -> CGFloat {
        return UITableView.automaticDimension
    }

    override func rowHeight() -> CGFloat {
        return UITableView.automaticDimension
    }
}