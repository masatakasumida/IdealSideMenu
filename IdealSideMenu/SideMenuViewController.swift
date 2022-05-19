//
//  SideMenuViewController.swift
//  IdealSideMenu
//
//  Created by 住田雅隆 on 2022/05/15.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    var sideMenuTitle = ["menu1","menu2","menu3"]
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
                
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // 右にドラッグしても反応させない
        guard translation.x <= 0 else { return }
        
        view.frame.origin = CGPoint(x: self.pointOrigin!.x + translation.x, y: 0)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            //ドラッグする移動量の速さに応じて画面を閉じる
            if dragVelocity.x <= -500 {
                self.dismiss(animated: true, completion: nil)
            } else {
                
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 0)
                }
            }
        }
    }
}
extension SideMenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuTitle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = sideMenuTitle[indexPath.row]
        return cell
    }
}
