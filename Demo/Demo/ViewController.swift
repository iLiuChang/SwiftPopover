//
//  ViewController.swift
//  Demo
//
//  Created by LC on 2025/1/7.
//

import UIKit

class ViewController: UIViewController {

    
    fileprivate var texts = ["Edit", "Delete", "Report"]

    fileprivate var popover: Popover!

    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectLeft(_ sender: UIButton) {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 135))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        self.popover = Popover(contentView: tableView)
        self.popover.delegate = self
        self.popover.overlayView.backgroundColor = .clear
        self.popover.layer.shadowColor = UIColor(red: 0.02, green: 0.24, blue: 0.13, alpha: 0.6).cgColor
        self.popover.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.popover.layer.shadowRadius = 12
        self.popover.layer.shadowOpacity = 1
        self.popover.show(from: sender, in: self.view)
        
        // remove event
//        self.popover.overlayView.removeTarget(self.popover, action: #selector(Popover.dismiss), for: .touchUpInside)
    }
    
    @IBAction func selectCenter(_ sender: UIButton) {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 135))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        self.popover = Popover(contentView: tableView)
        self.popover.sideOffset = 20
        self.popover.direction = .down
        self.popover.delegate = self
        self.popover.show(from: sender, in: self.view)
        
//        self.popover.show(point: sender.center, in: self.view)
    }
    
}

extension ViewController: PopoverDelegate {
    func willShowPopover(_ popover: Popover) {
        print("willShowPopover")
    }
    
    func didShowPopover(_ popover: Popover) {
        print("didShowPopover")
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.popover.dismiss()
    }
}
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
        return cell
    }
}
