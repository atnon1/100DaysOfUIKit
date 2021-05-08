//
//  ViewController.swift
//  Milestone 28-30
//
//  Created by Anton Makeev on 06.05.2021.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController {

    var allPairs = [String:String]()
    var currentPairs = [String:String]()
    var cards = [String]()
    var selectedCardIndices = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPairsList()
        createCurrentGameCardList()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWords))
    }
    
    @objc func addWords() {
        let context = LAContext()
        var error: NSError?
        let askWords = { [weak self] in
            let ac = UIAlertController(title: "Add country and capital", message: nil, preferredStyle: .alert)
            ac.addTextField { tf in
                tf.placeholder = "Country"
            }
            ac.addTextField { tf in
                tf.placeholder = "Capital"
            }
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let country = ac.textFields?[0].text, let capital = ac.textFields?[1].text {
                    if !country.isEmpty && !capital.isEmpty {
                        self?.allPairs[country] = capital
                        self?.createCurrentGameCardList()
                        self?.collectionView.reloadData()
                    }
                }
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true)
        }
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "App needs to identify parent"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        askWords()
                    }
                }
            }
        } else {
            askWords()
        }
    }
    
    func createPairsList() {
        let path = Bundle.main.path(forResource: "pairs", ofType: "txt")!
        let pairsString = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
        for pair in pairsString.components(separatedBy: "\n") {
            let pairArray = pair.components(separatedBy: ":")
            allPairs[pairArray[0]] = pairArray[1]
        }
    }
    
    func createCurrentGameCardList() {
        let pairsNumber = Int.random(in: 7...allPairs.count)
        currentPairs = allPairs
        while currentPairs.count > pairsNumber {
            currentPairs.removeValue(forKey: allPairs.randomElement()!.key)
        }
        cards.removeAll()
        selectedCardIndices = []
        for pair in currentPairs {
            cards.append(pair.key)
            cards.append(pair.value)
        }
        cards.shuffle()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GameCardView else { fatalError() }
        cell.title.text = cards[indexPath.item]
        if selectedCardIndices.contains(indexPath) {
            cell.frontView.isHidden = false
            cell.backView.isHidden = true
        } else {
            cell.frontView.isHidden = true
            cell.backView.isHidden = false
        }
        cell.configureSides()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardTapped(at: indexPath)
    }
    

    func cardTapped(at indexPath: IndexPath) {
        
        let wasOpen = selectedCardIndices.contains(indexPath)
        if selectedCardIndices.count >= 2 {
            for indexPath in selectedCardIndices.sorted().reversed() {
                gameCardCell(at: indexPath)?.flipCard()
            }
            selectedCardIndices.removeAll()
        }
        
        if let index = selectedCardIndices.firstIndex(of: indexPath) {
            selectedCardIndices.remove(at: index)
        } else if !wasOpen {
            selectedCardIndices.append(indexPath)
            gameCardCell(at: indexPath)?.flip()
        }
        
        removeMatches()
    }
    
    func gameCardCell(at indexPath : IndexPath) -> GameCardView? {
        if let cell = collectionView.cellForItem(at: indexPath) as? GameCardView {
            return cell
        } else {
             return nil
        }
    }
    
    func isOpenedCardMatch(with card: GameCardView) {
        
    }

    func removeMatches() {
        guard selectedCardIndices.count == 2 else { return }
        
        let firstIndex = selectedCardIndices[0].item
        let secondIndex = selectedCardIndices[1].item
        let firstWord = cards[firstIndex]
        let secondWord = cards[secondIndex]
        if currentPairs[firstWord] == secondWord || currentPairs[secondWord] == firstWord {
            collectionView.isUserInteractionEnabled = false
            cards.remove(at: max(firstIndex, secondIndex))
            cards.remove(at: min(firstIndex, secondIndex))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.collectionView.deleteItems(at: [IndexPath(item: firstIndex, section: 0), IndexPath(item: secondIndex, section: 0)])
                self?.collectionView.isUserInteractionEnabled = true
            }
            selectedCardIndices.removeAll()
        }
    }
}

