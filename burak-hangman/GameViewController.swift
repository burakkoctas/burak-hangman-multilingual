import UIKit

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wrongGuessesLabel: UILabel!
    @IBOutlet weak var remainingAttemptsLabel: UILabel!
    @IBOutlet weak var letterButtonsContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel! // Yeni skor etiketi
    
    // Ana sayfadan aktarılacak
    var gameModel: GameModel!
    
    // Harf butonları
    private var letterButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        createLetterButtons()
        updateUI()
    }
    
    // UI elemanlarını ayarlama
    private func setupUI() {
        backButton.setTitle(LocalizationHelper.shared.getTranslation(for: "back"), for: .normal)
        resetButton.setTitle(LocalizationHelper.shared.getTranslation(for: "reset"), for: .normal)
        wrongGuessesLabel.text = LocalizationHelper.shared.getTranslation(for: "wrong_guesses")
        
        // Yeni skor etiketi
        updateScoreLabel()
    }
    
    // Skor etiketini güncelleme
    private func updateScoreLabel() {
        scoreLabel.text = LocalizationHelper.shared.getFormattedTranslation(
            for: "current_score",
            gameModel.currentScore
        )
    }
    
    // Harf butonlarını dinamik olarak oluşturma
    private func createLetterButtons() {
        // Eski butonları temizle
        letterButtons.forEach { $0.removeFromSuperview() }
        letterButtons.removeAll()
        
        let alphabet = gameModel.currentLanguage.alphabet
        
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        let horizontalSpacing: CGFloat = 5
        let verticalSpacing: CGFloat = 5
        
        // Bir satırdaki buton sayısı
        let buttonsPerRow = Int((letterButtonsContainer.bounds.width + horizontalSpacing) / (buttonWidth + horizontalSpacing))
        
        for (index, letter) in alphabet.enumerated() {
            let col = index % buttonsPerRow
            let row = index / buttonsPerRow
            
            let x = CGFloat(col) * (buttonWidth + horizontalSpacing)
            let y = CGFloat(row) * (buttonHeight + verticalSpacing)
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            button.setTitle(String(letter), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.layer.cornerRadius = 5
            button.backgroundColor = UIColor.systemBlue
            button.setTitleColor(UIColor.white, for: .normal)
            button.addTarget(self, action: #selector(letterButtonTapped(_:)), for: .touchUpInside)
            
            letterButtonsContainer.addSubview(button)
            letterButtons.append(button)
        }
    }
    
    // UI'ı güncelleme
    private func updateUI() {
        // Kelimeyi göster
        wordLabel.text = gameModel.displayWord
        
        // Yanlış tahminleri göster
        let wrongGuessesText = gameModel.wrongLetters.map { String($0) }.joined(separator: ", ")
        wrongGuessesLabel.text = "\(LocalizationHelper.shared.getTranslation(for: "wrong_guesses")) \(wrongGuessesText)"
        
        // Kalan deneme sayısını göster
        remainingAttemptsLabel.text = LocalizationHelper.shared.getFormattedTranslation(
            for: "remaining_attempts",
            gameModel.remainingAttempts
        )
        
        // Asılan adam görselini güncelle
        let wrongAttemptsCount = gameModel.wrongLetters.count
        hangmanImageView.image = UIImage(named: "hangman\(wrongAttemptsCount)")
        
        // Skor etiketini güncelle
        updateScoreLabel()
        
        // Butonları güncelle
        updateLetterButtons()
        
        // Oyun durumunu kontrol et
        checkGameState()
    }
    
    // Harf butonlarını güncelleme
    private func updateLetterButtons() {
        for button in letterButtons {
            if let title = button.title(for: .normal), let firstChar = title.first {
                if gameModel.guessedLetters.contains(firstChar) {
                    button.isEnabled = false
                    button.backgroundColor = UIColor.systemGray
                } else {
                    button.isEnabled = true
                    button.backgroundColor = UIColor.systemBlue
                }
            }
        }
    }
    
    // Oyun durumunu kontrol et ve popup göster
    private func checkGameState() {
        if gameModel.isGameWon {
            disableAllLetterButtons()
            
            // Kazanma popup'ı göster
            let pointsEarned = gameModel.currentWord.count
            let alert = UIAlertController(
                title: LocalizationHelper.shared.getTranslation(for: "win_popup_title"),
                message: LocalizationHelper.shared.getFormattedTranslation(
                    for: "win_popup_message",
                    pointsEarned,
                    gameModel.currentScore
                ),
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(
                title: LocalizationHelper.shared.getTranslation(for: "next_word"),
                style: .default
            ) { [weak self] _ in
                self?.gameModel.nextWord { success in
                    if success {
                        self?.updateUI()
                    } else {
                        self?.showConnectionErrorAlert()
                    }
                }
            }
            
            alert.addAction(okAction)
            present(alert, animated: true)
            
        } else if gameModel.isGameLost {
            disableAllLetterButtons()
            
            // Kaybetme popup'ı göster
            let alert = UIAlertController(
                title: LocalizationHelper.shared.getTranslation(for: "lose_popup_title"),
                message: LocalizationHelper.shared.getFormattedTranslation(
                    for: "lose_popup_message",
                    gameModel.currentWord.uppercased(),
                    gameModel.currentScore
                ),
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(
                title: LocalizationHelper.shared.getTranslation(for: "next_word"),
                style: .default
            ) { [weak self] _ in
                self?.gameModel.nextWord { success in
                    if success {
                        self?.updateUI()
                    } else {
                        self?.showConnectionErrorAlert()
                    }
                }
            }
            
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
    
    // Bağlantı hatası popup'ını göster
    private func showConnectionErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to fetch a new word. Please check your connection and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizationHelper.shared.getTranslation(for: "ok_button"), style: .default))
        present(alert, animated: true)
    }
    
    // Tüm harf butonlarını devre dışı bırak
    private func disableAllLetterButtons() {
        letterButtons.forEach { button in
            button.isEnabled = false
            button.backgroundColor = UIColor.systemGray
        }
    }
    
    // Harf butonuna tıklandığında
    @objc private func letterButtonTapped(_ sender: UIButton) {
        guard let letter = sender.title(for: .normal)?.first else { return }
        
        // Harfi tahmin et
        let successful = gameModel.guessLetter(letter)
        
        if successful {
            // UI güncelle
            updateUI()
        }
    }
    
    // Geri dön butonuna tıklandığında
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // Oyunu sıfırlama butonuna tıklandığında
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        gameModel.resetGame { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.updateUI()
            } else {
                self.showConnectionErrorAlert()
            }
        }
    }
}
