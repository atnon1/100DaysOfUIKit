//
//  ViewController.swift
//  Milestone22-24
//
//  Created by Anton Makeev on 16.04.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        label.bounceOut(duration: 5)
        var array = [2,3,5,61,66,2,3,26,6]
        array.remove(item: 3)
        print(array)
        array.remove(item: 3)
        print(array)
        var stringArray = ["s","w","s", "d"]
        stringArray.remove(item: "w")
        print(stringArray)
        var arrayempty = [Int]()
        arrayempty.remove(item: 5)
        print(arrayempty)
    }


}

