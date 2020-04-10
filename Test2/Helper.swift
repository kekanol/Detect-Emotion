//
//  Helper.swift
//  Emoution
//
//  Created by Константин Емельянов on 19.02.2020.
//  Copyright © 2020 Константин Емельянов. All rights reserved.
//

import Foundation

func getCreationDate(for file: URL) -> Date { // достает дату создания файла
    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
        return creationDate
    } else {
        return Date()
    }
}
