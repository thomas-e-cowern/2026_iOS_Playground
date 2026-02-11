//
//  MockJokeOO.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import Foundation

class MockJokeOO: JokeOO {
    
    override func fetchOneJoke() async {
        singleJoke = Joke(error: false, category: "Christmas", type: "twopart", joke: nil, setup: "Why couldn't the skeleton go to the Christmas party?", delivery: "Because he had no body to go with!", flags: Flags(nsfw: false, religious: false, political: false, racist: false, sexist: false, explicit: false), safe: true, id: 251, lang: "en")
    }
}
