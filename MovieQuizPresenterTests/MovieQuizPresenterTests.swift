import XCTest
@testable import MovieQuiz

// Мок-объект для MovieQuizViewControllerProtocol, который будет использоваться в тестах
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func resetImageBorder() {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

// Тесты для MovieQuizPresenter
final class MovieQuizPresenterTests: XCTestCase {

    // Тестируем метод presenter.convert(model:) для преобразования модели
    func testPresenterConvertModel() throws {
        // Given: Подготовка mock-объекта и данных
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        // Пустые данные для изображения
        let emptyData = Data()
        // Создание объекта вопроса
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)

        // When: Вызов метода преобразования модели в ViewModel
        let viewModel = sut.convert(model: question)
        
        // Then: Проверки на правильность преобразования
        XCTAssertNotNil(viewModel.image, "Image should not be nil") // Проверяем, что изображение не nil
        XCTAssertEqual(viewModel.question, "Question Text", "Question text should match") // Проверяем, что текст вопроса правильный
        XCTAssertEqual(viewModel.questionNumber, "1/10", "Question number should match") // Проверяем, что номер вопроса правильный
    }
}
