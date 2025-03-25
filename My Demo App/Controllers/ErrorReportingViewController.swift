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
        DispatchQueue.main.sync {
        }
    }
    
    // MARK: - 2. Unrecognized Selector
    @IBAction func scenarioUnrecognizedSelector(_ sender: Any) {
        let obj = NSObject()
        let nonExistentSelector = NSSelectorFromString("nonExistentMethod:")
        obj.perform(nonExistentSelector)
    }
    
    @objc class KVOClass: NSObject {
        @objc dynamic var observedValue: String = "initial"
    }
    
    // MARK: - 3. KVO Crash (Improper Observer Removal)
    @IBAction func scenarioKVO(_ sender: Any) {
        let obj = KVOClass()
        self.kvoObject = obj
        
        obj.addObserver(self, forKeyPath: #keyPath(KVOClass.observedValue), options: [.new], context: nil)
        
        self.kvoObject = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            obj.observedValue = "KVO meltdown imminent"
        }
    }
    
    // MARK: - 4. Unsafe Pointer After Deallocation
    @IBAction func scenarioUnsafePointer(_ sender: Any) {
        let pointer = UnsafeMutablePointer<Int>.allocate(capacity: 10)
        pointer.initialize(repeating: 0, count: 10)
        bigData = BigData(buffer: pointer)
        
        pointer.deallocate()
        bigData?.buffer?[5] = 999
    }
    
    // MARK: - 5. Background Thread UI Update (Auto Layout meltdown)
    @IBAction func scenarioLayoutMeltdown(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            let newLabel = UILabel()
            newLabel.text = "Updating UI from background!"
            self.view.addSubview(newLabel)
        }
    }
    
    // MARK: - 6. Core Data Concurrency Violation
    @IBAction func scenarioCoreDataConcurrency (_ sender: Any) {
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
    
    // MARK: - 7. GCD Race Condition (nondeterministic crash)
    @IBAction func scenarioGCDRace(_ sender: Any) {
        sharedArray = []
        let group = DispatchGroup()
        
        for i in 0..<10000 {
            DispatchQueue.global().async(group: group) {
                self.sharedArray.append(i)
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("Finished appending. sharedArray.count = \(self.sharedArray.count)")
        }
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
        let invalidPointer = UnsafeMutableRawPointer(bitPattern: 0x1)!
        invalidPointer.storeBytes(of: 0xFF, as: UInt8.self)
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
