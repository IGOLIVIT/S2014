//
//  GoalsView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddGoal = false
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
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(VolcanoTheme.lavaOrange.opacity(0.2))
                                .frame(width: CGFloat.random(in: 2...5))
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
                        
                        VStack(spacing: 25) {
                            Group {
                                if appData.goals.isEmpty {
                                    // Empty state
                                    VStack(spacing: 30) {
                                        Spacer()
                                        
                                        Image(systemName: "target")
                                            .font(.system(size: 80))
                                            .foregroundColor(VolcanoTheme.lavaOrange)
                                        
                                        VStack(spacing: 15) {
                                        Text("Create Your First Goal")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(VolcanoTheme.textPrimary)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Define what you want to achieve and start focusing on results")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(VolcanoTheme.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                        }
                                        
                                        Button("Create Goal") {
                                            showingAddGoal = true
                                        }
                                        .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                                        
                                        Spacer()
                                    }
                                } else {
                                    // Goals list
                                    LazyVStack(spacing: 20) {
                                        ForEach(appData.goals) { goal in
                                            GoalCard(goal: goal, appData: appData)
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.top, 20)
                                }
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
            .background(VolcanoTheme.primaryBackground)
            .navigationTitle("My Goals")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()
                }
                .foregroundColor(VolcanoTheme.moltenGold)
                .font(.system(size: 16, weight: .semibold)),
                
                trailing: !appData.goals.isEmpty ? 
                Button(action: { showingAddGoal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(VolcanoTheme.lavaOrange)
                } : nil
            )
        }
        .onAppear {
            animationOffset = 1.0
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(appData: appData)
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    @ObservedObject var appData: AppData
    @State private var showingEditGoal = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(VolcanoTheme.textPrimary)
                        .lineLimit(2)
                    
                    if !goal.description.isEmpty {
                        Text(goal.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(VolcanoTheme.textSecondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(VolcanoTheme.moltenGold)
                    } else {
                        Text("\(goal.completedSessions)/\(goal.targetSessions)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(VolcanoTheme.lavaOrange)
                    }
                    
                    Text(goal.isCompleted ? "Completed" : "Sessions")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(VolcanoTheme.textSecondary)
                }
            }
            
            // Progress bar
            if !goal.isCompleted {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(VolcanoTheme.secondaryBackground)
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * goal.progressPercentage, height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut(duration: 0.5), value: goal.progressPercentage)
                    }
                }
                .frame(height: 6)
            }
            
            // Action buttons
            HStack(spacing: 15) {
                Button("Edit") {
                    showingEditGoal = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(VolcanoTheme.moltenGold)
                
                Spacer()
                
                Button("Delete") {
                    showingDeleteAlert = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(VolcanoTheme.secondaryBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            goal.isCompleted ? VolcanoTheme.moltenGold.opacity(0.5) : VolcanoTheme.lavaOrange.opacity(0.3),
                            lineWidth: goal.isCompleted ? 2 : 1
                        )
                )
        )
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(goal: goal, appData: appData)
        }
        .alert("Delete Goal", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appData.deleteGoal(goal)
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
    }
}

struct AddGoalView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var targetSessions = 5
    
    var body: some View {
        NavigationView {
            ZStack {
                VolcanoTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(VolcanoTheme.lavaOrange)
                            
                            Text("New Goal")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Goal Title")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                TextField("e.g., Learn Swift", text: $title)
                                    .textFieldStyle(VolcanoTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description (optional)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                TextField("Goal details...", text: $description)
                                    .textFieldStyle(VolcanoTextFieldStyle())
                                    .lineLimit(3)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sessions needed to complete")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                HStack {
                                    Button("-") {
                                        if targetSessions > 1 {
                                            targetSessions -= 1
                                        }
                                    }
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(VolcanoTheme.secondaryBackground)
                                    )
                                    
                                    Spacer()
                                    
                                    Text("\(targetSessions)")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button("+") {
                                        if targetSessions < 100 {
                                            targetSessions += 1
                                        }
                                    }
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(VolcanoTheme.secondaryBackground)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(VolcanoTheme.secondaryBackground.opacity(0.3))
                                )
                            }
                            
                            Button("Create Goal") {
                                let newGoal = Goal(
                                    title: title,
                                    description: description,
                                    targetSessions: targetSessions
                                )
                                appData.addGoal(newGoal)
                                dismiss()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 25)
                        
                        Spacer()
                    }
                }
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
    }
}

struct EditGoalView: View {
    let goal: Goal
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var targetSessions = 5
    
    var body: some View {
        NavigationView {
            ZStack {
                VolcanoTheme.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(VolcanoTheme.moltenGold)
                            
                            Text("Edit Goal")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(VolcanoTheme.textPrimary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Название цели")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                TextField("Название цели", text: $title)
                                    .textFieldStyle(VolcanoTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Описание")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                TextField("Описание цели", text: $description)
                                    .textFieldStyle(VolcanoTextFieldStyle())
                                    .lineLimit(3)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sessions needed to complete")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VolcanoTheme.textPrimary)
                                
                                HStack {
                                    Button("-") {
                                        if targetSessions > max(1, goal.completedSessions) {
                                            targetSessions -= 1
                                        }
                                    }
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(VolcanoTheme.secondaryBackground)
                                    )
                                    
                                    Spacer()
                                    
                                    Text("\(targetSessions)")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(VolcanoTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button("+") {
                                        if targetSessions < 100 {
                                            targetSessions += 1
                                        }
                                    }
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(VolcanoTheme.lavaOrange)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(VolcanoTheme.secondaryBackground)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(VolcanoTheme.secondaryBackground.opacity(0.3))
                                )
                                
                                if goal.completedSessions > 0 {
                                    Text("Minimum: \(goal.completedSessions) (already completed)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(VolcanoTheme.textSecondary)
                                }
                            }
                            
                            Button("Save Changes") {
                                var updatedGoal = goal
                                updatedGoal.title = title
                                updatedGoal.description = description
                                updatedGoal.targetSessions = targetSessions
                                if updatedGoal.completedSessions >= updatedGoal.targetSessions {
                                    updatedGoal.isCompleted = true
                                } else {
                                    updatedGoal.isCompleted = false
                                }
                                appData.updateGoal(updatedGoal)
                                dismiss()
                            }
                            .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 25)
                        
                        Spacer()
                    }
                }
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
            title = goal.title
            description = goal.description
            targetSessions = goal.targetSessions
        }
    }
}
