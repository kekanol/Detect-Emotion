//
//  ContentView.swift
//  Emoution
//
//  Created by Константин Емельянов on 16.01.2020.
//  Copyright © 2020 Константин Емельянов. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var rec: Bool = false
    @State private var showres: Bool = false
    @State var showrec: Bool = false
    let timer = TTimer().timer
    @State var time = 0
    @State var emoution = ""
    @State var list: [SuggList] = []                     
    @State var results: [Int] = []
    @State var i: Int = 0
    func record() {
        if rec == false {
            time = 0 // обнуляет счетчик времени
            audioRecorder.startRecording() // начинает запись
        }
        else {
            audioRecorder.stopRecording() // завершает запись
            time = 0 // обнуляет счетчик времени на всякий случай
        }
    }
    
    func save(i: Int) { // записывает результаты
        if i != 7 {
            if self.results != [] {
                if self.results[0] != i { 
                    var ar = [i] // создает массив результатов
                    ar += self.results // дописывает предыдущие результаты
                    self.results = ar // перезаписывает предыдущие результаты
                }
            } else {
                self.results.append(i) // добавляет новый результат, если результаты пустые
            }
        }
            self.emoution = Emoution().Emoutions[i] // записывает результаты в главное окошко
            self.list = Emoution().sugestions[i] // записывает результаты в советы
    }
    var body: some View {
        ZStack {
            TimerLabel(rec: $rec)
                .onReceive(timer) { _ in
                    if self.rec {
                        if self.time % 5 == 0 && self.time != 0 { // каждые 5 секунд
                            self.audioRecorder.stopRecording() // останавливает запись
                            self.audioRecorder.startRecording() // начинает запись
                            AudioRecorder().upload() { i in // загружает запись на сервер
                                self.save(i: i) // сохраняет результаты пришедшие с сервера
                            }
                            let recs = self.audioRecorder.recordings.dropLast()
                            if recs.count != 0 {
                                self.audioRecorder.DeleteAt(url: recs.last!.fileURL) // удаляет записанный 5секундный записанный файл
                            }
                            self.audioRecorder.fetchRecordings() // обновляет recordings
                            
                        }
                        self.time += 1 // добавляет к времени 1 секунду
                    }
            }
            VStack {
                Title(rec: $rec, CurEmoution: self.$emoution) // заголовок
                    .animation(.easeInOut)
                    .padding()
                    .padding(.top, 60)
                Spacer()
                Text(rec ? "Идет запись" : "Начать запись")
                    .font(.title)
                Spacer()
                ZStack {
                    Circles(rec: $rec)
                    Button(action: {self.record();self.rec.toggle()}) { // круглая кнопка записи
                        Image(systemName: "waveform.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.red)
                            .frame(width: 150, height: 150)
                            .opacity(rec ? 1 : 0)
                            .animation(.spring())
                    }
                }
                Spacer()
                Button(action: {self.record();self.rec.toggle()}) { // кнопка старт/стоп
                    HStack(spacing: 5) {
                        Image(systemName:rec ? "pause.circle.fill" : "play.circle.fill")
                        Text(rec ? "Стоп" : "Старт")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .frame(width: 160)
                    .foregroundColor(rec ? .red : .blue)
                }
                .frame(width: 220, height: 80)
                .background(Color("WhiteBackGround"))
                .cornerRadius(30)
                .shadow(color: Color("shadowColor"), radius: 10)
                .padding()
            }
            
            Suggestion(rec: $rec, list: self.$list, showres: $showres) // окошко советов
                .offset(y: showres ? 0 : 800)
                .animation(.spring())
            RecordingsList(showrec: $showrec, audioRecorder: AudioRecorder(), Results: $results) // окошко списка эмоций
                .offset(y: showrec ? 0 : 800)
                .animation(.spring())
            MenuButton(showrec: $showrec) // конпка списка записей
                .offset(x: showrec ? 150 : 40, y: -25)
                .animation(.spring())
            SugButton(showres: $showres) // кнопка советов
                .offset(x: showres ? -150 : -40, y: -25)
                .animation(.spring())
        }
        
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioRecorder: AudioRecorder(), i: 0)
    }
}

struct MenuButton: View {
    @Binding var showrec: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {self.showrec.toggle()}) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.leading, 18)
                    .frame(width: 90, height: 60)
                    .background(Color("WhiteBackGround"))
                    .cornerRadius(30)
                    .shadow(color: Color("shadowColor"), radius: 10)
                }
            }
            
        }
    }
}

struct SugButton: View {
    @Binding var showres: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {self.showres.toggle()}) {
                    HStack {
                        Spacer()
                        Image(systemName: "list.number")
                            .foregroundColor(.primary)                        
                    }
                    .padding(.trailing, 18)
                    .frame(width: 90, height: 60)
                    .background(Color("WhiteBackGround"))
                    .cornerRadius(30)
                    .shadow(color: Color("shadowColor"), radius: 10)
                }
                Spacer()
            }
            
        }
    }
}



struct SuggList: Identifiable {
    var id = UUID()
    var num: Int
    var suggestion: String
}

struct TTimer {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
}

struct TimerLabel: View {
    @Binding var rec: Bool
    @State var currentSeconds: Int = 0
    @State var currentMinutes: Int = 0
    @State var lesser1: String = "0"
    @State var lesser2: String = "0"
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    func timeCheck() {
        
        if self.currentSeconds < 59 {
            self.currentSeconds += 1
            if self.currentSeconds < 10 {
                self.lesser1 = "0"
            }
            else {
                self.lesser1 = ""
            }
        }
        else {
            self.currentMinutes += 1
            self.currentSeconds = 0
            if self.currentMinutes < 10 {
                self.lesser2 = "0"
            }
            else {
                self.lesser2 = ""
            }
        }
    } 
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(lesser2 + "\(currentMinutes)" + ":" + lesser1 + "\(currentSeconds)")
                    .onReceive(timer) { _ in
                        if self.rec {
                            self.timeCheck()
                        }
                        else {
                            self.currentSeconds = 0
                            self.currentMinutes = 0
                            self.lesser1 = "0"
                            self.lesser2 = "0"
                        }
                }
                .onAppear() {
                    self.timer = TTimer().timer
                }
                .padding()
                .padding(.bottom, 130)
            }.frame(width: 100, alignment: .center)
        }
    }
}

struct Circles: View {
    @Binding var rec : Bool 
    
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var bigroundSize: CGFloat = 210
    @State var middleroundSize: CGFloat = 200
    @State var smallroundSize: CGFloat = 150
    func changeSize1(length: CGFloat) -> CGFloat {
        
        if length == 210 {
            let a: CGFloat = 230
            return a
        }
        if length == 230 {
            let a: CGFloat = 210
            return a
        }
        return length
    }
    func changeSize2(length: CGFloat) -> CGFloat {
        if length == 180 {
            let a: CGFloat = 200
            return a
        }
        if length == 200 {
            let a: CGFloat = 180
            return a
        }
        return length
    }
    func changeSize3(length: CGFloat) -> CGFloat {
        if length == 150 {
            let a: CGFloat = 170
            return a
        }
        if length == 170 {
            let a: CGFloat = 150
            return a
        }
        return length
    }
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(Color("ColorReddy"))
                .frame(width: self.bigroundSize, height: self.bigroundSize)
                .opacity(rec ? 0.3 : 0)
                .onReceive(timer) { _ in
                    self.bigroundSize = self.changeSize1(length: self.bigroundSize)
            }
            .animation(.spring())
            Circle()
                .foregroundColor(Color("ColorReddy"))
                .frame(width: self.middleroundSize, height: self.middleroundSize)
                .opacity(rec ? 0.5 : 0)
                .onReceive(timer) { _ in
                    self.middleroundSize = self.changeSize2(length: self.middleroundSize)
            }
            .animation(.spring())
            Circle()
                .foregroundColor(rec ? Color("WhiteBackGround") : .red)
                .frame(width: 149, height: 149)
                .animation(.easeInOut)
            
        }
        .frame(width: 230, height: 230)
    }
}

struct Emoution {
    let Emoutions = ["Вы напряжены", "Вы радостны", "Вы удивлены", "Вы спокойны", "Вы печальны", "Вы отвращены", "Вы боитесь", "Подождите", "Нет связи"]
    // массив title
    let sugestions: [[SuggList]] = [ // массив советов
//        Напряжение: 
        [SuggList(num: 1, suggestion: "Принять ванну с пеной"),
         SuggList(num: 2, suggestion: "Заняться медитацией"),
         SuggList(num: 3, suggestion: "Послушать успокаивающую музыку. Шелест листьев, шум моря или звуки дождя хорошо снимают стресс"),
         SuggList(num: 4, suggestion: "Можно изменить освещение - холодные тона света очень успокаивают "),
         SuggList(num: 5, suggestion: "Выпейте чай с ромашкой")],

//        Радость: 
        [SuggList(num: 1, suggestion: "У вас отличное настроение! Самое время поделиться им с окружающими."),
         SuggList(num: 2, suggestion: "Включите любимый плейлист"),
         SuggList(num: 3, suggestion: "Позвоните друзьям и родным"),
         SuggList(num: 4, suggestion: "Займитесь спортом"),
         SuggList(num: 5, suggestion: "Приготовьте что-нибудь вкусное")],

//        В удивлении: 
        [SuggList(num: 1, suggestion: "Рассказать друзьям и родным о том, что произошло."),
         SuggList(num: 2, suggestion: "Поделитесь в соц.сетях новостями"),
         SuggList(num: 3, suggestion: "Включите хорошую музыку для хорошего настроения")],

//        В нейтральном состоянии: 
        [SuggList(num: 1, suggestion: "Можно заняться делами, до которых никак не доходили руки."),
         SuggList(num: 2, suggestion: "Сейчас самое время сосредоточится и плодотворно поработать")],

//        Грусть: 
        [SuggList(num: 1, suggestion: "Съесть немного сладкого"),
         SuggList(num: 2, suggestion: "Займитесь активным видом отдыха"),
         SuggList(num: 3, suggestion: "Включить комедию или мелодраму с хорошим концом"),
         SuggList(num: 4, suggestion: "Прогуляйтесь на свежем воздухе"),
         SuggList(num: 5, suggestion: "Посмотрите видео с котиками")],
 
//        Отвращение:
        [SuggList(num: 1, suggestion: "Постарайтесь убрать все раздражающие факторы "),
         SuggList(num: 2, suggestion: "Прогуляйтесь на свежем воздухе"),
         SuggList(num: 3, suggestion: "Почитайте книгу"),
         SuggList(num: 4, suggestion: "Займитесь спортом")],
        
//          Страх
        [SuggList(num: 1, suggestion: "Успокоиться"),
         SuggList(num: 2, suggestion: "Поговорить с кем-то"),
         SuggList(num: 5, suggestion: "Сменить «минус» на «плюс». Подумайте о ситуации в положительном ключе ")],
        
        [SuggList(num: 1, suggestion: "Попробуйте попозже")],
        
        [SuggList(num: 1, suggestion: "Подключитесь к интернету"),]
    ]
    
}


struct Title: View {
    @Binding var rec : Bool
    @Binding var CurEmoution: String
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var leng1: CGFloat = 13
    @State var leng2: CGFloat = 17
    func sizeChange(length: CGFloat) -> CGFloat {
        if length == 13 {
            let a: CGFloat = 17
            return a
        }
        if length == 17 {
            let a: CGFloat = 13
            return a
        }
        return length
    }
    var body: some View {
        HStack {
            if rec {
                HStack {
                    Circle()
                        .frame(width: leng1, height: leng1)
                    Circle()
                        .frame(width: leng2, height: leng2)
                    Circle()
                        .frame(width: leng1, height: leng1)
                    
                }
                .onReceive(timer) { _ in
                    self.leng1 = self.sizeChange(length: self.leng1)
                    self.leng2 = self.sizeChange(length: self.leng2)
                }
                .onAppear() {
                    self.leng1 = CGFloat(13)
                    self.leng2 = CGFloat(17)
                    self.timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
                }
                .onDisappear() {
                    self.timer.upstream.connect().cancel()
                }
                .frame(width: 60, height: 20)
                .padding(.horizontal)
                if CurEmoution != "" {
                    VStack(alignment: .trailing) {
                        Text("\(CurEmoution)")
                            .font(.largeTitle)
                    }
                    Spacer()
                }
            }
            else {
                Text("\(CurEmoution)")
                    .font(.largeTitle)
            }
        }
            //        .background(Color("WhiteBackGround"))
            .frame(width: 350, height: 50)
            .animation(.linear)
    }
}

struct Suggestion: View {
    @Binding var rec : Bool
    @Binding var list: [SuggList]
    @Binding var showres: Bool
    var body: some View {
        
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Попробуйте")
                    .font(.largeTitle)
                    .frame(minWidth: 0 , maxWidth: .infinity, alignment: .leading)
                    .padding()
                Button(action: {self.showres.toggle()}) {
                    Image(systemName: "multiply.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.trailing)
                }
                .buttonStyle(PlainButtonStyle())
            }
            ForEach(list) { item in
                HStack {
                    Text(String(item.num) + ".")
                        .font(.headline)
                        .fontWeight(.light)
                        .padding(.leading)
                        .foregroundColor(.primary)
                    Text(item.suggestion)
                        .font(.headline)
                        .fontWeight(.light)
                        .padding(.trailing)
                        .foregroundColor(.primary)
                }
            }
            Spacer()
        }
            
        .frame(width: 350, height: 400)
        .background(Color("WhiteBackGround"))
        .cornerRadius(30)
        .shadow(color: Color("shadowColor"), radius: 20)
        
        
    }
}
