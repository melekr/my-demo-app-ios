//
//  BTViewController.swift
//  My Demo App
//
//  Created by Melek R on 2025-03-21.
//

import UIKit
import CoreData
import Backtrace

class ErrorReportingViewController: UIViewController {
    @IBOutlet weak var universeTextField: TextFieldBorderColor!
    
    @IBOutlet weak var tokenTextField: TextFieldBorderColor!
    
    struct BigData {
        var buffer: UnsafeMutablePointer<Int>?
    }
    var bigData: BigData?
    
    var memoryHog = [Data]()
    
    var sharedArray = [Int]()
    
    var kvoObject: KVOClass?
    
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
        universeTextField.text = Credentials.universeName
        tokenTextField.text = Credentials.backtraceToken
        
        universeTextField.delegate = self
        tokenTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        Credentials.universeName = universeTextField.text ?? ""
        Credentials.backtraceToken = tokenTextField.text ?? ""
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 1. Deadlock via Dispatch
    @IBAction func scenarioDeadlock(_ sender: Any) {
        // WebViewViewController
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 2. Unrecognized Selector
    @IBAction func scenarioUnrecognizedSelector(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "QRCodeScannerViewController") as! QRCodeScannerViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc class KVOClass: NSObject {
        @objc dynamic var observedValue: String = "initial"
    }
    
    // MARK: - 3. KVO Crash (Improper Observer Removal)
    @IBAction func scenarioKVO(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GeoLocationViewController") as! GeoLocationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 4. Unsafe Pointer After Deallocation
    @IBAction func scenarioUnsafePointer(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DrawingViewController") as! DrawingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 5. Background Thread UI Update (Auto Layout meltdown)
    @IBAction func scenarioLayoutMeltdown(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 6. Core Data Concurrency Violation
    @IBAction func scenarioCoreDataConcurrency (_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FaceIdViewController") as! FaceIdViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 7. GCD Race Condition (nondeterministic crash)
    @IBAction func scenarioGCDRace(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "TabBar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCartViewController") as! MyCartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 8. Objective-C NSException
    @IBAction func scenarioNSException(_ sender: Any) {
        let userInfo: [AnyHashable: Any] = [
            "length": 3,
            "index": 10,
            "description": "Attempted to access index 10 in array of length 3"
        ]

        NSException(
            name: .rangeException,
            reason: "Index 10 beyond bounds [0 .. 2]",
            userInfo: userInfo
        ).raise()
    }
    
    // MARK: - 9. Unhandled Error
    @IBAction func scenarioUncaughtError(_ sender: Any) {
        enum DemoError: Error {
            case unexpected
        }
        func throwError() throws {
            throw DemoError.unexpected
        }
        try! throwError()
    }
    
    // MARK: - 10. Bad Memory Access (SIGBUS / SIGSEGV)
    @IBAction func scenarioBadMemoryAccess(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        Engine.sharedInstance.isLogin = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 11. Force-Unwrapped Optional
    @IBAction func scenarioForceUnwrap(_ sender: Any) {
        let optionalString: String? = nil
        let _ = optionalString!
    }
    
    // MARK: - 12.  Out of Range Array Index
    @IBAction func scenarioIndexOutOfRange(_ sender: Any) {
        let array = [1, 2, 3]
        let _ = array[99]
    }
    
    // MARK: - 13. Stack Overflow
    @IBAction func scenarioFatalError(_ sender: Any) {
        triggerStackOverflow()
    }
    
    func triggerStackOverflow() {
        triggerStackOverflow()
    }
    
    // MARK: - 14. Manual Report
    @IBAction func sendManualReport(_ sender: Any) {
        BacktraceClient.shared?.send(attachmentPaths: []) { (result) in
            print("Manual report sent: \(result)")
        }
    }
    
    // MARK: - 15. OOM Trend
    @IBAction func oomTrendScenario(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            while true {
                var chunk = Data(count: 5 * 1024 * 1024)
                chunk.withUnsafeMutableBytes { buffer in
                    memset(buffer.baseAddress, 1, buffer.count)
                }
                self.memoryHog.append(chunk)
                print("Allocated \(self.memoryHog.count * 5) MB so far")
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
    
}

extension ErrorReportingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
