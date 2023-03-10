//
//  BankManager.swift
//  Created by kaki, songjun.
//  Copyright © yagom academy. All rights reserved.
//

import Foundation

struct BankManager {
    private var numberOfClient = 0
    private var waitingQueue = Queue<Client>()
    private let loanSemaphore = DispatchSemaphore(value: 1)
    private let depositSemaphore = DispatchSemaphore(value: 2)
    private let group = DispatchGroup()
    
    mutating func setupWaitingQueueAndClientNumber() {
        let randomNumberOfClient = Int.random(in: 10...30)
        
        for number in 1...randomNumberOfClient {
            let client = Client(clientNumber: number,
                                requstedTask: .init(rawValue: Int.random(in: 1...2)) ?? .deposit)
            waitingQueue.enqueue(client)
        }
        
        numberOfClient = waitingQueue.size
    }
    
    mutating func processBusiness() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        while !waitingQueue.isEmpty {
            guard let client = waitingQueue.dequeue() else { return }
            processBankTask(client)
        }
        group.wait()
        
        let wasteTime = CFAbsoluteTimeGetCurrent() - startTime
        presentBusinessResult(time: wasteTime)
    }
    
    private func processBankTask(_ client: Client) {
        if client.requstedTask == .loan {
            DispatchQueue.global().async(group: group) {
                loanSemaphore.wait()
                print("\(client.clientNumber)번 고객 \(client.requstedTask.taskName)업무 시작")
                Thread.sleep(forTimeInterval: 1.1)
                print("\(client.clientNumber)번 고객 \(client.requstedTask.taskName)업무 완료")
                loanSemaphore.signal()
            }
        } else {
            DispatchQueue.global().async(group: group) {
                depositSemaphore.wait()
                print("\(client.clientNumber)번 고객 \(client.requstedTask.taskName)업무 시작")
                Thread.sleep(forTimeInterval: 0.7)
                print("\(client.clientNumber)번 고객 \(client.requstedTask.taskName)업무 완료")
                depositSemaphore.signal()
            }
        }
    }
    
    private func presentBusinessResult(time: CFAbsoluteTime) {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(numberOfClient)명이며, 총 엄무시간은 \(String(format: "%.2f", time))초입니다.")
    }
}
