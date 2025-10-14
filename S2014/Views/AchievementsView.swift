//
//  AchievementsView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var animationOffset: CGFloat = 0
    
    private var achievements: [Achievement] {
        [
            Achievement(
                title: "First Spark",
                description: "Complete your first focus session",
                iconName: "flame.fill",
                isUnlocked: appData.totalSessions >= 1,
                requirement: "1 session",
                progress: min(appData.totalSessions, 1),
                maxProgress: 1
            ),
            Achievement(
                title: "Momentum Builder",
                description: "Complete 5 focus sessions",
                iconName: "bolt.fill",
                isUnlocked: appData.totalSessions >= 5,
                requirement: "5 sessions",
                progress: min(appData.totalSessions, 5),
                maxProgress: 5
            ),
            Achievement(
                title: "Focus Master",
                description: "Complete 25 focus sessions",
                iconName: "target",
                isUnlocked: appData.totalSessions >= 25,
                requirement: "25 sessions",
                progress: min(appData.totalSessions, 25),
                maxProgress: 25
            ),
            Achievement(
                title: "Time Warrior",
                description: "Focus for 5 hours total",
                iconName: "clock.fill",
                isUnlocked: appData.totalFocusTime >= 300,
                requirement: "5 hours",
                progress: min(appData.totalFocusTime, 300),
                maxProgress: 300
            ),
            Achievement(
                title: "Streak Champion",
                description: "Maintain a 7-day streak",
                iconName: "calendar",
                isUnlocked: appData.currentStreak >= 7,
                requirement: "7 days",
                progress: min(appData.currentStreak, 7),
                maxProgress: 7
            ),
            Achievement(
                title: "Spark Collector",
                description: "Collect 100 Momentum Sparks",
                iconName: "star.fill",
                isUnlocked: appData.totalSparks >= 100,
                requirement: "100 sparks",
                progress: min(appData.totalSparks, 100),
                maxProgress: 100
            )
        ]
    }
    
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
                        ForEach(0..<10, id: \.self) { index in
                            Circle()
                                .fill(VolcanoTheme.moltenGold.opacity(0.3))
                                .frame(width: CGFloat.random(in: 2...5))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                                .animation(
                                    .easeInOut(duration: Double.random(in: 3...6))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...2)),
                                    value: animationOffset
                                )
                        }
                        
                        VStack(spacing: 25) {
                            // Header Stats
                            VStack(spacing: 20) {
                                HStack(spacing: 30) {
                                    StatCard(
                                        title: "Sessions",
                                        value: "\(appData.totalSessions)",
                                        icon: "flame.fill",
                                        color: VolcanoTheme.lavaOrange
                                    )
                                    
                                    StatCard(
                                        title: "Focus Time",
                                        value: "\(appData.totalFocusTime)m",
                                        icon: "clock.fill",
                                        color: VolcanoTheme.moltenGold
                                    )
                                }
                                
                                HStack(spacing: 30) {
                                    StatCard(
                                        title: "Streak",
                                        value: "\(appData.currentStreak)",
                                        icon: "calendar",
                                        color: VolcanoTheme.lavaOrange
                                    )
                                    
                                    StatCard(
                                        title: "Sparks",
                                        value: "\(appData.totalSparks)",
                                        icon: "star.fill",
                                        color: VolcanoTheme.moltenGold
                                    )
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                            
                            // Achievements Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 15),
                                GridItem(.flexible(), spacing: 15)
                            ], spacing: 20) {
                                ForEach(achievements.indices, id: \.self) { index in
                                    AchievementCard(achievement: achievements[index])
                                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animationOffset)
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            Spacer(minLength: 30)
                        }
                    }
                }
            }
            .background(VolcanoTheme.primaryBackground)
            .navigationTitle("Achievements")
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
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(VolcanoTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(VolcanoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(VolcanoTheme.secondaryBackground.opacity(0.6))
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [VolcanoTheme.secondaryBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: achievement.isUnlocked ? VolcanoTheme.lavaOrange.opacity(0.5) : .clear, radius: isGlowing ? 15 : 5)
                    .scaleEffect(isGlowing && achievement.isUnlocked ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? VolcanoTheme.primaryBackground : VolcanoTheme.textSecondary)
            }
            
            // Content
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? VolcanoTheme.textPrimary : VolcanoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(VolcanoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Progress bar
                if !achievement.isUnlocked {
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(VolcanoTheme.secondaryBackground)
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(VolcanoTheme.lavaOrange)
                                    .frame(width: geometry.size.width * (Double(achievement.progress) / Double(achievement.maxProgress)), height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.5), value: achievement.progress)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(achievement.progress)/\(achievement.maxProgress)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(VolcanoTheme.textSecondary)
                    }
                } else {
                    Text("UNLOCKED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(VolcanoTheme.moltenGold)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(VolcanoTheme.secondaryBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            achievement.isUnlocked ? VolcanoTheme.lavaOrange.opacity(0.5) : VolcanoTheme.secondaryBackground,
                            lineWidth: achievement.isUnlocked ? 2 : 1
                        )
                )
        )
        .onAppear {
            if achievement.isUnlocked {
                isGlowing = true
            }
        }
    }
}

struct Achievement {
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: Bool
    let requirement: String
    let progress: Int
    let maxProgress: Int
}
