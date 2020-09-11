//
//  ViewController.swift
//  HangManGameDay41
//
//  Created by Samat on 29.07.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var currentAnswer: UITextField!
    var letterButtons = [UIButton]()
    
    var solutions = [String]()
    var currentSolution = ""
    
    var levelLabel: UILabel!
    var wrongAnswersLabel: UILabel!
    
    var level = 1 {
        didSet {
            levelLabel?.text = "Level\n\n\(level)"
        }
    }
    
    var wrongAnswers = 0 {
        didSet {
            wrongAnswersLabel.text = "Wrong\nAnswers\n\(wrongAnswers)"
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        wrongAnswersLabel = UILabel()
        wrongAnswersLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongAnswersLabel.numberOfLines = 0
        wrongAnswersLabel.textAlignment = .center
        wrongAnswersLabel.text = "Wrong\nAnswers\n0"
        view.addSubview(wrongAnswersLabel)
        
        levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.numberOfLines = 0
        levelLabel.textAlignment = .center
        levelLabel.text = "Level\n\n1"
        view.addSubview(levelLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "ANSWER"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 32)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            wrongAnswersLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            wrongAnswersLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            levelLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            levelLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 360),
            buttonsView.heightAnchor.constraint(equalToConstant: 120),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 40
        let height = 40
        
        for row in 0..<3 {
            for column in 0..<9 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                letterButton.setTitle("W", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hangman game: Movies"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.configureSolutions()
            
            DispatchQueue.main.async { [weak self] in
                self?.configureButtons()
                self?.configureAnswer()
            }
        }
        
        
    }

    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        sender.isHidden = true
        
        guard currentSolution.contains(buttonTitle) else {
            wrongAnswers += 1
            if wrongAnswers == 7 { loseGame() }
            return
        }
        
        guard var newAnswer = currentAnswer.text else { return }
        
        for (index, letter) in currentSolution.enumerated() {
            if String(letter) == buttonTitle {
                let rs = newAnswer.index(newAnswer.startIndex, offsetBy: index)
                let re = newAnswer.index(newAnswer.startIndex, offsetBy: index + 1)
                newAnswer.replaceSubrange(rs..<re, with: String(letter))
                currentAnswer.text = newAnswer
            }
        }

        if let last = solutions.last {
            if newAnswer == last.uppercased() {
                endGame()
                return
            }
        }
        
        guard newAnswer == currentSolution else { return }
        levelUp()
    }
    
    func showButtons() {
        for button in letterButtons.dropLast() {
            if button.isHidden { button.isHidden = false }
        }
    }
    
    func configureAnswer() {
        currentSolution = solutions[level - 1].uppercased()
        
        var answerText = ""
        for letter in currentSolution {
            answerText += letter == " " ? " " : "?"
        }
        currentAnswer?.text = answerText
    }
    
    
    func configureSolutions() {
        if let levelFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                var words = levelContents.components(separatedBy: "\n")
                words.shuffle()
                
                for word in words {
                    if word != "" {
                        solutions.append(word)
                    }
                }
            }
        }
        print(solutions)
    }
    
    
    func configureButtons() {
        for (index, button) in letterButtons.enumerated() {
            if index < letters.count {
                button.setTitle(letters[index], for: .normal)
            }
        }
        letterButtons.last?.isHidden = true
    }
    
    
    func levelUp() {
        let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level? 🎃", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: nextLevel))
        present(ac, animated: true)
    }
    
    
    func loseGame() {
        let ac = UIAlertController(title: "Man Hanged 🙁", message: "Correct answer: \(currentSolution)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Start Again", style: .default, handler: startGame))
        present(ac, animated: true)
    }
    
    
    func endGame() {
        let ac = UIAlertController(title: "Well done!", message: "You Win! 🎊🎉 ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Start Again", style: .default, handler: startGame))
        present(ac, animated: true)
    }
    
    
    func startGame(action: UIAlertAction) {
        level = 1
        wrongAnswers = 0
        solutions.shuffle()
        configureAnswer()
        showButtons()
    }
    
    
    func nextLevel(action: UIAlertAction) {
        level += 1
        wrongAnswers = 0
        configureAnswer()
        showButtons()
    }
}

