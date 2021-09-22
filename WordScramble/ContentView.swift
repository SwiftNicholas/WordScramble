//
//  ContentView.swift
//  WordScramble
//
//  Created by Nicholas Verrico on 9/22/21.
//

import SwiftUI
var emptyString: String = ""
var wordListFileName = "start"
var wordListFileExtension = "txt"

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootword = emptyString
    @State private var newWord = emptyString
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    
    var body: some View {
        NavigationView {
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootword)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        guard isOriginalWord(answer) else {
            return wordError(title: "Word used already", message: "Be more original")
        }
        guard isPossibleWord(answer) else {
            return wordError(title: "Letters not found", message: "You have to use only the letters from the original word")
        }
        guard isRealWord(answer) else {
           return wordError(title: "Word not possible", message: "That isn't a real word.")
        }
        
        usedWords.insert(answer, at: 0)
        newWord = emptyString
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: wordListFileName, withExtension: wordListFileExtension) {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootword = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt, from bundle")
    }
    
    func isOriginalWord(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossibleWord(_ word: String) -> Bool {
        var tempWord = rootword
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
                return true
            } else {
                return false
            }
        }
        
        // Should not execute
        assertionFailure("This code should not execute, necssary for compiler safety")
        return false
    }
    
    func isRealWord(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
