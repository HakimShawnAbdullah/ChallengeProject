//
//  MovieTests.swift
//  VaroChallengeTests
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import XCTest

class MoviePlayingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testMovieDecoding() {
        guard let jsonFilePath = Bundle.init(for: type(of: self)).url(forResource: "MovieMock", withExtension: "JSON") else {
            XCTFail()
            return
        }
        guard let data = try? Data(contentsOf: jsonFilePath) else {
            XCTFail()
            return
        }
        let movies = try? JSONDecoder().decode(MoviesPlaying.self, from: data).results
        
        XCTAssertNotNil(movies)
    }
    
}
