//
//  FrequencySlider.swift
//  Sonic Speaker Unclogger
//
//  Created by Guilherme Carvalho on 18/10/23.
//

import SwiftUI

struct FreqButton: View {
    let freq: Float
    @EnvironmentObject var synth: Synth
    
    var body: some View {
        Button(action: {() in synth.frequency = freq}, label: {
            Text("\(Int(freq))Hz")
                .foregroundColor(.blue)
        })
        .padding(4)
        .padding(.horizontal, 6)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.25))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue)
            }
        )
        .zIndex(20)
    }
}

struct FrequencySlider: View {
    @EnvironmentObject var synth: Synth
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                FreqButton(freq: 165)
                
                Text("~good for water")
                    .font(.footnote)
                    .opacity(0.25)
                
                Spacer()
                
                Text("\(Int(synth.frequency))Hz")
                    .font(.system(size: 24))
                
                Spacer()
                
                
                Text("~good for dirt")
                    .font(.footnote)
                    .opacity(0.25)
                FreqButton(freq: 6000)
            }.padding(.bottom, 10)
            Slider(
                value: $synth.frequency, in: 1...6400, step: 1,
                label: {Text("Frequency")}
            )
        }
    }
}
