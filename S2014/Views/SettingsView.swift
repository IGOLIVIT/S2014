//
//  SettingsView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
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
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(VolcanoTheme.lavaOrange.opacity(0.2))
                                .frame(width: CGFloat.random(in: 2...4))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                                .animation(
                                    .easeInOut(duration: Double.random(in: 4...7))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...2)),
                                    value: animationOffset
                                )
                        }
                        
                        VStack(spacing: 30) {
                            // App Info Section
                            VStack(spacing: 20) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                
                                VStack(spacing: 8) {
                                    Text("IgniteFlow")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Text("Ignite your potential, master your flow")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 20)
                            
                            // Statistics Section
                            VStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(VolcanoTheme.moltenGold)
                                        .font(.system(size: 20))
                                    
                                    Text("Your Progress")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 15) {
                                    StatisticRow(
                                        icon: "flame.fill",
                                        title: "Total Focus Sessions",
                                        value: "\(appData.totalSessions)",
                                        color: VolcanoTheme.lavaOrange
                                    )
                                    
                                    StatisticRow(
                                        icon: "clock.fill",
                                        title: "Total Focus Time",
                                        value: formatTime(minutes: appData.totalFocusTime),
                                        color: VolcanoTheme.moltenGold
                                    )
                                    
                                    StatisticRow(
                                        icon: "calendar",
                                        title: "Current Streak",
                                        value: "\(appData.currentStreak) days",
                                        color: VolcanoTheme.lavaOrange
                                    )
                                    
                                    StatisticRow(
                                        icon: "star.fill",
                                        title: "Momentum Sparks",
                                        value: "\(appData.totalSparks)",
                                        color: VolcanoTheme.moltenGold
                                    )
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            // Actions Section
                            VStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(VolcanoTheme.moltenGold)
                                        .font(.system(size: 20))
                                    
                                    Text("Actions")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Spacer()
                                }
                                
                                Button("Reset All Progress") {
                                    showingResetAlert = true
                                }
                                .buttonStyle(DestructiveButtonStyle())
                            }
                            .padding(.horizontal, 25)
                            
                            // Motivational Quote
                            VStack(spacing: 15) {
                                Image(systemName: "quote.bubble.fill")
                                    .foregroundColor(VolcanoTheme.moltenGold)
                                    .font(.system(size: 24))
                                
                                Text("\"The secret of getting ahead is getting started. Every expert was once a beginner.\"")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(VolcanoTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .padding(.horizontal, 30)
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
        .onAppear {
            animationOffset = 1.0
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appData.resetProgress()
            }
        } message: {
            Text("This will permanently delete all your progress, including focus sessions, achievements, and sparks. This action cannot be undone.")
        }
    }
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(VolcanoTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(VolcanoTheme.secondaryBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
