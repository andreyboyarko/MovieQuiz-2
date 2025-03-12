

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists, "First poster not found")
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        let expectation = XCTestExpectation(description: "Wait for new poster")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists, "Second poster not found")
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.exists, "Index label not found")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.exists, "First poster not found")
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.exists, "Index label not found")
        let firstIndex = indexLabel.label
        XCTAssertEqual(firstIndex, "1/10", "Unexpected initial index value")

        app.buttons["No"].tap()

        // Ожидание изменения индекса
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label != %@", firstIndex),
            object: indexLabel
        )
        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Index did not update")

        let secondPoster = app.images["Poster"]
        XCTAssertTrue(secondPoster.exists, "Second poster not found")
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData, "Poster did not change after tapping No")
        XCTAssertEqual(indexLabel.label, "2/10", "Index did not increment correctly")
    }

    
    func testGameFinish() {
        sleep(2) // Ждём, чтобы приложение успело запуститься

        // Нажимаем на кнопку "No" 10 раз
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2) // Ждём обновления UI
        }

        // Ищем алерт по заголовку
        let alert = app.alerts["Этот раунд окончен!"]
        
        // Проверяем, что алерт появился
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert not found")
        
        // Проверяем заголовок и кнопку
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    
    func testAlertDismiss() {
        sleep(2) // Ждём, чтобы приложение успело запуститься

        // Нажимаем на кнопку "No" 10 раз
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2) // Ждём обновления UI
        }

        // Ищем алерт по заголовку
        let alert = app.alerts["Этот раунд окончен!"]
        
        // Проверяем, что алерт появился
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert not found")
        
        // Нажимаем на кнопку "Сыграть ещё раз"
        alert.buttons.firstMatch.tap()
        
        // Проверяем, что алерт исчез
        XCTAssertFalse(alert.exists, "Alert should be dismissed")
        
        // Проверяем, что индекс обновился (он должен быть "1/10")
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label not found")
//        XCTAssertTrue(indexLabel.exists, "Index label not found")
        XCTAssertEqual(indexLabel.label, "1/10")
    }

    
}
