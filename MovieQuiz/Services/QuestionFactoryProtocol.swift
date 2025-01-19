//import Foundation
//
//protocol QuestionFactoryProtocol {
//    func requestNextQuestion()
//}
protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
    func setup(delegate: QuestionFactoryDelegate)
}


