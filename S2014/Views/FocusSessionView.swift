//
//  FocusSessionView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct FocusSessionView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining: Int = 0
    @State private var totalTime: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var showingCompletion = false
    @State private var showingGoalSelection = false
    @State private var selectedGoal: Goal?
    @State private var timer: Timer?
    @State private var pulseAnimation = false
    @State private var glowIntensity: Double = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
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
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                // Lava pulse effect
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    VolcanoTheme.lavaOrange.opacity(0.3),
                                    VolcanoTheme.lavaOrange.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                        .opacity(isRunning ? glowIntensity : 0.2)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: pulseAnimation
                        )
                }
                
                VStack(spacing: 50) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(VolcanoTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Focus Session")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                            
                            if let selectedGoal = selectedGoal {
                                Text(selectedGoal.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(VolcanoTheme.moltenGold)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Goal selection button
                        Button(action: { showingGoalSelection = true }) {
                            Image(systemName: "target")
                                .font(.system(size: 20))
                                .foregroundColor(VolcanoTheme.moltenGold)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Timer Circle
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(VolcanoTheme.secondaryBackground, lineWidth: 15)
                            .frame(width: 280, height: 280)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(totalTime - timeRemaining) / CGFloat(totalTime))
                            .stroke(
                                LinearGradient(
                                    colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1.0), value: timeRemaining)
                        
                        // Timer text
                        VStack(spacing: 10) {
                            Text(timeString(from: timeRemaining))
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(VolcanoTheme.textPrimary)
                            
                            Text(isRunning ? "Stay Focused" : isPaused ? "Paused" : "Ready to Begin")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(VolcanoTheme.textSecondary)
                                .animation(.easeInOut(duration: 0.3), value: isRunning)
                        }
                    }
                    .scaleEffect(pulseAnimation && isRunning ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Spacer()
                    
                    // Control buttons
                    HStack(spacing: 30) {
                        if !isRunning && !isPaused {
                            Button("Start") {
                                startTimer()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                        } else if isRunning {
                            Button("Pause") {
                                pauseTimer()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                        } else {
                            Button("Resume") {
                                resumeTimer()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                        }
                        
                        if isRunning || isPaused {
                            Button("Reset") {
                                resetTimer()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            pulseAnimation = true
            totalTime = appData.defaultTimerDuration * 60
            timeRemaining = totalTime
        }
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showingGoalSelection) {
            GoalSelectionView(appData: appData, selectedGoal: $selectedGoal)
        }
        .alert("Session Complete!", isPresented: $showingCompletion) {
            Button("Great!") {
                appData.completeFocusSession(minutes: appData.defaultTimerDuration, goalId: selectedGoal?.id)
                dismiss()
            }
        } message: {
            let goalText = selectedGoal != nil ? " for goal \"\(selectedGoal!.title)\"" : ""
            Text("Congratulations! You completed a focus session\(goalText). Momentum spark earned!")
        }
    }
    
    private func startTimer() {
        isRunning = true
        isPaused = false
        glowIntensity = 0.8
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func pauseTimer() {
        isRunning = false
        isPaused = true
        glowIntensity = 0.3
        timer?.invalidate()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func resumeTimer() {
        startTimer()
    }
    
    private func resetTimer() {
        isRunning = false
        isPaused = false
        timeRemaining = totalTime
        glowIntensity = 0.5
        timer?.invalidate()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func completeSession() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        
        // Strong haptic feedback for completion
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        showingCompletion = true
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct GoalSelectionView: View {
    @ObservedObject var appData: AppData
    @Binding var selectedGoal: Goal?
    @Environment(\.dismiss) private var dismiss
    
    var activeGoals: [Goal] {
        appData.goals.filter { !$0.isCompleted }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VolcanoTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            Image(systemName: "target")
                                .font(.system(size: 60))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                            
                            Text("Select Goal")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                            
                            Text("Which goal is this focus session for?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(VolcanoTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 15) {
                            // No goal option
                            Button(action: {
                                selectedGoal = nil
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("No Specific Goal")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(VolcanoTheme.textPrimary)
                                        
                                        Text("Just a focus session for concentration")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(VolcanoTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedGoal == nil {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(VolcanoTheme.moltenGold)
                                    } else {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(VolcanoTheme.textSecondary.opacity(0.5))
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(VolcanoTheme.secondaryBackground.opacity(0.4))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(
                                                    selectedGoal == nil ? VolcanoTheme.moltenGold.opacity(0.5) : VolcanoTheme.secondaryBackground,
                                                    lineWidth: selectedGoal == nil ? 2 : 1
                                                )
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Active goals
                            if activeGoals.isEmpty {
                                VStack(spacing: 15) {
                                Text("No Active Goals")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(VolcanoTheme.textSecondary)
                                
                                Text("Create a goal in the \"My Goals\" section")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(VolcanoTheme.textSecondary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 30)
                            } else {
                                ForEach(activeGoals, id: \.id) { goal in
                                    Button(action: {
                                        selectedGoal = goal
                                        dismiss()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(goal.title)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(VolcanoTheme.textPrimary)
                                                    .lineLimit(2)
                                                
                                                if !goal.description.isEmpty {
                                                    Text(goal.description)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(VolcanoTheme.textSecondary)
                                                        .lineLimit(2)
                                                }
                                                
                                                Text("\(goal.completedSessions)/\(goal.targetSessions) sessions completed")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(spacing: 8) {
                                                if selectedGoal?.id == goal.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(VolcanoTheme.moltenGold)
                                                } else {
                                                    Image(systemName: "circle")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(VolcanoTheme.textSecondary.opacity(0.5))
                                                }
                                                
                                                // Mini progress indicator
                                                VStack(spacing: 2) {
                                                    Text("\(Int(goal.progressPercentage * 100))%")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(VolcanoTheme.textSecondary)
                                                    
                                                    Rectangle()
                                                        .fill(VolcanoTheme.secondaryBackground)
                                                        .frame(width: 30, height: 3)
                                                        .cornerRadius(1.5)
                                                        .overlay(
                                                            Rectangle()
                                                                .fill(VolcanoTheme.lavaOrange)
                                                                .frame(width: 30 * goal.progressPercentage, height: 3)
                                                                .cornerRadius(1.5),
                                                            alignment: .leading
                                                        )
                                                }
                                            }
                                        }
                                        .padding(20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(VolcanoTheme.secondaryBackground.opacity(0.4))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(
                                                            selectedGoal?.id == goal.id ? VolcanoTheme.moltenGold.opacity(0.5) : VolcanoTheme.secondaryBackground,
                                                            lineWidth: selectedGoal?.id == goal.id ? 2 : 1
                                                        )
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Select Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(VolcanoTheme.moltenGold)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}


