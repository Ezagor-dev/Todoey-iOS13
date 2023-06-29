//
//  ContentView.swift
//  AshList
//
//  Created by Ezagor on 29.06.2023.
//  Copyright © 2023 Ezagor. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            OnBoardView(systemImageName: "scribble.variable", title: "Stay Organized", description: "Effortlessly manage your tasks and stay organized with AshList. Keep track of everything you need to do in one convenient place.")
            OnBoardView(systemImageName: "paintpalette.fill", title: "Customize Your Workflow", description: "Tailor AshList to fit your unique workflow. Create categories, create items, and personalize your task management experience.")
            OnBoardView(systemImageName: "dial.min.fill", title: "Boost Productivity", description: "Stay focused, accomplish more, and experience a sense of accomplishment as you make progress towards your targets.")
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct OnBoardView: View {
    
    let systemImageName: String
    let title: String
    let description: String
    
    var body: some View{
        VStack(spacing:20){
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.black)
            
            Text(title)
                .font(.title).bold()
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal,40)
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View{
        OnBoardView(systemImageName: "scribble.variable", title: "Stay Organized", description: "Effortlessly manage your tasks and stay organized with AshList. Keep track of everything you need to do in one convenient place.")
    }
}


