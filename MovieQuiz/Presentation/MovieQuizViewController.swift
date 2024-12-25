import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        lockButtons()
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        lockButtons()
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showFirstQuestion()
        configureUI()
    }
    
    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
    ]
    
    private struct QuizQuestion {
        // строка с названием фильма
        // совпадает с названием картинки афиши фильма в Assets
        let image: String
        // строка с вопросом о рейтинге фильма
        let text: String
        // булевое значение (true, false), правильный ответ на вопрос
        let correctAnswer: Bool
    }

    // вью модель для состояния "Вопрос показан"
    private struct QuizStepViewModel {
      // картинка с афишей фильма с типом UIImage
      let image: UIImage
      // вопрос о рейтинге квиза
      let question: String
      // строка с порядковым номером этого вопроса (ex. "1/10")
      let questionNumber: String
    }

    // для состояния "Результат квиза"
    private struct QuizResultsViewModel {
      // строка с заголовком алерта
      let title: String
      // строка с текстом о количестве набранных очков
      let text: String
      // текст для кнопки алерта
      let buttonText: String
    }
    
    private func configureUI() {
        // Настройка кнопок
           yesButton.layer.cornerRadius = 15
           yesButton.clipsToBounds = true
           noButton.layer.cornerRadius = 15
           noButton.clipsToBounds = true
           // Настройка imageView
           imageView.layer.cornerRadius = 20
           imageView.clipsToBounds = true
           imageView.contentMode = .scaleAspectFill
    }
    
    // Метод блокировки кнопок
    private func lockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    // Метод разблокировки кнопок
    private func unlockButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    // Обработка результата ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.showNextQuestionOrResults()
            self.unlockButtons() // Разблокируем кнопки после завершения анимации
        }
    }
    
    private func showFirstQuestion() {
        // Получаем первый вопрос
        let firstQuestion = questions[currentQuestionIndex]
        // Конвертируем его в вью-модель
        let viewModel = convert(model: firstQuestion)
        // Показываем его на экране
        showQuestion(quiz: viewModel)
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questinStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questinStep
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showFirstQuestion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            updateImageView()
            let viewModel = convert(model: nextQuestion)
            showQuestion(quiz: viewModel)
        }
    }
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func updateImageView() {
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 20
    imageView.clipsToBounds = true
    }
}





/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
