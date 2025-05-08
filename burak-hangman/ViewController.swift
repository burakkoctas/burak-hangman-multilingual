import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // Flag butonları için outlet koleksiyonu
    @IBOutlet var flagButtons: [UIButton]!
    
    // Oyun modeli
    private let gameModel = GameModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in flagButtons {
            let imageName = "flag\(button.tag)"
            let image = UIImage(named: imageName)

            var config = UIButton.Configuration.plain()
            config.image = image
            config.imagePadding = 0 // Görsel ve metin arası boşluk (eğer metin varsa)
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            // Görselin boyutunu küçültmek için preferredSymbolConfiguration kullan (örnek 40x30)
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30)

            button.configuration = config
        }

        
        // Başlangıç dili İngilizce olarak ayarla
        updateSelectedLanguage(.english)
    }
    
    // Bayrak butonuna tıklandığında
    @IBAction func flagButtonTapped(_ sender: UIButton) {
        // Hangi dil seçildi?
        var selectedLanguage: GameLanguage = .english
        
        switch sender.tag {
        case 1:
            selectedLanguage = .english
        case 2:
            selectedLanguage = .spanish
        case 3:
            selectedLanguage = .italian
        case 4:
            selectedLanguage = .german
        case 5:
            selectedLanguage = .french
        case 6:
            selectedLanguage = .portugueseBR
        default:
            selectedLanguage = .english
        }
        
        updateSelectedLanguage(selectedLanguage)
    }
    
    // Seçilen dile göre UI güncellemesi
    private func updateSelectedLanguage(_ language: GameLanguage) {
        // Dili lokalizasyon ve oyun modelinde ayarla
        LocalizationHelper.shared.setLanguage(language)
        gameModel.setLanguage(language)
        
        // UI'ı güncelle
        titleLabel.text = LocalizationHelper.shared.getTranslation(for: "title")
        playButton.setTitle(LocalizationHelper.shared.getTranslation(for: "play"), for: .normal)
        
        // Seçilen bayrak için görsel vurgusu (opsiyonel)
        for button in flagButtons {
            button.alpha = (button.tag == getFlagTag(for: language)) ? 1.0 : 0.5
        }
    }
    
    // Dil enum'ından bayrak tag'ine dönüşüm
    private func getFlagTag(for language: GameLanguage) -> Int {
        switch language {
        case .english: return 1
        case .spanish: return 2
        case .italian: return 3
        case .german: return 4
        case .french: return 5
        case .portugueseBR: return 6
        }
    }
    
    // Oyunu başlatma ve diğer sayfaya geçiş
    @IBAction func playButtonTapped(_ sender: UIButton) {
        // Oyun sayfasına geçmeden önce kelime çek
        gameModel.fetchNewWord { [weak self] success in
            guard let self = self else { return } // Safely unwrap self

            if !success {
                // Hata durumunda kullanıcıya bilgi ver
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to fetch a word. Please check your connection and try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }

            // Başarılı olduğunda oyun sayfasına geç
            self.performSegue(withIdentifier: "showGameScreen", sender: self)
        }
    }
    
    // Segue hazırlığı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGameScreen" {
            if let gameVC = segue.destination as? GameViewController {
                // Oyun modelini diğer sayfaya aktar
                gameVC.gameModel = gameModel
            }
        }
    }
}
