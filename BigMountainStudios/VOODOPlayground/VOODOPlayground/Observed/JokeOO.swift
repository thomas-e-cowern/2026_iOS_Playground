//
//  JokeOO.swift
//  VOODOPlayground
//
//  Created by Thomas Cowern on 2/11/26.
//

import Foundation
import Observation

@Observable
class JokeOO {
    var singleJoke: Joke?
    
    init(singleJoke: Joke? = nil) {
        self.singleJoke = singleJoke
    }
    
    func fetchOneJoke() async {
        
        
#if DEBUG
        
        singleJoke = Joke(error: false, category: "Christmas", type: "twopart", joke: nil, setup: "Why couldn't the skeleton go to the Christmas party?", delivery: "Because he had no body to go with!", flags: Flags(nsfw: false, religious: false, political: false, racist: false, sexist: false, explicit: false), safe: true, id: 251, lang: "en")
        
#else
        
        guard let url = URL(string: "https://v2.jokeapi.dev/joke/Any") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(Joke.self, from: data)
            
            singleJoke = decodedResponse
        } catch {
            print("There were errors decoding the joke: \(error.localizedDescription)")
        }
        
#endif
    }
}

