//
//  Chat2Worker.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 17.11.2023.
//  
//

import Foundation

protocol Chat2Worker {
    var widgetServices: WidgetServices { get }
    
    //func fetchData(completion: @escaping (Result<[Chat2Item], RequestError>) -> Void)
}

final class Chat2NetworkWorker: Chat2Worker {
    
    private(set) var widgetServices: WidgetServices
    
    init(widgetServices: WidgetServices = WidgetServices()) {
        self.widgetServices = widgetServices
    }
    
   /*
    func fetchData(completion: @escaping (Result<[Chat2Item], RequestError>) -> Void) {
        
    }
    */
}
