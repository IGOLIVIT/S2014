//
//  OnboardingView.swift
//  IgniteFlow
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appData: AppData
    @State private var currentSlide = 0
    @State private var animationOffset: CGFloat = 0
    
    private let slides = [
        OnboardingSlide(
            title: "Ignite Your Drive",
            subtitle: "Transform your potential into unstoppable momentum",
            imageName: "flame.fill",
            description: "Every great achievement starts with a single spark of motivation"
        ),
        OnboardingSlide(
            title: "Track Your Progress",
            subtitle: "Build consistency through daily focus sessions",
            imageName: "chart.line.uptrend.xyaxis",
            description: "Watch your dedication compound into extraordinary results"
        ),
        OnboardingSlide(
            title: "Master Your Flow",
            subtitle: "Enter the zone where peak performance lives",
            imageName: "bolt.fill",
            description: "Unlock your highest potential through focused action"
        )
    ]
    
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
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationOffset)
                
                // Floating particles effect
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(VolcanoTheme.lavaOrange.opacity(0.3))
                        .frame(width: CGFloat.random(in: 2...6))
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
                
                VStack(spacing: 0) {
                    // Main content
                    TabView(selection: $currentSlide) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            SlideView(slide: slides[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentSlide)
                    
                    // Bottom section
                    VStack(spacing: 30) {
                        // Page indicators
                        HStack(spacing: 12) {
                            ForEach(0..<slides.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentSlide ? VolcanoTheme.moltenGold : VolcanoTheme.textSecondary.opacity(0.3))
                                    .frame(width: 10, height: 10)
                                    .scaleEffect(index == currentSlide ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: currentSlide)
                            }
                        }
                        
                        // Navigation buttons
                        HStack(spacing: 20) {
                            if currentSlide < slides.count - 1 {
                                Button("Next") {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        currentSlide += 1
                                    }
                                }
                                .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                            } else {
                                Button("Get Started") {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        appData.completeOnboarding()
                                    }
                                }
                                .buttonStyle(VolcanoButtonStyle(isPrimary: true))
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            animationOffset = 1.0
        }
    }
}

struct SlideView: View {
    let slide: OnboardingSlide
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: slide.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(VolcanoTheme.lavaOrange)
                .scaleEffect(isVisible ? 1.0 : 0.5)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isVisible)
            
            VStack(spacing: 20) {
                // Title
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(VolcanoTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .offset(y: isVisible ? 0 : 50)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isVisible)
                
                // Subtitle
                Text(slide.subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(VolcanoTheme.moltenGold)
                    .multilineTextAlignment(.center)
                    .offset(y: isVisible ? 0 : 30)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: isVisible)
                
                // Description
                Text(slide.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(VolcanoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .offset(y: isVisible ? 0 : 20)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: isVisible)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct OnboardingSlide {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}

// MARK: - Custom Button Style
struct VolcanoButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(isPrimary ? VolcanoTheme.primaryBackground : VolcanoTheme.textPrimary)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        isPrimary ? 
                        LinearGradient(colors: [VolcanoTheme.lavaOrange, VolcanoTheme.moltenGold], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [VolcanoTheme.secondaryBackground], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: isPrimary ? VolcanoTheme.lavaOrange.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


