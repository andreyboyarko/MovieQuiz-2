import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        print("Преобразование вопроса: \(model.text), изображение: \(model.image.count) байт")
        
        if model.image.isEmpty {
            print("Ошибка: пустые данные изображения")
        } else {
            print("Размер данных изображения: \(model.image.count) байт")
        }
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(), // Преобразуем картинку
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = true
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    func noButtonClicked() {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = false
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    
//    @IBAction func yesButtonClicked(_ sender: UIButton) {
////        changeStateButton(isEnabled: false)// Блокируем кнопки
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givenAnswer = true
//
//        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }

}
