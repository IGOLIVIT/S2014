//
//  DashboardView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var appData: AppData
    @State private var showingGoals = false
    @State private var showingFocusSession = false
    @State private var showingAchievements = false
    @State private var showingSparkGame = false
    @State private var showingSettings = false
    @State private var showingTimerSettings = false
    @State private var currentQuoteIndex = 0
    @State private var animationOffset: CGFloat = 0
    
    private let motivationalQuotes = [
        "Success is the sum of small efforts repeated day in and day out.",
        "The way to get started is to quit talking and begin doing.",
        "Don't watch the clock; do what it does. Keep going.",
        "The future depends on what you do today.",
        "Excellence is never an accident. It is always the result of high intention."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    // Background
                    LinearGradient(
                        colors: [
                            VolcanoTheme.primaryBackground,
                            VolcanoTheme.secondaryBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Floating particles
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(VolcanoTheme.lavaOrange.opacity(0.2))
                            .frame(width: CGFloat.random(in: 3...8))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 4...8))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...3)),
                                value: animationOffset
                            )
                    }
                    
                    VStack(spacing: 30) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Your Daily Flow")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                Text("Ignite your potential today")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(VolcanoTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(VolcanoTheme.moltenGold)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        
                        // Today's Progress Ring
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .stroke(VolcanoTheme.secondaryBackground, lineWidth: 12)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: min(CGFloat(appData.totalSessions) / 5.0, 1.0))
                                    .stroke(
                                        LinearGradient(
                                            colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1.0), value: appData.totalSessions)
                                
                                VStack(spacing: 2) {
                                    Text("\(appData.totalSessions)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Text("Sessions")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                }
                            }
                            
                            Text("Today's Focus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                        }
                        .padding(.vertical, 20)
                        
                        // Goals Section
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(VolcanoTheme.moltenGold)
                                    .font(.system(size: 20))
                                
                                Text("My Goals")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                Spacer()
                                
                                Button("All") {
                                    showingGoals = true
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                            }
                            
                            if appData.goals.isEmpty {
                                VStack(spacing: 10) {
                                    Text("No goals yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                    
                                    Button("Create First Goal") {
                                        showingGoals = true
                                    }
                                    .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                                }
                            } else {
                                // Show first 2 active goals
                                let activeGoals = appData.goals.filter { !$0.isCompleted }.prefix(2)
                                if activeGoals.isEmpty {
                                    Text("All goals completed! 🎉")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(VolcanoTheme.moltenGold)
                                } else {
                                    VStack(spacing: 10) {
                                        ForEach(Array(activeGoals), id: \.id) { goal in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(goal.title)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(VolcanoTheme.textPrimary)
                                                        .lineLimit(1)
                                                    
                                                    Text("\(goal.completedSessions)/\(goal.targetSessions) sessions")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(VolcanoTheme.textSecondary)
                                                }
                                                
                                                Spacer()
                                                
                                                // Mini progress bar
                                                GeometryReader { geometry in
                                                    ZStack(alignment: .leading) {
                                                        Rectangle()
                                                            .fill(VolcanoTheme.secondaryBackground)
                                                            .frame(height: 4)
                                                            .cornerRadius(2)
                                                        
                                                        Rectangle()
                                                            .fill(VolcanoTheme.lavaOrange)
                                                            .frame(width: geometry.size.width * goal.progressPercentage, height: 4)
                                                            .cornerRadius(2)
                                                    }
                                                }
                                                .frame(width: 60, height: 4)
                                            }
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(VolcanoTheme.secondaryBackground.opacity(0.3))
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // Timer Settings
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(VolcanoTheme.moltenGold)
                                    .font(.system(size: 20))
                                
                                Text("Timer Settings")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                Spacer()
                                
                                Button("Change") {
                                    showingTimerSettings = true
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                            }
                            
                            HStack {
                                Text("Session Duration:")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(VolcanoTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(appData.defaultTimerDuration) min")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(VolcanoTheme.secondaryBackground.opacity(0.3))
                            )
                        }
                        .padding(.horizontal, 25)
                        
                        // Action Buttons
                        VStack(spacing: 20) {
                            Button("Start Focus Session") {
                                showingFocusSession = true
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                            
                            HStack(spacing: 15) {
                                Button("Achievements") {
                                    showingAchievements = true
                                }
                                .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                                
                                Button("Spark Game") {
                                    showingSparkGame = true
                                }
                                .buttonStyle(VolcanoButtonStyle(isPrimary: false))
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // Motivational Quote
                        VStack(spacing: 10) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundColor(VolcanoTheme.moltenGold)
                                .font(.system(size: 24))
                            
                            Text(motivationalQuotes[currentQuoteIndex])
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(VolcanoTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.horizontal, 30)
                                .animation(.easeInOut(duration: 0.5), value: currentQuoteIndex)
                        }
                        .padding(.vertical, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(VolcanoTheme.secondaryBackground.opacity(0.5))
                                .shadow(color: VolcanoTheme.lavaOrange.opacity(0.2), radius: 10)
                        )
                        .padding(.horizontal, 25)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
        }
        .background(VolcanoTheme.primaryBackground)
        .onAppear {
            animationOffset = 1.0
            startQuoteRotation()
        }
        .sheet(isPresented: $showingGoals) {
            GoalsView(appData: appData)
        }
        .sheet(isPresented: $showingTimerSettings) {
            TimerSettingsView(appData: appData)
        }
        .fullScreenCover(isPresented: $showingFocusSession) {
            FocusSessionView(appData: appData)
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(appData: appData)
        }
        .fullScreenCover(isPresented: $showingSparkGame) {
            SparkGameView(appData: appData)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(appData: appData)
        }
    }
    
    private func startQuoteRotation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentQuoteIndex = (currentQuoteIndex + 1) % motivationalQuotes.count
            }
        }
    }
}

struct TimerSettingsView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDuration: Int = 25
    
    private let timerOptions = [5, 10, 15, 20, 25, 30, 45, 60, 90]
    
    var body: some View {
        NavigationView {
            ZStack {
                VolcanoTheme.primaryBackground.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "timer")
                            .font(.system(size: 60))
                            .foregroundColor(VolcanoTheme.lavaOrange)
                        
                        Text("Timer Settings")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(VolcanoTheme.textPrimary)
                        
                        Text("Choose your focus session duration")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(VolcanoTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 20) {
                        // Custom duration picker
                        VStack(spacing: 15) {
                            HStack {
                                Button("-") {
                                    if selectedDuration > 5 {
                                        selectedDuration -= 5
                                    }
                                }
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(VolcanoTheme.secondaryBackground)
                                )
                                
                                Spacer()
                                
                                VStack(spacing: 5) {
                                    Text("\(selectedDuration)")
                                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Text("minutes")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button("+") {
                                    if selectedDuration < 120 {
                                        selectedDuration += 5
                                    }
                                }
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(VolcanoTheme.secondaryBackground)
                                )
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        // Quick selection buttons
                        VStack(spacing: 15) {
                            Text("Quick Select:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(timerOptions, id: \.self) { duration in
                                    Button("\(duration) min") {
                                        selectedDuration = duration
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedDuration == duration ? VolcanoTheme.primaryBackground : VolcanoTheme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedDuration == duration ? VolcanoTheme.lavaOrange : VolcanoTheme.secondaryBackground.opacity(0.3))
                                    )
                                }
                            }
                        }
                        
                        Button("Save Settings") {
                            appData.setTimerDuration(selectedDuration)
                            dismiss()
                        }
                        .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(VolcanoTheme.textSecondary)
                }
            }
        }
        .onAppear {
            selectedDuration = appData.defaultTimerDuration
        }
    }
}

struct VolcanoTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(VolcanoTheme.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(VolcanoTheme.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(VolcanoTheme.lavaOrange.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}
