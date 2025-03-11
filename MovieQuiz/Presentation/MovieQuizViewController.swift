
import Foundation


import UIKit

import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateImageView()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        setButtonsEnabled(true)
    }

    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            self?.showLoadingIndicator()
            self?.presenter.restartGame()
        }
        alertPresenter?.showAlert(model: alertModel)
    }

    private func configureUI() {
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }

    private func updateImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        setButtonsEnabled(false)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        setButtonsEnabled(false)
    }
}
//
//import UIKit
//import Foundation
//
//final class MovieQuizViewController: UIViewController {
//
//    //MARK: - Properties
//    // переменная с индексом текущего вопроса, начальное значение 0
////    private var currentQuestionIndex = 0
////    private let questionsAmount: Int = 10
////    private var questionFactory: QuestionFactoryProtocol?
////    private var questionFactory: QuestionFactory = QuestionFactory()
//    private var currentQuestion: QuizQuestion?
//    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
////    private var correctAnswers = 0
//    private var alertPresenter: AlertPresenter?
//    private var statisticService: StatisticServiceProtocol!
//
//    private let presenter: MovieQuizPresenter!
//
//    // MARK:
////    func didReceiveNextQuestion(question: QuizQuestion?) {
////        print("didReceiveNextQuestion вызван")
////        guard let question = question else {
////            print("Ошибка: получили пустой вопрос")
////            return
////        }
////        print("Получен вопрос: \(question.text), изображение: \(question.image.count) байт")
//////        currentQuestion = question
////        presenter.didReceiveNextQuestion(question: question)
////        let viewModel = presenter.convert(model: question)
//////        let viewModel = convert(model: question)
////
////        DispatchQueue.main.async { [weak self] in
////            self?.show(quiz: viewModel)
////        }
////    }
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        updateImageView()
//        statisticService = StatisticService()
////        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
////        presenter.questionFactory = questionFactory
//        alertPresenter = AlertPresenter(viewController: self)
//        presenter = MovieQuizPresenter(viewController: self)
//        print("Загружаю данные...")
////        showLoadingIndicator() // Показываем индикатор загрузки перед загрузкой данных
////        questionFactory?.loadData() // Начинаем загрузку данных
//        imageView.layer.cornerRadius = 20
////        presenter.viewController = self
//    }
//
//    // MARK: - Private Functions
//    // Обработка результата ответа
//    func showAnswerResult(isCorrect: Bool) {
//        presenter.didAnswer(isCorrectAnswer: isCorrect)
////        if isCorrect {
////
////            correctAnswers += 1
////        }
//
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 8
//        imageView.layer.cornerRadius = 20
//        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//                    guard let self = self else { return }
////                    self.presenter.correctAnswers = self.correctAnswers
//                    self.presenter.questionFactory = self.questionFactory
//                    self.presenter.showNextQuestionOrResults()
//                }
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
////            self?.showNextQuestionOrResults()
////            guard let self = self else { return }
////            self.imageView.layer.borderWidth = 0
////            self.imageView.layer.borderColor = nil
////            self.changeStateButton(isEnabled: true) // Разблокируем кнопки
////        }
//    }
//
//    private func showFirstQuestion() {
//        _ = questionFactory?.requestNextQuestion()
//    }
//
//     func show(quiz step: QuizStepViewModel) {
//        print("Отображаем вопрос: \(step.question), изображение: \(step.image)")
//        imageView.image = step.image
//        textLabel.text = step.question
//        counterLabel.text = step.questionNumber
//        }
//
//    private func showNextQuestionOrResults() {
//            imageView.layer.borderWidth = 0
//            imageView.layer.borderColor = UIColor.clear.cgColor
////            if currentQuestionIndex == presenter.questionsAmount - 1 {
//            if presenter.isLastQuestion() {
//                // Сох. статистики в StatisticService
//                statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
////                statisticService.store(correct: correctAnswers, total: questionsAmount)
//
//                let massage = """
//                    Ваш результат \(presenter.correctAnswers)/\(presenter.questionsAmount)
//                    Количество сыгранных квизов: \(statisticService.gamesCount)
//                    Рекорд: \(presenter.correctAnswers)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
//                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
//                    """
//
//                let alertModel = AlertModel(
//                    title: "Этот раунд окончен!",
//                    message: massage,
//                    buttonText: "Сыграть ещё раз",
//                    completion: { [weak self] in
//                            self?.presenter.restartGame()
//                        }
//                )
//                alertPresenter?.showAlert(model: alertModel)
//            } else {
//                presenter.switchToNextQuestion()
//                self.presenter.restartGame()
////                _ = questionFactory?.requestNextQuestion()
//                setButtonsEnabled(true)
//                }
//        }
//
////    private func restartGame() {
////        self.presenter.resetQuestionIndex()
////        presenter.correctAnswers = 0
////        showFirstQuestion()
////    }
//
//    private func setButtonsEnabled(_ isEnabled: Bool) {
//        noButton.isEnabled = isEnabled
//        yesButton.isEnabled = isEnabled
//    }
//
//    func showResults(quiz result: QuizResultsViewModel) {
//            let alert = UIAlertController(
//                title: result.title,
//                message: result.text,
//                preferredStyle: .alert
//            )
//
//            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
//                guard let self = self else { return }
//                self.presenter.resetQuestionIndex()
//                self.presenter.restartGame()
//                self.showFirstQuestion()
//            }
//            alert.addAction(action)
//            present(alert, animated: true, completion: nil)
//        }
//
//    private func updateImageView() {
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 20
//        imageView.clipsToBounds = true
//    }
//
//    private func configureUI() {
//        // Настройка кнопок
//        yesButton.layer.cornerRadius = 15
//        yesButton.clipsToBounds = true
//        noButton.layer.cornerRadius = 15
//        noButton.clipsToBounds = true
//        // Настройка imageView
//        imageView.layer.cornerRadius = 20
//        imageView.clipsToBounds = true
//        imageView.contentMode = .scaleAspectFill
//    }
//
//    private func changeStateButton(isEnabled: Bool) {
//        noButton.isEnabled = isEnabled
//        yesButton.isEnabled = isEnabled
//    }
//
//    func showLoadingIndicator() {
//        DispatchQueue.main.async {
//            self.activityIndicator.isHidden = false
//            self.activityIndicator.startAnimating()
//        }
//    }
//    func showNetworkError(message: String) {
//        hideLoadingIndicator()
//
//        let alertModel = AlertModel(
//            title: "Ошибка",
//            message: message,
//            buttonText: "Попробовать еще раз"
//        ) { [weak self] in
//            self?.showLoadingIndicator()
//            self?.presenter.restartGame() // Здесь уже вызывается requestNextQuestion
//        }
//
//        alertPresenter?.showAlert(model: alertModel)
//    }
////    private func showNetworkError(message: String) {
////        hideLoadingIndicator()
////
////        let action = UIAlertAction(title: "Попробовать ещё раз",
////                                    style: .default) { [weak self] _ in
////        let model = AlertModel(title: "Ошибка",
////                               message: message,
////                               buttonText: "Попробовать еще раз") { [weak self] in
////            guard let self = self else { return }
////            self?.presenter.restartGame()
//////            self.presenter.resetQuestionIndex()
//////            self.questionFactory?.requestNextQuestion()
////        }
////
////        //alertPresenter.showAlert(in: self, model: model)
////        if let alertPresenter = alertPresenter {
////            alertPresenter?.showAlert(model: alertModel)
////        }
//
//
//
////    func didLoadDataFromServer() {
////        print("Данные успешно загружены.")
////        activityIndicator.isHidden = true // скрываем индикатор загрузки
////        questionFactory?.requestNextQuestion()
////    }
//
////    func didFailToLoadData(with error: Error) {
////        print("Ошибка загрузки данных: \(error.localizedDescription)")
////        hideLoadingIndicator()
////
////        let alertModel = AlertModel(
////            title: "Ошибка",
////            message: error.localizedDescription,
////            buttonText: "Попробовать снова"
////        ) { [weak self] in
////            print("Повторная попытка загрузки данных")
////            self?.showLoadingIndicator()
////            self?.questionFactory?.loadData()
////        }
////
////        alertPresenter?.showAlert(model: alertModel)
////    }
//
//    func hideLoadingIndicator() {
//        DispatchQueue.main.async {
//            self.activityIndicator.isHidden = true
//            self.activityIndicator.stopAnimating()
//        }
//    }
//
//    //MARK: - IBOutlets
//    @IBOutlet private weak var imageView: UIImageView!
//    @IBOutlet private weak var noButton: UIButton!
//    @IBOutlet private weak var yesButton: UIButton!
//    @IBOutlet private weak var textLabel: UILabel!
//    @IBOutlet private weak var counterLabel: UILabel!
//    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
//
//    @IBAction private func noButtonClicked(_ sender: UIButton) {
//        presenter.yesButtonClicked()
////        presenter.currentQuestion = currentQuestion
////        presenter.noButtonClicked()
//        changeStateButton(isEnabled: false) // Блокируем кнопки
////        guard let currentQuestion = currentQuestion else {
////            return
////        }
////        let givenAnswer = false
////        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
//    @IBAction private func yesButtonClicked(_ sender: UIButton) {
//        presenter.yesButtonClicked()
////        presenter.currentQuestion = currentQuestion
////        presenter.yesButtonClicked()
//        changeStateButton(isEnabled: false) // Блокируем кнопки
////        guard let currentQuestion = currentQuestion else {
////            return
////        }
////        let givenAnswer = true
////        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//    }
//}
//
//
