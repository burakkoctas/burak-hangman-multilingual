import Foundation

class LocalizationHelper {
    
    static let shared = LocalizationHelper()
    
    // Tüm çeviriler burada tutulacak
    private var translations: [GameLanguage: [String: String]] = [
        .english: [
            "title": "ENGLISH",
            "play": "PLAY",
            "back": "Back",
            "reset": "Reset Game",
            "win_message": "You Won!",
            "lose_message": "Game Over!",
            "wrong_guesses": "Wrong Guesses:",
            "remaining_letters": "Remaining Letters:",
            "remaining_attempts": "Attempts left: %d",
            "win_popup_title": "Congratulations!",
            "win_popup_message": "You guessed the word correctly!\nPoints earned: %d\nTotal score: %d",
            "lose_popup_title": "Game Over",
            "lose_popup_message": "The word was: %@\nYour score: %d",
            "ok_button": "OK",
            "next_word": "Next Word",
            "current_score": "Score: %d",
            "try_again" : "Try Again"
            
        ],
        .spanish: [
            "title": "ESPAÑOL",
            "play": "JUGAR",
            "back": "Volver",
            "reset": "Reiniciar",
            "win_message": "¡Has Ganado!",
            "lose_message": "¡Juego Terminado!",
            "wrong_guesses": "Errores:",
            "remaining_letters": "Letras restantes:",
            "remaining_attempts": "Intentos restantes: %d",
            "win_popup_title": "¡Felicidades!",
            "win_popup_message": "¡Adivinaste la palabra correctamente!\nPuntos ganados: %d\nPuntuación total: %d",
            "lose_popup_title": "Juego Terminado",
            "lose_popup_message": "La palabra era: %@\nTu puntuación: %d",
            "ok_button": "OK",
            "next_word": "Siguiente Palabra",
            "current_score": "Puntuación: %d",
            "try_again": "Intentar otra vez"
        ],
        .italian: [
            "title": "ITALIANO",
            "play": "GIOCA",
            "back": "Indietro",
            "reset": "Ricomincia",
            "win_message": "Hai Vinto!",
            "lose_message": "Partita Terminata!",
            "wrong_guesses": "Errori:",
            "remaining_letters": "Lettere rimanenti:",
            "remaining_attempts": "Tentativi rimasti: %d",
            "win_popup_title": "Congratulazioni!",
            "win_popup_message": "Hai indovinato correttamente la parola!\nPunti guadagnati: %d\nPunteggio totale: %d",
            "lose_popup_title": "Partita Terminata",
            "lose_popup_message": "La parola era: %@\nIl tuo punteggio: %d",
            "ok_button": "OK",
            "next_word": "Prossima Parola",
            "current_score": "Punteggio: %d",
            "try_again": "Riprova"
            
        ],
        .german: [
            "title": "DEUTSCH",
            "play": "SPIELEN",
            "back": "Zurück",
            "reset": "Neustart",
            "win_message": "Du hast gewonnen!",
            "lose_message": "Spiel vorbei!",
            "wrong_guesses": "Falsche Buchstaben:",
            "remaining_letters": "Verbleibende Buchstaben:",
            "remaining_attempts": "Verbleibende Versuche: %d",
            "win_popup_title": "Glückwunsch!",
            "win_popup_message": "Du hast das Wort richtig erraten!\nPunkte erhalten: %d\nGesamtpunktzahl: %d",
            "lose_popup_title": "Spiel vorbei",
            "lose_popup_message": "Das Wort war: %@\nDeine Punktzahl: %d",
            "ok_button": "OK",
            "next_word": "Nächstes Wort",
            "current_score": "Punktzahl: %d",
            "try_again":"Versuchen Sie es erneut"
        ],
        .french: [
            "title": "FRANÇAIS",
            "play": "JOUER",
            "back": "Retour",
            "reset": "Recommencer",
            "win_message": "Vous avez gagné!",
            "lose_message": "Partie terminée!",
            "wrong_guesses": "Erreurs:",
            "remaining_letters": "Lettres restantes:",
            "remaining_attempts": "Essais restants: %d",
            "win_popup_title": "Félicitations!",
            "win_popup_message": "Vous avez deviné le mot correctement!\nPoints gagnés: %d\nScore total: %d",
            "lose_popup_title": "Partie Terminée",
            "lose_popup_message": "Le mot était: %@\nVotre score: %d",
            "ok_button": "OK",
            "next_word": "Mot Suivant",
            "current_score": "Score: %d",
            "try_again": "Essayer à nouveau"
            
        ],
        .portugueseBR: [
            "title": "PORTUGUÊS",
            "play": "JOGAR",
            "back": "Voltar",
            "reset": "Reiniciar",
            "win_message": "Você Venceu!",
            "lose_message": "Fim de Jogo!",
            "wrong_guesses": "Erros:",
            "remaining_letters": "Letras restantes:",
            "remaining_attempts": "Tentativas restantes: %d",
            "win_popup_title": "Parabéns!",
            "win_popup_message": "Você adivinhou a palavra corretamente!\nPontos ganhos: %d\nPontuação total: %d",
            "lose_popup_title": "Fim de Jogo",
            "lose_popup_message": "A palavra era: %@\nSua pontuação: %d",
            "ok_button": "OK",
            "next_word": "Próxima Palavra",
            "current_score": "Pontuação: %d",
            "try_again": "Tente novamente"
        ]
    ]
    
    // Varsayılan dil
    private var currentLanguage: GameLanguage = .english
    
    private init() {}
    
    // Dil değiştirme
    func setLanguage(_ language: GameLanguage) {
        currentLanguage = language
    }
    
    // Çeviri getirme
    func getTranslation(for key: String) -> String {
        return translations[currentLanguage]?[key] ?? key
    }
    
    // Formatlı çeviri getirme (örn: kalan deneme sayısı)
    func getFormattedTranslation(for key: String, _ args: CVarArg...) -> String {
        let format = getTranslation(for: key)
        return String(format: format, arguments: args)
    }
}
