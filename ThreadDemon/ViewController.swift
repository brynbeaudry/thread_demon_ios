//
//  ViewController.swift
//  ThreadDemon
//
//  Created by Bryn Beaudry on 2017-10-27.
//  Copyright © 2017 Bryn Beaudry. All rights reserved.
//

import UIKit

//Create a singleton in swift

class Data{
    var value : UInt!
    var status : String!
    init(){
        value = 0
        status = "START"
    }
}
let _data = Data()
var data : Data {
    return _data
}

class ViewController: UIViewController {
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var labelProdReg: UILabel!
    
    @IBOutlet weak var labelProdHttp: UILabel!
    @IBOutlet weak var labelData: UILabel!
    @IBOutlet weak var labelTotalCon: UILabel!
    @IBOutlet weak var LabelTotalProd: UILabel!
    //create a semaphore, the value is the amount of threads that can enter the critical region in this case.
    let sem = DispatchSemaphore(value: 1)
    
    //Create thread conditions
    let not_empty : NSCondition = NSCondition()
    let not_full : NSCondition = NSCondition()
    
    //define constants, max value I'm allow the UInt to reach before I halt producing
    let MAX_VALUE = 3000000

    //increments the amount of items in the shared memory by 1, when it can
    func httpDump(add: UInt){
        
        //decrement the sem, lock after entering
        sem.wait(timeout: DispatchTime.distantFuture)
        
        //while the data container is full, wait using Ns condition
        while(!(data.value < MAX_VALUE)){
            //wait until not full
            not_full.wait()
        }
        //enter critical section
        
        //decrement value by 1, change status to consuming
        data.value? -= UInt(add)
        data.status = "HTTP PRODUCING"
        
        //Update UI Thread, syncronously, so that the background thread doesn't unlock and leave the critical section before the UI is updated. You don't this has to complete before exiting critical region
        DispatchQueue.main.sync{
            //
        }
        
        //leave critical section
        
        //unlock critical section
        sem.signal()
    }
    
    func produce(add: UInt){
        
        //decrement the sem, lock after entering
        sem.wait(timeout: DispatchTime.distantFuture)
        
        //while the data container is full, wait using Ns condition
        while(!(data.value < MAX_VALUE)){
            //wait until not full
            not_full.wait()
        }
        //enter critical section
        
        //decrement value by 1, change status to consuming
        data.value? -= UInt(add)
        data.status = "PRODUCING"
        
        //Update UI Thread, syncronously, so that the background thread doesn't unlock and leave the critical section before the UI is updated. You don't this has to complete before exiting critical region
        DispatchQueue.main.sync{
            //
        }
        
        //leave critical section
        
        //unlock critical section
        sem.signal()
    }
    
    //consumes or decrements the value in the shared data, when it can
    func consume(){
        //decrement the sem, lock after entering
        sem.wait(timeout: DispatchTime.distantFuture)
        
        //while there isn't anything to consume, wait using Ns condition
        while(!(data.value > 0)){
            //wait until not empty
            not_empty.wait()
        }
        //enter critical section
        
        //decrement value by 1, change status to consuming
        data.value? -= UInt(1)
        data.status = "CONSUMING"
        
        //Update UI Thread, syncronously, so this has to complete before exiting critical region
        DispatchQueue.main.sync{
            //update ui
        }
        
        //leave critical section
        
        //unlock critical section
        sem.signal()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //make a bunch of consumer operations on a dispatch queue
        
        //do an http call to get a random number from the internet on a different thread
        //at a timed interval
        
        //dispatch once every x seconds
        //make a custom timer-based reference to the disptach queue
        let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        t.schedule(deadline: .now(), repeating: .seconds(5), leeway: .seconds(1))
        t.setEventHandler(handler: { print("Define function for getting radnom number from an http request") })
        var produceOperations : [Operation] = [Operation]()
        for i in 0..<10{
            //in here we can set the attribute members of each block operation, like qos and dependancies. Ie arr[0].addDepemndancy(arr[1])!
            produceOperations.append(BlockOperation(block: {print("Define the operation")}))
        }
        let prodQ = OperationQueue()
        prodQ.addOperations(produceOperations)
        //This executes the queue asynchronously, because adding to the queue executes and changes the default setting to asynchronous.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

