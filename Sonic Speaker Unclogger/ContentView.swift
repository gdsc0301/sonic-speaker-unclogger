//
//  ContentView.swift
//
//  Created by Guilherme Carvalho on 02/10/23.
//

import SwiftUI
import CoreAudio
import AudioToolbox
import AVFAudio

struct ContentView: View {
    @StateObject var synth = Synth()
    
    var body: some View {
        VStack(
            alignment: .center,
            content: {
                VStack(spacing: 24) {
                    Button(action: {() in synth.volume = 1}, label: {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                        Text("Play\(synth.isPlaying() ? "ing" : "")")
                            .multilineTextAlignment(.center)
                    })
                    .animation(.easeInOut, value: synth.volume)
                    .opacity(synth.isPlaying() ? 0.5 : 1)
                    .disabled(synth.isPlaying())
                    
                    WaveformSelect()
                }
            
                Spacer()
                
                FrequencySlider()
                
                VStack(spacing: 0) {
                    Slider(
                        value: $synth.pan, in: -1...1, step: 0.01,
                        label: {Text("Pan")},
                        minimumValueLabel: {Text("Left")},
                        maximumValueLabel: {Text("Right")}
                    )
                    Text("Choose the speaker")
                        .font(.system(size: 14))
                        .opacity(0.5)
                }
                                
                Spacer()
                Button(action: {() in synth.volume = 0}, label: {
                    Image(systemName: "stop.circle.fill")
                        .foregroundColor(synth.isPlaying() ? .red : .gray)
                    Text("Stop")
                        .multilineTextAlignment(.center)
                        .foregroundColor(synth.isPlaying() ? .red : .gray)
                })
                .animation(.easeInOut, value: synth.volume)
                .opacity(synth.isPlaying() ? 1 : 0.5)
                .disabled(!synth.isPlaying())
            }
        )
        // adjusts the padding to prevent the notch space in a landscape iPhone
        .padding(.leading, (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 16)
        .padding(.trailing, UIApplication.shared.windows.first?.safeAreaInsets.right)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 16)
        .background(RadialGradient(
            // adapts the orange to the dark and light theme
            gradient: Gradient(colors: [
                Color(UIColor.systemTeal).opacity(0.64),
                Color(UIColor.systemTeal).opacity(min(1, 0.1 + Double(synth.frequency / 6400)))
            ]),
//            gradient: Gradient(colors: [.white, Color.orange.opacity(min(1, 0.3 + Double(synth.frequency / 6400)))]),
            center: UnitPoint(x: CGFloat(((synth.pan) + 1) / 2), y: 0.5),
            startRadius: 1,
            // Half the screen size
            endRadius: UIScreen.main.bounds.width/2
        ))
        .ignoresSafeArea(.all)
        .environmentObject(synth)
    }
}

#Preview {
    ContentView()
}

