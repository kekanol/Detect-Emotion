//
//  RecordingsList.swift
//  Emoution
//
//  Created by Константин Емельянов on 19.02.2020.
//  Copyright © 2020 Константин Емельянов. All rights reserved.
//

import SwiftUI

let CurrEmoution = ["Напряжение", "Радость", "Удивление", "Спокойствие", "Печаль", "Отвращение", "Страх", "", "Нет сети"]

struct RecordingsList: View {
    @Binding var showrec: Bool
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var Results : [Int]
    
     func clearAll() {
        // чистит все записи и ответы
        let count: Int = audioRecorder.recordings.count // константа количества записей
        for i in 0..<count {
            // удаляет каждый файл
            audioRecorder.DeleteAt(url: audioRecorder.recordings[i].fileURL)
        }
        audioRecorder.recordings.removeAll() // чистит recordings
        Results.removeAll() // чистит Results
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Ваши записи")
                    .foregroundColor(.primary)
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.top)
                    
                Spacer()
                Button(action: {self.clearAll()}) { // кнопка отчистки
                   Image(systemName: "bin.xmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)
                    .padding(.top)
                }
                
                Button(action: {self.showrec.toggle()}) { // кнопка закрытия
                Image(systemName: "multiply.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .background(Color("WhiteBackGround"))
            
            List { // создает список эмоций 
                ForEach(Results, id: \.self) { number in 
                    Text(CurrEmoution[number])
                        .foregroundColor(.primary)
                }
            }
        .foregroundColor(Color("WhiteBackGround"))
        }
        .background(Color("WhiteBackGround"))
        .cornerRadius(30)
        .frame(width: 350, height: 450)
        .shadow(color: Color("shadowColor"), radius: 10)
        .padding(20)
    }
}

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList(showrec: ContentView(audioRecorder: AudioRecorder()).$showrec, audioRecorder: AudioRecorder(), Results: ContentView(audioRecorder: AudioRecorder()).$results)
    }
}


