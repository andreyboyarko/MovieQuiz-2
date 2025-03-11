

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
        
        app.buttons["No"].tap()
        
        let expectation = XCTestExpectation(description: "Wait for new question")
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
    
    func testGameFinish() {
        let expectation = XCTestExpectation(description: "Wait for 10 questions")
        var tapCount = 0
        
        func tapNextButton() {
            DispatchQueue.main.async {
                self.app.buttons["No"].tap()
                tapCount += 1
                
                if tapCount < 10 {
                    // Задержка перед следующим нажатием
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        tapNextButton()
                    }
                } else {
                    // После 10 нажатий ждём 2 секунды и завершаем ожидание
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        expectation.fulfill()
                    }
                }
            }
        }
        
        // Начинаем последовательность нажатий
        tapNextButton()
        wait(for: [expectation], timeout: 15.0)
        
        let alert = app.alerts["Game results"]
        XCTAssertTrue(alert.exists, "Alert not found")
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        let expectation = XCTestExpectation(description: "Wait for 10 questions")
        var tapCount = 0
        
        XCUIApplication()/*@START_MENU_TOKEN@*/.buttons["No"]/*[[".buttons[\"Нет\"]",".buttons[\"No\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        func tapNextButton() {
            DispatchQueue.main.async {
                self.app.buttons["No"].tap()
                tapCount += 1
                
                if tapCount < 10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        tapNextButton()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        expectation.fulfill()
                    }
                }
            }
        }
        
        tapNextButton()
        wait(for: [expectation], timeout: 15.0)
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        let restartExpectation = XCTestExpectation(description: "Wait for game restart")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            restartExpectation.fulfill()
        }
        wait(for: [restartExpectation], timeout: 5.0)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists, "Alert should not exist")
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
}
