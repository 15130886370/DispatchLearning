//
//  ViewController.swift
//  DispatchLeaning
//
//  Created by 七环第一帅 on 2021/11/29.
//

import UIKit

class ViewController: UIViewController {
    
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.title = "首页"
    }
    
    func testDeadLock() {
        let queue1 = DispatchQueue(label: "queue1")
        let queue2 = DispatchQueue(label: "queue2")
        
        queue1.async {
            print("任务1")
            queue2.sync {
                print("任务2")
            }
        }
    }
    
    func semaphoreTest() {
        semaphore.signal()
        semaphore.signal()
        semaphore.signal()

        semaphore.wait()
        print("\(Date()) \(Thread.current) hello_1")

        semaphore.wait()
        print("\(Date()) \(Thread.current) hello_2")

        semaphore.wait()
        print("\(Date()) \(Thread.current) hello_2")
        
        // 延迟3秒去另一个线程异步添加信号量
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("\(Date()) \(Thread.current) 信号量+1")
            self.semaphore.signal()
        }

        semaphore.wait()
        print("\(Date()) \(Thread.current) hello_4")
    }
    
    func request() {
        let queue = DispatchQueue.init(label: "com.testxxx",attributes: .concurrent)
        let semphore = DispatchSemaphore(value: 2)
        
        queue.async {
            sleep(1)
            print("完成回调1, Thread = \(Thread.current)")
            semphore.signal()
        }
        
        queue.async {
            sleep(1)
            print("完成回调2, Thread = \(Thread.current)")
            semphore.signal()
        }
        
        queue.async {
            print("完成回调3, Thread = \(Thread.current)")
        }
        
        queue.async {
            print("完成回调4, Thread = \(Thread.current)")
            semphore.signal()
        }
        
        semphore.wait()
        print("wait1---")
        
        semphore.wait()
        print("wait2---")
        
        semphore.wait()
        print("结束---")
    }
    
    private func question1() {
        print("question1 - 开始")
        
        DispatchQueue.main.sync {
            print("main.sync - 开始")
            sleep(1)
            print("main.sync - 结束")
            
        }
    
        sleep(1)
        print("question1 - 结束")
    }
    
    private func question2() {
        print("Thread = \(Thread.current)")
        print("1")
        DispatchQueue.global().sync { //task1
            print("Thread = \(Thread.current)")
            print("2")
            print("5")
            DispatchQueue.main.async { //task2
                print("Thread = \(Thread.current)")
                sleep(UInt32(0.2))
                print("3")
            }
        }
        DispatchQueue.main.async { //task3
            print("Thread = \(Thread.current)")
            print("8")
        }
        
        print("Thread = \(Thread.current)")
        print("4")
        sleep(UInt32(0.2))
        print("6")
    }
    
    private func question3() {
        print("1")
        let que = DispatchQueue.init(label: "thread")
        que.async {
            print("2")
            DispatchQueue.main.sync {
                print("3")
                que.sync {
                    print("4")
                }
            }
            print("5")
        }
        print("6")
        que.async {
            print("7")
        }
        print("8")
    }

        
    private func setupUI() {
        
        view.addSubview(serialAsyncButton)
        serialAsyncButton.translatesAutoresizingMaskIntoConstraints = false
        serialAsyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        serialAsyncButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        serialAsyncButton.addTarget(self, action: #selector(serialAsync(_:)), for: .touchUpInside)
        
        
        view.addSubview(serialSyncButton)
        serialSyncButton.translatesAutoresizingMaskIntoConstraints = false
        serialSyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        serialSyncButton.topAnchor.constraint(equalTo: serialAsyncButton.bottomAnchor, constant: 20).isActive = true
        serialSyncButton.addTarget(self, action: #selector(serialSync(_:)), for: .touchUpInside)
        
        
        view.addSubview(concurrentAsyncButton)
        concurrentAsyncButton.translatesAutoresizingMaskIntoConstraints = false
        concurrentAsyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        concurrentAsyncButton.topAnchor.constraint(equalTo: serialSyncButton.bottomAnchor, constant: 20).isActive = true
        concurrentAsyncButton.addTarget(self, action: #selector(concurrentAsync(_:)), for: .touchUpInside)
        
        view.addSubview(concurrentSyncButton)
        concurrentSyncButton.translatesAutoresizingMaskIntoConstraints = false
        concurrentSyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        concurrentSyncButton.topAnchor.constraint(equalTo: concurrentAsyncButton.bottomAnchor, constant: 20).isActive = true
        concurrentSyncButton.addTarget(self, action: #selector(concurrentSync(_:)), for: .touchUpInside)
        
        view.addSubview(mainAsyncButton)
        mainAsyncButton.translatesAutoresizingMaskIntoConstraints = false
        mainAsyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainAsyncButton.topAnchor.constraint(equalTo: concurrentSyncButton.bottomAnchor, constant: 20).isActive = true
        mainAsyncButton.addTarget(self, action: #selector(mainAsyc(_:)), for: .touchUpInside)
        
    }
    
    
    private lazy var serialAsyncButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("串行异步", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        
        return button
    }()
    
    private lazy var serialSyncButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("串行同步", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        
        return button
    }()
    
    private lazy var concurrentAsyncButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("并发异步", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        
        return button
    }()
    
    private lazy var concurrentSyncButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("并发同步", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        
        return button
    }()
    
    private lazy var mainAsyncButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("main异步", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        
        return button
    }()
    
    @objc func serialAsync(_ sender: UIButton) {
        
        let serialQueue = DispatchQueue.init(label: "com.wsecar1")
        
        serialQueue.async {
            sleep(1)
            print("串行异步 1， thread = \(Thread.current)")
        }
        
        serialQueue.async {
            sleep(2)
            print("串行异步 2， thread = \(Thread.current)")
        }
        
        serialQueue.async {
            print("串行异步 3， thread = \(Thread.current)")
        }
        
        serialQueue.async {
            print("串行异步 4， thread = \(Thread.current)")
        }
    }
    
    @objc func serialSync(_ sender: UIButton) {
        
        let serialQueue = DispatchQueue.init(label: "com.wsecar2")
        
        serialQueue.sync {
            sleep(1)
            print("串行同步 1， thread = \(Thread.current)")
        }
        
        serialQueue.sync {
            sleep(2)
            print("串行同步 2， thread = \(Thread.current)")
        }
        
        serialQueue.sync {
            print("串行同步 3， thread = \(Thread.current)")
        }
        
        serialQueue.sync {
            print("串行同步 4， thread = \(Thread.current)")
        }
    }
    
    
    @objc func concurrentAsync(_ sender: UIButton) {
        
        let concurrentQueue = DispatchQueue.init(label: "com.wsecar3", qos: .userInteractive, attributes: .concurrent)
        
        concurrentQueue.async {
            
            sleep(1)
            print("并发异步 1， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            sleep(2)
            print("并发异步 2， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            print("并发异步 3， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            print("并发异步 4， thread = \(Thread.current)")
        }
    }
    
    @objc func concurrentSync(_ sender: UIButton) {
        
        let concurrentQueue = DispatchQueue.init(label: "com.wsecar4", qos: .userInteractive, attributes: .concurrent)
        
        concurrentQueue.sync {
            
            sleep(1)
            print("并发同步 1， thread = \(Thread.current)")
        }
        
        concurrentQueue.sync {
            sleep(2)
            print("并发同步 2， thread = \(Thread.current)")
        }
        
        concurrentQueue.sync {
            print("并发同步 3， thread = \(Thread.current)")
        }
        
        concurrentQueue.sync {
            print("并发同步 4， thread = \(Thread.current)")
        }
    }
    
    @objc func mainAsyc(_ sender: UIButton) {
        
        let concurrentQueue = DispatchQueue.main
        
        
        DispatchQueue.global().sync {
            
            sleep(1)
            print("mainAsyc 1， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            sleep(2)
            print("mainAsyc 2， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            print("mainAsyc 3， thread = \(Thread.current)")
        }
        
        
        concurrentQueue.async {
            print("mainAsyc 4， thread = \(Thread.current)")
        }
        
        concurrentQueue.async {
            print("mainAsyc 5， thread = \(Thread.current)")
        }

    }
}
