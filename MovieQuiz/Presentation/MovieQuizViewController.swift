import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Properties
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
//    private var questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol!
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        print("didReceiveNextQuestion вызван")
        guard let question = question else {
            print("Ошибка: получили пустой вопрос")
            return
        }
        print("Получен вопрос: \(question.text), изображение: \(question.image.count) байт")
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateImageView()
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        print("Загружаю данные...")
        showLoadingIndicator() // Показываем индикатор загрузки перед загрузкой данных
        questionFactory?.loadData() // Начинаем загрузку данных
        imageView.layer.cornerRadius = 20
    }

    // MARK: - Private Functions
    // Обработка результата ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.changeStateButton(isEnabled: true) // Разблокируем кнопки
        }
    }
    
    private func showFirstQuestion() {
        _ = questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
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

    private func show(quiz step: QuizStepViewModel) {
        print("Отображаем вопрос: \(step.question), изображение: \(step.image)")
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        }
        
        private func showNextQuestionOrResults() {
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
            if currentQuestionIndex == questionsAmount - 1 {
                // Сох. статистики в StatisticService
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                let massage = """
                    Ваш результат \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(correctAnswers)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
                
                let alertModel = AlertModel(
                    title: "Этот раунд окончен!",
                    message: massage,
                    buttonText: "Сыграть ещё раз",
                    completion: { [weak self] in
                            self?.restartGame()
                        }
                )
                alertPresenter?.showAlert(model: alertModel)
            } else {
                currentQuestionIndex += 1
                _ = questionFactory?.requestNextQuestion()
                setButtonsEnabled(true)
                }
        }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showFirstQuestion()
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
        
    private func showResults(quiz result: QuizResultsViewModel) {
            let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.showFirstQuestion()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
  
    private func updateImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
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
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        //alertPresenter.showAlert(in: self, model: model)
        if let alertPresenter = alertPresenter {
            alertPresenter.showAlert(model: model)
        }

    }
    
    func didLoadDataFromServer() {
        print("Данные успешно загружены.")
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        print("Ошибка загрузки данных: \(error.localizedDescription)")
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: error.localizedDescription,
            buttonText: "Попробовать снова"
        ) { [weak self] in
            print("Повторная попытка загрузки данных")
            self?.showLoadingIndicator()
            self?.questionFactory?.loadData()
        }

        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        changeStateButton(isEnabled: false) // Блокируем кнопки
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        changeStateButton(isEnabled: false) // Блокируем кнопки
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}


