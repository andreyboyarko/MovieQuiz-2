import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private(set) var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            print("Ошибка: следующий вопрос не получен")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func showNextQuestionOrResults() {
        if isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showResults(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}

//import UIKit
//
//final class MovieQuizPresenter: QuestionFactoryDelegate {
//    let questionsAmount: Int = 10
//    private var currentQuestionIndex: Int = 0
//    private var questionFactory: QuestionFactoryProtocol?
//    private(set) var correctAnswers = 0
//    private var currentQuestion: QuizQuestion?
//    private weak var viewController: MovieQuizViewController?
//
//    init(viewController: MovieQuizViewController) {
//        self.viewController = viewController
//        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
//        questionFactory?.loadData()
//        viewController.showLoadingIndicator()
//    }
//
//    // MARK: - QuestionFactoryDelegate
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        guard let question = question else {
//            print("Ошибка: следующий вопрос не получен")
//            return
//        }
//        currentQuestion = question
//        let viewModel = convert(model: question)
//        DispatchQueue.main.async { [weak self] in
//            self?.viewController?.show(quiz: viewModel)
//        }
//    }
//
//    func didLoadDataFromServer() {
//        viewController?.hideLoadingIndicator()
//        questionFactory?.requestNextQuestion()
//    }
//
//    func didFailToLoadData(with error: Error) {
//        let message = error.localizedDescription
//        viewController?.showNetworkError(message: message)
//    }
//
//    // MARK: - Public Methods
//    func isLastQuestion() -> Bool {
//        currentQuestionIndex == questionsAmount - 1
//    }
//
//    func resetQuestionIndex() {
//        currentQuestionIndex = 0
//    }
//
//    func switchToNextQuestion() {
//        currentQuestionIndex += 1
//    }
//
//    func restartGame() {
//        resetQuestionIndex()
//        correctAnswers = 0
//        questionFactory?.requestNextQuestion()
//    }
//
//    func didAnswer(isCorrectAnswer: Bool) {
//        if isCorrectAnswer {
//            correctAnswers += 1
//        }
//    }
//
//    func convert(model: QuizQuestion) -> QuizStepViewModel {
//        print("Преобразование вопроса: \(model.text), изображение: \(model.image.count) байт")
//        if model.image.isEmpty {
//            print("Ошибка: пустые данные изображения")
//        } else {
//            print("Размер данных изображения: \(model.image.count) байт")
//        }
//        return QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
//        )
//    }
//
//    func yesButtonClicked() {
//        didAnswer(isYes: true)
//    }
//
//    func noButtonClicked() {
//        didAnswer(isYes: false)
//    }
//
//    private func didAnswer(isYes: Bool) {
//        guard let currentQuestion = currentQuestion else { return }
//        let givenAnswer = isYes
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
//
//    func showNextQuestionOrResults() {
//        if isLastQuestion() {
//            let text = "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!"
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: text,
//                buttonText: "Сыграть ещё раз"
//            )
//            viewController?.showResults(quiz: viewModel)
//        } else {
//            switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//        }
//    }
//}
