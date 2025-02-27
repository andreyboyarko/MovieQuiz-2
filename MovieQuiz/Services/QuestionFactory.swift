import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // Загружаем данные
    func loadData() {
        print("QuestionFactory: Начинаем загрузку данных...")
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    print("QuestionFactory: Данные о фильмах загружены. Количество фильмов: \(mostPopularMovies.items.count)")
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    print("QuestionFactory: Ошибка загрузки данных - \(error.localizedDescription)")
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    // Запрос следующего вопроса
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Смотрим, что индекс находится в пределах массива
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            // Применяем безопасный доступ к элементу
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()

            // Загружаем изображение с URL
            do {
                let url = movie.resizedImageURL // Просто используем URL напрямую
                imageData = try Data(contentsOf: url)
            } catch {
                print("Failed to load image: \(error)")
            }
            
            let rating = movie.rating ?? 0.0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    // Настройка делегата
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}


//class QuestionFactory: QuestionFactoryProtocol {
//    private let moviesLoader: MoviesLoading
//    private weak var delegate: QuestionFactoryDelegate?
//    private var movies: [MostPopularMovie] = []
//
//    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
//        self.moviesLoader = moviesLoader
//        self.delegate = delegate
//    }
//
//    func loadData() {
//        moviesLoader.loadMovies { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let mostPopularMovies):
//                    self.movies = mostPopularMovies.items
//                    self.delegate?.didLoadDataFromServer()
//                case .failure(let error):
//                    self.delegate?.didFailToLoadData(with: error)
//                }
//            }
//        }
//    }
//
//    func requestNextQuestion() {
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            let index = (0..<self.movies.count).randomElement() ?? 0
//
//            guard let movie = self.movies[safe: index] else { return }
//
//            var imageData = Data()
//
//            do {
//                imageData = try Data(contentsOf: movie.resizedImageURL)
//            } catch {
//                print("Failed to load image")
//            }
//
//            let rating = Float(movie.rating) ?? 0
//
//            let text = "Рейтинг этого фильма больше чем 7?"
//            let correctAnswer = rating > 7
//
//            let question = QuizQuestion(image: imageData,
//                                         text: text,
//                                         correctAnswer: correctAnswer)
//
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.delegate?.didReceiveNextQuestion(question: question)
//            }
//        }
//    }
//    func setup(delegate: QuestionFactoryDelegate) {
//            self.delegate = delegate
//        }
//}

//final class QuestionFactory: QuestionFactoryProtocol {
//    weak var delegate: QuestionFactoryDelegate?
//
//    private var questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
//
//    private var currentQuestionIndex = 0
//
//    init() {
//        questions.shuffle() // Перемешиваем массив при создании фабрики
//    }
//
//    func setup(delegate: QuestionFactoryDelegate) {
//        self.delegate = delegate
//    }
//
//    func requestNextQuestion() -> QuizQuestion? {
//        guard !questions.isEmpty else { return nil } // Проверяем, что массив не пуст
//        let question = questions[currentQuestionIndex]
//        currentQuestionIndex = (currentQuestionIndex + 1) % questions.count // Индекс следующего вопроса
//        delegate?.didReceiveNextQuestion(question: question) // Сообщаем делегату
//        return question
//    }
//}

