import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case gamesCount
        
        enum BestGame: String {
            case correct
            case total
            case date
            
            var fullKey: String {
                return "bestGame.\(self.rawValue)"
            }
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100.0
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.BestGame.correct.fullKey)
            let total = storage.integer(forKey: Keys.BestGame.total.fullKey)
            let date = storage.object(forKey: Keys.BestGame.date.fullKey) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.BestGame.correct.fullKey)
            storage.set(newValue.total, forKey: Keys.BestGame.total.fullKey)
            storage.set(newValue.date, forKey: Keys.BestGame.date.fullKey)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentCorrectAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        storage.set(currentCorrectAnswers + count, forKey: Keys.correctAnswers.rawValue)
        
        let currentTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentTotalQuestions + amount, forKey: Keys.totalQuestions.rawValue)
        
        gamesCount += 1
        
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}

extension StatisticService: StatisticServiceProtocol { }

