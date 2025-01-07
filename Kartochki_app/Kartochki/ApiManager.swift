//
//  ApiManager.swift
//  Kartochki
//
//  Created by Darian Lee on 7/16/24.
//

import Foundation
import GoogleGenerativeAI
@Observable
class ApiManager {
    let languageTags: [String: String] = [
        "Afrikaans": "af",
        "Arabic": "ar",
        "Bengali": "bn",
        "Chinese": "zh",
        "Dutch": "nl",
        "English": "en",
        "French": "fr",
        "German": "de",
        "Greek": "el",
        "Hebrew": "he",
        "Hindi": "hi",
        "Indonesian": "id",
        "Italian": "it",
        "Japanese": "ja",
        "Korean": "ko",
        "Malay": "ms",
        "Persian": "fa",
        "Polish": "pl",
        "Portuguese": "pt",
        "Romanian": "ro",
        "Russian": "ru",
        "Spanish": "es",
        "Swahili": "sw",
        "Swedish": "sv",
        "Tamil": "ta",
        "Thai": "th",
        "Turkish": "tr",
        "Ukrainian": "uk",
        "Urdu": "ur",
        "Vietnamese": "vi",
        "Zulu": "zu"
    ]
    
    func getTranslation(translationLanguage: String, inputText: String, inputLanguage: String) async throws -> String {
        let l1 = languageTags[inputLanguage] ?? "en"
        let l2 = languageTags[translationLanguage] ?? "en"
        let url = URL(string: "https://api.mymemory.translated.net/get?q=" + inputText + "&langpair=" + l1 + "|" + l2)!
            let (data,_) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TranslationResponse.self, from: data)
            
            guard let decodedResponse = response.responseData.translatedText.removingPercentEncoding else {
                return "unable to fetch translation"
            }
            print(decodedResponse)
                return decodedResponse
        }
    
    
    func getExampleSentence(language: String, inputText: String, difficulty: String) async throws -> String {
        let apiKey = Config.googleAPIKey
        let prompt: String = "Give me a " + difficulty + " sentence using the word '" + inputText + "' in " + language + ". Please only include this sentence in your response. Make sure a " + difficulty + " " + language + " leaner could understand it."
        let model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
                do {
                    let response = try await model.generateContent(prompt)
                    if let text = response.text{
                        return text
                    } else {
                        return "Empty"
                    }
                } catch {
                    print("Error generating content: \(error)")
                    return "Error"
                }
            }
            
        
    }
struct TranslationResponse: Codable {
    let responseData: ResponseData
}
struct ResponseData: Codable {
    let translatedText: String

}
