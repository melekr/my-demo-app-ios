//
//  DrawingViewController.swift
//  My Demo App
//
//  Created by Mubashir on 17/09/21.
//

import UIKit
import Backtrace

class DrawingViewController: UIViewController, YPSignatureDelegate {
    
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    
    @IBOutlet weak var cartCountContView: UIView!
    
    @IBOutlet weak var cartCountLbl: UILabel!
    
    var bigData: BigData?
    
    struct BigData {
        var buffer: UnsafeMutablePointer<Int>?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = BacktraceClient.shared?.addBreadcrumb("Drawing screen loaded",
                                                  attributes: [:],
                                                  type: .log,
                                                  level: .info)
        cartCountLbl.text = String(Engine.sharedInstance.cartCount)
        if Engine.sharedInstance.cartCount < 1 {
            cartCountContView.isHidden = true
        }
        prepareSignatureView()
    }
    
    func prepareSignatureView() {
        signatureView.delegate = self
        
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 10)
        pointer.initialize(repeating: 0, count: 10)
        bigData = BigData(buffer: pointer)
        
        pointer.deallocate()
        bigData?.buffer?[5] = 999
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButton(_ sender: Any) {
        self.signatureView.clear()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            
//            self.signatureView.clear()
        }
    }
    
    func didStart(_ view : YPDrawSignatureView) {
        print("Started Drawing")
        

    }
    
    func didFinish(_ view : YPDrawSignatureView) {
        print("Finished Drawing")
    }
    
    @IBAction func catalogButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CatalogViewController") as! CatalogViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cartButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCartViewController") as! MyCartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func moreButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

