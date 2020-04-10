//
//  AudioRecorder.swift
//  Test2
//
//  Created by Константин Емельянов on 12.03.2020.
//  Copyright © 2020 Константин Емельянов. All rights reserved.
//

//
//  Recorder.swift
//  Emoution
//
//  Created by Константин Емельянов on 19.02.2020.
//  Copyright © 2020 Константин Емельянов. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import Alamofire

class AudioRecorder: NSObject, ObservableObject {
    
    override init() {
        super.init()
        fetchRecordings()
    }
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    // константа для обновления AudioRecorder
    var audioRecorder: AVAudioRecorder! // объект AudioRecorder
    var recordings = [Recording]() // массив аудио записей
    var isRecording = false { // переменная сигализирующая о том идёт ли запись
        didSet {
            objectWillChange.send(self)
            // обновляет AudioRecorder
        }
    }   
    
    func startRecording() {
        // начинает запись
        let Session = AVAudioSession.sharedInstance() // объявляет аудио сессию
        do {
            try Session.setCategory(.playAndRecord, mode: .default) // задает параметры
            try Session.setActive(true) // запускает аудиосессию
        } catch {
            print("Ошибка в запуске записи")
        }
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // открывает папку докементов приложения
        let Filename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).wav")
        // дает имя будущему файлу
        
        let settings = [
            // задает формат записи
            AVFormatIDKey:Int(kAudioFormatLinearPCM),
            AVSampleRateKey:16000,
            AVNumberOfChannelsKey:1,
            AVLinearPCMBitDepthKey:8,
            AVLinearPCMIsFloatKey:false,
            AVLinearPCMIsBigEndianKey:false,
            AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
            ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: Filename, settings: settings)
            // передает данные audioRecorder
            audioRecorder.record() // запускает запись
            isRecording = true // показывает что идет запись
        } catch {
            print("Невозможно запустить запись")
        }
    }
    
    func stopRecording() {
        // останавливает запись
        audioRecorder.stop() // останавливает запывание
        isRecording = false // показывает что нет записи
        fetchRecordings() // сортирует записи
    }
    
    func fetchRecordings() {
        //  функция, дающая доступ к записаным айдиофайлам и сортирующая их по дате создания      
        recordings.removeAll() // удаляет все элементы массива recordings
        
        let FM = FileManager.default
        let documentDirectory = FM.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FM.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil) 
        // открывает дерикторию с записанными файлами
        for audio in directoryContents { // проходит по массиву файлов
            let record = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(record) // добавляет в массив recordings новый элемент audio
        }
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        // сортирует массив recordings по дате
        objectWillChange.send(self)
        // обновляет AudioRecorder
    }
    
    func DeleteAt(url: URL) {
        // удаляет конкретный файл
        let FM = FileManager.default
        do {
            try FM.removeItem(at: url)
            // удаляет записаный файл
        }
        catch {
            print("Нечего удалять")
        }
        objectWillChange.send(self)
        // обновляет AudioRecorder
    }
    
    func upload(completion: @escaping (Int) -> Void) {
        // загружает файл на сервер и получает с него ответ
        var i: Int? //переменная, которая передается на экран с информацией
        let recs = recordings.dropLast() // создает массив записей без последнего
        let fileURL = recs.last!.fileURL // создает адрес файла
        
        AF.upload(multipartFormData: { multipartFormData in
            // загружает файл на сервер
            multipartFormData.append(fileURL, withName: "file")
        }, to: "http://217.73.60.165:2480/python")
            .responseJSON{ response in
                // получает ответ
                switch response.result {
                case .success:
                    let data = "\(String(describing: response.result))"
                    // присваивает i значение соответствующее эмоции
                    if data.contains("angry") {
                        i = 0
                    }
                    if data.contains("happy") {
                        i = 1
                    }
                    if data.contains("surprise") {
                        i = 2
                    }
                    if data.contains("neutral") {
                        i = 3
                    }
                    if data.contains("sad") {
                        i = 4
                    }
                    if data.contains("disgust") {
                        i = 5
                    }
                    if data.contains("fear") {
                        i = 6
                    }
                case .failure(let error):
                    if response.response?.statusCode == 500 {
                        i = 7 // ошибка на сервере
                    }
                    else {
                        print(error)
                        i = 8 // другие ошибки, скорее всего нет связи с сервером
                    }
                }
                completion(i ?? 8) // возвращает i в ответ функции
        }
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        // переводит формат даты создания файла в строку
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self) 
    }
    
}


struct AudioRecorder_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
