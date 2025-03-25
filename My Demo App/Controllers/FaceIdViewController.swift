//
//  FaceIdViewController.swift
//  My Demo App
//
//  Created by Mubashir on 17/09/21.
//

import UIKit
import CoreData
import Backtrace

class FaceIdViewController: UIViewController {
    
    @IBOutlet weak var allowLoginFaceBtn: UIButton!
    @IBOutlet weak var faceLoginMainBtn: UIButton!
    
    @IBOutlet weak var cartCountContView: UIView!
    
    @IBOutlet weak var cartCountLbl: UILabel!
    @IBOutlet weak var allowFaceIdLbl: UILabel!
    @IBOutlet weak var useFaceLbl: UILabel!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DemoModel")
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = BacktraceClient.shared?.addBreadcrumb("FaceID screen loaded",
                                                  attributes: [:],
                                                  type: .log,
                                                  level: .info)
        if Engine.sharedInstance.cartCount < 1 {
            cartCountContView.isHidden = true
        }
        biometricSupport()
    }
    
    func biometricSupport() {
        if !Engine.sharedInstance.isFaceSupported {
            allowLoginFaceBtn.isUserInteractionEnabled = false
            faceLoginMainBtn.isUserInteractionEnabled = false
            allowFaceIdLbl.textColor = .gray
            useFaceLbl.textColor = .gray
        }
        
        cartCountLbl.text = String(Engine.sharedInstance.cartCount)
        allowLoginFaceBtn.isSelected = false
        
        let backgroundContext = persistentContainer.newBackgroundContext()
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: backgroundContext)!
        let person = NSManagedObject(entity: entity, insertInto: backgroundContext)
        person.setValue("John Doe", forKey: "name")
        try? backgroundContext.save()
        
        DispatchQueue.global().async {
            let entity2 = NSEntityDescription.entity(forEntityName: "Person", in: backgroundContext)!
            let person2 = NSManagedObject(entity: entity2, insertInto: backgroundContext)
            person2.setValue("Jane Doe", forKey: "name")
            try? backgroundContext.save()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func allowLoginFaceButton(_ sender: UIButton) {
        if allowLoginFaceBtn.isSelected {
            allowLoginFaceBtn.isSelected = false
            Engine.sharedInstance.isFaceLogin = false
        }else{
            allowLoginFaceBtn.isSelected = true
            Engine.sharedInstance.isFaceLogin = true
        }
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
