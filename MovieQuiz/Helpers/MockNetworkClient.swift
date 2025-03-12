

import Foundation

// Создаем мок-класс для сетевого клиента
class MockNetworkClient: NetworkRouting {
    
    enum TestError: Error {
        case test
    }

    private let emulateError: Bool
    private let responseData: Data?

    init(emulateError: Bool, responseData: Data? = nil) {
        self.emulateError = emulateError
        self.responseData = responseData
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test)) // Эмулируем ошибку
        } else if let responseData = responseData {
            handler(.success(responseData)) // Эмулируем успешный ответ с данными
        } else {
            handler(.failure(TestError.test)) // Эмулируем ошибку, если данных нет
        }
    }
}
