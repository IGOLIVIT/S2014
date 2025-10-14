//
//  AppData.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Data Models
struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool = false
    var completedSessions: Int = 0
    var targetSessions: Int = 1
    var createdDate: Date = Date()
    
    init(title: String, description: String = "", targetSessions: Int = 1) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetSessions = targetSessions
    }
    
    var progressPercentage: Double {
        guard targetSessions > 0 else { return 0 }
        return min(Double(completedSessions) / Double(targetSessions), 1.0)
    }
}

class AppData: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var totalFocusTime: Int = 0 // in minutes
    @Published var totalSessions: Int = 0
    @Published var totalSparks: Int = 0
    @Published var currentStreak: Int = 0
    @Published var goals: [Goal] = []
    @Published var lastSessionDate: Date?
    @Published var defaultTimerDuration: Int = 25 // in minutes
    
    init() {
        loadData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveData()
    }
    
    func completeFocusSession(minutes: Int, goalId: UUID? = nil) {
        totalFocusTime += minutes
        totalSessions += 1
        totalSparks += 1
        
        // Update specific goal if provided
        if let goalId = goalId,
           let goalIndex = goals.firstIndex(where: { $0.id == goalId }) {
            goals[goalIndex].completedSessions += 1
            if goals[goalIndex].completedSessions >= goals[goalIndex].targetSessions {
                goals[goalIndex].isCompleted = true
            }
        }
        
        updateStreak()
        saveData()
    }
    
    func addSparks(_ count: Int) {
        totalSparks += count
        saveData()
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func setTimerDuration(_ minutes: Int) {
        defaultTimerDuration = minutes
        saveData()
    }
    
    func resetProgress() {
        totalFocusTime = 0
        totalSessions = 0
        totalSparks = 0
        currentStreak = 0
        goals = []
        lastSessionDate = nil
        defaultTimerDuration = 25
        saveData()
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastSessionDate {
            let lastSessionDay = Calendar.current.startOfDay(for: lastDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastSessionDate = Date()
    }
    
    private func saveData() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(totalFocusTime, forKey: "totalFocusTime")
        UserDefaults.standard.set(totalSessions, forKey: "totalSessions")
        UserDefaults.standard.set(totalSparks, forKey: "totalSparks")
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(defaultTimerDuration, forKey: "defaultTimerDuration")
        
        // Save goals as JSON
        if let goalsData = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(goalsData, forKey: "goals")
        }
        
        if let lastSessionDate = lastSessionDate {
            UserDefaults.standard.set(lastSessionDate, forKey: "lastSessionDate")
        }
    }
    
    private func loadData() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        totalFocusTime = UserDefaults.standard.integer(forKey: "totalFocusTime")
        totalSessions = UserDefaults.standard.integer(forKey: "totalSessions")
        totalSparks = UserDefaults.standard.integer(forKey: "totalSparks")
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        defaultTimerDuration = UserDefaults.standard.integer(forKey: "defaultTimerDuration")
        if defaultTimerDuration == 0 { defaultTimerDuration = 25 } // Default value
        
        // Load goals from JSON
        if let goalsData = UserDefaults.standard.data(forKey: "goals"),
           let loadedGoals = try? JSONDecoder().decode([Goal].self, from: goalsData) {
            goals = loadedGoals
        }
        
        lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date
    }
}

// MARK: - Theme Colors
struct VolcanoTheme {
    static let primaryBackground = Color(red: 0.102, green: 0.055, blue: 0.043) // #1A0E0B
    static let secondaryBackground = Color(red: 0.231, green: 0.122, blue: 0.071) // #3B1F12
    static let lavaOrange = Color(red: 1.0, green: 0.271, blue: 0.0) // #FF4500
    static let moltenGold = Color(red: 1.0, green: 0.843, blue: 0.0) // #FFD700
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.98, green: 0.863, blue: 0.627) // #FADCA0
}
