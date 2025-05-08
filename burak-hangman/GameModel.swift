import Foundation

enum GameLanguage: String {
    case english = "en"
    case spanish = "es"
    case italian = "it"
    case german = "de"
    case french = "fr"
    case portugueseBR = "pt-br"
    
    var apiParam: String? {
        switch self {
        case .english:
            return nil
        default:
            return self.rawValue
        }
    }
    
    var flagImage: String {
        switch self {
        case .english: return "flag_uk"
        case .spanish: return "flag_spain"
        case .italian: return "flag_italy"
        case .german: return "flag_germany"
        case .french: return "flag_france"
        case .portugueseBR: return "flag_brazil"
        }
    }
    
    var alphabet: [Character] {
        switch self {
        case .english:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { $0 }
        case .spanish:
            return "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ".map { $0 }
        case .italian:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { $0 }
        case .german:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß".map { $0 }
        case .french:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÆÇÉÈÊËÎÏÔŒÙÛÜŸ".map { $0 }
        case .portugueseBR:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÂÃÇÉÊÍÓÔÕÚÜ".map { $0 }
        }
    }
}

class GameModel {
    private let apiBaseURL = "https://random-word-api.herokuapp.com/word"
    
    private(set) var currentWord: String = ""
    private(set) var guessedLetters: Set<Character> = []
    private(set) var wrongLetters: Set<Character> = []
    private(set) var currentLanguage: GameLanguage = .english
    private(set) var gameState: GameState = .notStarted
    
    // Skor sistemi için yeni değişkenler
    private(set) var currentScore: Int = 0
    
    var maxWrongAttempts = 6
    
    enum GameState {
        case notStarted
        case inProgress
        case won
        case lost
    }
    
    // Mevcut durumda kelimenin gösterilme şekli (doğru tahmin edilmeyen harfler için '_')
    var displayWord: String {
        return currentWord.uppercased().map { char in
            return guessedLetters.contains(Character(char.uppercased())) ? char.uppercased() : "_"
        }.joined(separator: " ")
    }
    
    // Kalan deneme sayısı
    var remainingAttempts: Int {
        return maxWrongAttempts - wrongLetters.count
    }
    
    // Kazanma durumu kontrolü
    var isGameWon: Bool {
        return currentWord.uppercased().allSatisfy { guessedLetters.contains(Character($0.uppercased())) }
    }
    
    // Kaybetme durumu kontrolü
    var isGameLost: Bool {
        return wrongLetters.count >= maxWrongAttempts
    }
    
    // Dil değiştirme
    func setLanguage(_ language: GameLanguage) {
        currentLanguage = language
    }
    
    // API'den yeni kelime çekme (URLSession kullanarak)
    func fetchNewWord(completion: @escaping (Bool) -> Void) {
        var urlString = apiBaseURL
        
        // Dil parametresi ekle
        if let langParam = currentLanguage.apiParam {
            urlString += "?lang=\(langParam)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                if let words = try JSONSerialization.jsonObject(with: data) as? [String],
                   let word = words.first {
                    DispatchQueue.main.async {
                        self.startNewGame(with: word)
                        completion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    // Yeni oyun başlatma
    private func startNewGame(with word: String) {
        currentWord = word
        guessedLetters.removeAll()
        wrongLetters.removeAll()
        gameState = .inProgress
        print("\(word)")
    }
    
    // Harf tahmin etme
    func guessLetter(_ letter: Character) -> Bool {
        // Oyun bittiyse veya harf zaten tahmin edildiyse işlem yapma
        guard gameState == .inProgress, !guessedLetters.contains(letter) else {
            return false
        }
        
        // Harfi tahmin edilenler listesine ekle
        guessedLetters.insert(letter)
        
        // Harf kelimede yoksa yanlış tahminlere ekle
        if !currentWord.uppercased().contains(letter.uppercased()) {
            wrongLetters.insert(letter)
        }
        
        // Oyun durumunu güncelle
        updateGameState()
        
        return true
    }
    
    // Oyun durumunu güncelle
    private func updateGameState() {
        if isGameWon {
            gameState = .won
            // Kazandığında kelime uzunluğu kadar puan ekle
            currentScore += currentWord.count
        } else if isGameLost {
            gameState = .lost
        }
    }
    
    // Oyunu sıfırlama (puanı koruyarak)
    func nextWord(completion: @escaping (Bool) -> Void) {
        fetchNewWord(completion: completion)
    }
    
    // Oyunu ve puanı tamamen sıfırlama
    func resetGame(completion: @escaping (Bool) -> Void) {
        currentScore = 0
        fetchNewWord(completion: completion)
    }
}
