//
//  SparkGameView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct SparkGameView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var timeRemaining = 30
    @State private var score = 0
    @State private var sparks: [Spark] = []
    @State private var gameTimer: Timer?
    @State private var sparkTimer: Timer?
    @State private var animationOffset: CGFloat = 0
    @State private var showingResults = false
    
    enum GameState {
        case ready, playing, finished
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        VolcanoTheme.primaryBackground,
                        VolcanoTheme.secondaryBackground,
                        VolcanoTheme.primaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationOffset)
                
                // Background particles
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(VolcanoTheme.lavaOrange.opacity(0.1))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            .linear(duration: Double.random(in: 5...10))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...3)),
                            value: animationOffset
                        )
                }
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { 
                            endGame()
                            dismiss() 
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(VolcanoTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        if gameState == .playing {
                            HStack(spacing: 30) {
                                VStack(spacing: 2) {
                                    Text("TIME")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                    Text("\(timeRemaining)")
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(VolcanoTheme.moltenGold)
                                }
                                
                                VStack(spacing: 2) {
                                    Text("SCORE")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                    Text("\(score)")
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(VolcanoTheme.lavaOrange)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Invisible spacer for balance
                        Color.clear
                            .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    // Game Area
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if gameState == .ready {
                            ReadyView(onStart: startGame)
                        } else if gameState == .finished {
                            ResultsView(score: score, onRestart: restartGame, onClose: { dismiss() })
                        }
                        
                        // Game sparks
                        ForEach(sparks) { spark in
                            SparkView(spark: spark) {
                                catchSpark(spark)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            animationOffset = 1.0
        }
        .onDisappear {
            endGame()
        }
        .alert("Game Complete!", isPresented: $showingResults) {
            Button("Awesome!") {
                appData.addSparks(score)
                dismiss()
            }
        } message: {
            Text("You caught \(score) sparks! They've been added to your Momentum collection.")
        }
    }
    
    private func startGame() {
        gameState = .playing
        timeRemaining = 30
        score = 0
        sparks = []
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                finishGame()
            }
        }
        
        // Start spark spawning
        sparkTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            spawnSpark()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func spawnSpark() {
        let newSpark = Spark(
            id: UUID(),
            position: CGPoint(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 150...UIScreen.main.bounds.height - 200)
            ),
            creationTime: Date(),
            lifetime: Double.random(in: 2.0...4.0)
        )
        
        sparks.append(newSpark)
        
        // Remove spark after its lifetime
        DispatchQueue.main.asyncAfter(deadline: .now() + newSpark.lifetime) {
            sparks.removeAll { $0.id == newSpark.id }
        }
    }
    
    private func catchSpark(_ spark: Spark) {
        score += 1
        sparks.removeAll { $0.id == spark.id }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func finishGame() {
        gameState = .finished
        endGame()
        showingResults = true
    }
    
    private func restartGame() {
        gameState = .ready
    }
    
    private func endGame() {
        gameTimer?.invalidate()
        sparkTimer?.invalidate()
        gameTimer = nil
        sparkTimer = nil
        sparks = []
    }
}

struct ReadyView: View {
    let onStart: () -> Void
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(VolcanoTheme.lavaOrange)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Text("Catch the Spark")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(VolcanoTheme.textPrimary)
                
                Text("Tap the glowing sparks before they fade away!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(VolcanoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 15) {
                Text("⚡ Each spark caught = +1 point")
                Text("⏱️ 30 seconds to catch as many as you can")
                Text("🎯 Quick reflexes = higher score")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(VolcanoTheme.textSecondary)
            
            Button("Start Game") {
                onStart()
            }
            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
        }
        .onAppear {
            pulseAnimation = true
        }
    }
}

struct ResultsView: View {
    let score: Int
    let onRestart: () -> Void
    let onClose: () -> Void
    @State private var celebrationAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Image(systemName: score >= 20 ? "star.fill" : score >= 10 ? "flame.fill" : "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(score >= 20 ? VolcanoTheme.moltenGold : VolcanoTheme.lavaOrange)
                    .scaleEffect(celebrationAnimation ? 1.3 : 1.0)
                    .rotationEffect(.degrees(celebrationAnimation ? 360 : 0))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).repeatCount(3), value: celebrationAnimation)
                
                Text("Game Complete!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(VolcanoTheme.textPrimary)
                
                Text("You caught \(score) sparks!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(VolcanoTheme.lavaOrange)
            }
            
            VStack(spacing: 10) {
                Text(scoreMessage(for: score))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(VolcanoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Sparks added to your collection!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(VolcanoTheme.moltenGold)
            }
            
            HStack(spacing: 20) {
                Button("Play Again") {
                    onRestart()
                }
                .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                
                Button("Done") {
                    onClose()
                }
                .buttonStyle(VolcanoButtonStyle(isPrimary: true))
            }
        }
        .onAppear {
            celebrationAnimation = true
        }
    }
    
    private func scoreMessage(for score: Int) -> String {
        switch score {
        case 0...5:
            return "Keep practicing! Your reflexes are warming up."
        case 6...10:
            return "Good start! Your focus is building momentum."
        case 11...15:
            return "Impressive! Your concentration is sharp."
        case 16...20:
            return "Excellent! You're in the flow state."
        default:
            return "Outstanding! You're a true Spark Master!"
        }
    }
}

struct SparkView: View {
    let spark: Spark
    let onTap: () -> Void
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.5
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                VolcanoTheme.lavaOrange.opacity(glowIntensity),
                                VolcanoTheme.moltenGold.opacity(glowIntensity * 0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                // Main spark
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 20)
                    .shadow(color: VolcanoTheme.lavaOrange, radius: 5)
                
                // Inner glow
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 8, height: 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .position(spark.position)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            startAnimations()
            startFading()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            scale = 1.2
            glowIntensity = 1.0
        }
    }
    
    private func startFading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + spark.lifetime * 0.7) {
            withAnimation(.easeOut(duration: spark.lifetime * 0.3)) {
                opacity = 0.0
                scale = 0.5
            }
        }
    }
}

struct Spark: Identifiable {
    let id: UUID
    let position: CGPoint
    let creationTime: Date
    let lifetime: Double
}


