//
//  ContentView.swift
//  Assignment#6
//
//  Created by Тимофей Кислов on 17.10.2026.
//

import SwiftUI


struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Loading...")
                    .font(.headline)
                    .padding(.top, 20)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

// ОСНОВНОЙ ЭКРАН С РУЛЕТКОЙ
struct ContentView: View {
    let dishes = ["Dish1", "Dish2", "Dish3", "Dish4", "Dish5", "Dish6", "Dish7", "Dish8", "Dish9", "Dish10"]
    
    @State private var currentIndex = 0
    @State private var isRolling = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 40) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .padding(.top, 40)
            
            Spacer()
            
            Image(dishes[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(25)
            
            Spacer()
            
            Button(action: startRolling) {
                Text(isRolling ? "To spin..." : "Scroll!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isRolling ? Color.gray : Color.blue)
                    .cornerRadius(15)
            }
            .disabled(isRolling)
            
            // кнопка выхода
            Button(action: {
                exit(0)
            }) {
                Text("Exit")
                    .foregroundColor(.red)
                    .padding(.bottom, 30)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    // таймер мельница
    func startRolling() {
        isRolling = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.05)) {
                currentIndex = Int.random(in: 0..<dishes.count)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            timer?.invalidate()
            timer = nil
            
            let finalIndex = Int.random(in: 0..<dishes.count)
            withAnimation(.spring()) {
                currentIndex = finalIndex
            }
            isRolling = false
        }
    }
}
