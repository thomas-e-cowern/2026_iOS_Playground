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
    
    func fetchJoke() async {
        guard let url = URL(string: "https://v2.jokeapi.dev/joke/Any") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            print("Response from API was \(response)")
            
            let decodedResponse = try JSONDecoder().decode(Joke.self, from: data)
            
            print("Decoded Response: \(decodedResponse)")
            
            singleJoke = decodedResponse
        } catch {
            print("There were errors decoding the joke: \(error.localizedDescription)")
        }
    }
}

