//
//  Editor.swift
//  Pagi
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct Editor: View {
    @Binding var text: String
    
    @StateObject var viewModel = EditorViewModel()
    
    #if os(iOS)
    private let isiOS = true
    #else
    private let isiOS = false
    #endif
    private let progressBarHeight: CGFloat = 24
    
    init(text: Binding<String>) {
        #if os(iOS)
        UITextView.appearance().backgroundColor = .clear
        #endif
        
        self._text = text
    }
    
    @ViewBuilder
    func iOSEditor() -> some View {
            VStack {
                TextEditorView(
                    text: $text,
                    font: viewModel.font.fileName,
                    size: CGFloat(viewModel.fontSize),
                    isSpellCheckingEnabled: viewModel.isSpellCheckingEnabled,
                    focusMode: $viewModel.focusMode,
                    focusType: viewModel.focusType
                )
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
            .id("\(viewModel.font.rawValue)\(viewModel.fontSize)\(viewModel.isSpellCheckingEnabled)")
    }
    
    @ViewBuilder
    func macEditor() -> some View {
        TextEditorView(
            text: $text,
            font: viewModel.font.fileName,
            size: CGFloat(viewModel.fontSize),
            isSpellCheckingEnabled: viewModel.isSpellCheckingEnabled,
            focusMode: $viewModel.focusMode,
            focusType: viewModel.focusType
        )
            .id("\(viewModel.font.rawValue)\(viewModel.fontSize)")
    }
    
    @ViewBuilder
    func wordCount() -> some View {
        HStack {
            Spacer()
            
            if viewModel.wordCount {
                Text("\(viewModel.words)W")
                    .font(
                        .custom(viewModel.font.fileName, size: 12)
                            .monospacedDigit()
                    )
                    .foregroundColor(.foregroundLight)
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(nil, value: viewModel.words)
            }
        }
        .padding(isiOS ? .top : .bottom, viewModel.progressBarVisible ? 0 : 10)
        .animation(.interactiveSpring(), value: viewModel.overlayHover)
        .animation(.default, value: viewModel.words)
    }
    
    @ViewBuilder
    func progressBar() -> some View {
        VStack(spacing: 0) {
            if viewModel.progressBarVisible {
                ProgressBar(
                    percent: viewModel.percent,
                    color: .accentColor,
                    height: viewModel.isProgressBarExpanded ? progressBarHeight : 5
                )
                .transition(.move(edge: isiOS ? .top : .bottom))
                .animation(.default, value: viewModel.words)
                .animation(.interactiveSpring(), value: viewModel.overlayHover)
                .overlay (
                    VStack {
                        if viewModel.isProgressBarExpanded {
                            Label(viewModel.successText, systemImage: "checkmark")
                                .transition(.offset(x: 0, y: progressBarHeight))
                        }
                    }
                        .font(
                            .custom(viewModel.font.fileName, size: 12)
                            .monospacedDigit()
                        )
                        .foregroundColor(.background)
                        .animation(.interactiveSpring(), value: viewModel.overlayHover)
                )
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            macEditor()
            #else
            iOSEditor()
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .overlay(
            VStack {
                VStack {
                    #if os(macOS)
                    wordCount()
                    progressBar()
                    #else
                    progressBar()
                    wordCount()
                    #endif
                }
                .onHover(perform: { hover in
                    viewModel.overlayHover = hover
                })
            }
                .frame(maxHeight: .infinity, alignment: isiOS ? .top : .bottom)
        )
        .onAppear {
            viewModel.calculateWordCount(text)
        }
        .onChange(of: text, perform: { value in
            viewModel.calculateWordCount(text, typing: true)
        })
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(text: .constant("This is a test."))
    }
}
