//
//  ViewController.swift
//  Mileston 7-9
//
//  Created by Anton Makeev on 04.03.2021.
//

import UIKit

class ViewController: UIViewController {

    var word = ""
    var allWords = [String]()
    let alphabeth = Array("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ")
    var usedLetters = [String]()
    var answerLabel: UILabel!
    var attemptsLabel: UILabel!
    var letterButtons = [UIButton]()
    var knownAnswer: String = "" {
        didSet {
            answerLabel.text = knownAnswer
        }
    }
    var buttonsView: UIView!
    var attemptsLeft = 0 {
        didSet {
            attemptsLabel.text = "Attempts left: \(attemptsLeft)"
        }
    }
    
    let rowsNumberInPortrait = 8
    let rowsNumberInLandscape = 5
    let maxAttepmts = 10
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        attemptsLabel = UILabel()
        attemptsLabel.translatesAutoresizingMaskIntoConstraints = false
        attemptsLabel.numberOfLines = 0
        attemptsLabel.sizeToFit()
        view.addSubview(attemptsLabel)
        
        let restartButton = UIButton()
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        restartButton.addTarget(self, action: #selector(tappedRestart), for: .touchUpInside)
        view.addSubview(restartButton)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .center
        answerLabel.font = UIFont.monospacedSystemFont(ofSize: 40, weight: .bold)
        answerLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answerLabel)
        
        for letter in alphabeth {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(String(letter), for: .normal)
            button.addTarget(self, action: #selector(tapLetter), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
            button.isEnabled = false
            letterButtons.append(button)
        }
        
        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(buttonsView)
        updateButtons()
        
        NSLayoutConstraint.activate([
            attemptsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            attemptsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            restartButton.topAnchor.constraint(equalTo: attemptsLabel.topAnchor),
            restartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            restartButton.heightAnchor.constraint(equalTo: attemptsLabel.heightAnchor),
            answerLabel.topAnchor.constraint(equalTo: attemptsLabel.bottomAnchor),
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 10),
            buttonsView.centerXAnchor.constraint(equalTo: answerLabel.centerXAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            //buttonsView.widthAnchor.constraint(equalToConstant: 350),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil
        , completion: { _ in self.updateButtons() })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func loadWords() {
        DispatchQueue.global().async {
            if let url = Bundle.main.url(forResource: "russian", withExtension: "txt") {
                print(url)
                if let fileString = try? String(contentsOf: url, encoding: .windowsCP1251) {
                    self.allWords = fileString.components(separatedBy: "\n")
                        .filter { $0.count <= 10 }
                        .map { $0.uppercased() }
                    print(self.allWords.count)
                } else { print("string") }
            } else { print("bundle") }
            DispatchQueue.main.async {
                self.restartGame()
            }
        }
    }
    
    func updateButtons() {
        let rowsNumber: Int
        let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        switch statusBarOrientation {
        case .portrait, .portraitUpsideDown :
            rowsNumber = rowsNumberInPortrait
        case .none:
            return
        default:
            rowsNumber = rowsNumberInLandscape
        }
        buttonsView.subviews.forEach { $0.removeFromSuperview() }
        var constraints = [NSLayoutConstraint]()
        
        let columnsCount = alphabeth.count / rowsNumber
        var previousSV: UIStackView!
        let rowsWithExtraColumn = alphabeth.count % rowsNumber
        for row in 0..<rowsNumber {
            //calculate used indices taking in account previous extra columns
            let firstIndex = columnsCount * row + min(row, rowsWithExtraColumn)
            //calculate last index with extra column id needed
            let lastIndex = firstIndex + columnsCount + (row < rowsWithExtraColumn ? 1 : 0)
            let indexes = firstIndex..<lastIndex
            let sv = UIStackView()
            sv.translatesAutoresizingMaskIntoConstraints = false
            sv.distribution = .fillEqually
            sv.spacing = 2
            sv.axis = .horizontal
            for i in indexes {
                sv.addArrangedSubview(letterButtons[i])
            }
            buttonsView.addSubview(sv)
            constraints += [
                sv.leadingAnchor.constraint(equalTo: sv.superview!.leadingAnchor, constant: 1),
                sv.trailingAnchor.constraint(equalTo: sv.superview!.trailingAnchor, constant: -1),
                sv.topAnchor.constraint(equalTo: row == 0 ? sv.superview!.topAnchor : previousSV.bottomAnchor, constant: 2)
            ]
            
            sv.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
            if row != 0 {
                constraints.append(sv.heightAnchor.constraint(equalTo: previousSV.heightAnchor))
            }
            previousSV = sv
        }
        constraints.append(previousSV.bottomAnchor.constraint(equalTo: previousSV.superview!.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func tapLetter(_ sender: UIButton) {
        if let letter = sender.titleLabel?.text {
            let isCorrect = checkLetter(letter)
            sender.isEnabled = false
            sender.backgroundColor = isCorrect ? UIColor.green.withAlphaComponent(0.1) : UIColor.red.withAlphaComponent(0.1)
            
            //if game ends
            if !knownAnswer.contains("_") || attemptsLeft == 0 {
                let ac = UIAlertController(title: (attemptsLeft == 0 ? "Поражение. Вы исчерпали все попытки." : "Победа!"), message: "Верное слово: \(word)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Новая игра", style: .default, handler: { _ in self.restartGame() }))
                present(ac, animated: true)
            }
        }
    }
    
    @discardableResult
    func checkLetter(_ letter: String) -> Bool {
        usedLetters.append(letter)
        if word.contains(letter) {
            var newAnswer = ""
            for char in word {
                if usedLetters.contains(String(char)) {
                    newAnswer.append(char)
                } else {
                    newAnswer.append("_")
                }
            }
            knownAnswer = newAnswer
            return true
        } else {
            attemptsLeft -= 1
            return false
        }
    }
    
    func restartGame() {
        usedLetters.removeAll()
        for button in letterButtons {
            button.isEnabled = true
            button.backgroundColor = nil
        }
        word = allWords.randomElement() ?? "ВИСИЛИЦА"
        knownAnswer = String(repeating: "_", count: word.count)
        attemptsLeft = maxAttepmts
    }
    
    @objc func tappedRestart() {
        let ac = UIAlertController(title: "Перезапустить игру?", message: "Текущий прогресс будет утерян", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Новая игра", style: .destructive, handler: { _ in self.restartGame() }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(ac, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
    }
}

