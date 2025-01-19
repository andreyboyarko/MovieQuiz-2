
protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
    func setup(delegate: QuestionFactoryDelegate)
}


