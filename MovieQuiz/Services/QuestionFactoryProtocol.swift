
protocol QuestionFactoryProtocol {
    func requestNextQuestion()  // Убрали возвращаемый QuizQuestion?
    func setup(delegate: QuestionFactoryDelegate)
    func loadData()
}


