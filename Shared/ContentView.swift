//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PagiDocument
    
    var body: some View {
        ZStack {
            Color.background
            
            Editor(text: $document.text)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PagiDocument()))
    }
}
