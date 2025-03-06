import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Ошибка: Невозможно создать URL для популярных фильмов")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        print(" loadMovies: Запрос к API на загрузку популярных фильмов по URL: \(mostPopularMoviesUrl)")
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                print("Данные получены от сервера. Размер данных: \(data.count) байт.")
//                print("Полученные данные JSON -> \(String(data: data, encoding: .utf8) ?? "Не удалось преобразовать в строку")")
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // На случай, если JSON содержит snake_case
                    let mostPopularMovies = try decoder.decode(MostPopularMovies.self, from: data)
                    print("Декодирование данных прошло успешно.")
                    handler(.success(mostPopularMovies))
                } catch let decodingError {
                    print("Ошибка декодирования JSON: \(decodingError)")
                    handler(.failure(decodingError))
                }
            case .failure(let error):
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                handler(.failure(error))
            }
        }
    }
}
