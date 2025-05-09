import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // Bayrak imageView'ları için outlet koleksiyonu
    @IBOutlet var flagImageViews: [UIImageView]!
    
    // Oyun modeli
    private let gameModel = GameModel()
    
    // Seçili olan dil (varsayılan olarak İngilizce)
    private var selectedLanguage: GameLanguage = .english
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlagImageViews()
        
        // Başlangıç dili İngilizce olarak ayarla
        updateSelectedLanguage(.english)
    }
    
    // ImageView'ların ayarlanması
    private func setupFlagImageViews() {
        for (index, imageView) in flagImageViews.enumerated() {
            // Her bir imageView'a tag ata (eski button.tag değerlerine göre)
            imageView.tag = index + 1
            
            // Bayrak görselini ekle
            let imageName = "flag\(imageView.tag)"
            imageView.image = UIImage(named: imageName)
            
            // Bayrakların dokunulabilir olması için
            imageView.isUserInteractionEnabled = true
            
            // Dokunma tanıyıcısı ekle
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flagTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            // Düzgün bir boyut ayarla
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    // Bayrak imageView'ına tıklandığında (UITapGestureRecognizer için selector)
    @objc private func flagTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedImageView = gesture.view as? UIImageView else { return }
        
        // Hangi dil seçildi?
        switch tappedImageView.tag {
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
        selectedLanguage = language
        
        // UI'ı güncelle
        titleLabel.text = LocalizationHelper.shared.getTranslation(for: "title")
        playButton.setTitle(LocalizationHelper.shared.getTranslation(for: "play"), for: .normal)
        
        // Seçilen bayrak için görsel vurgusu
        for imageView in flagImageViews {
            imageView.alpha = (imageView.tag == getFlagTag(for: language)) ? 1.0 : 0.5
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
