//
//  DefaultTableViewDataSource.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 25.05.2023.
//

import UIKit.UITableView

@MainActor protocol TableViewDataSourceDelegate: AnyObject {
    func didSelectCell(at indexPath: IndexPath)
    func didCommit(editingStyle: UITableViewCell.EditingStyle, at indexPath: IndexPath)
    func scrollViewDidEndScrollingAnimation()
}

extension TableViewDataSourceDelegate {
    func didSelectCell(at indexPath: IndexPath) {}
    func didCommit(editingStyle: UITableViewCell.EditingStyle, at indexPath: IndexPath) {}
    func scrollViewDidEndScrollingAnimation() {}

}

typealias TableViewDataSource = UITableViewDelegate & UITableViewDataSource

class DefaultTableViewDataSource: NSObject, TableViewDataSource {

    private var sections: [TableSectionController]

    weak var delegate: TableViewDataSourceDelegate?

    init(sections: [TableSectionController]) {
        self.sections = sections
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfCells()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].canEditCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return sections[indexPath.section].editingStyleForCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.didCommit(editingStyle: editingStyle, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].cellController(at: indexPath).didSelectCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].header()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].footer()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footerHeight()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].estimatedRowHeight() ?? UITableView.automaticDimension
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation()
    }
}
