//
//  WaveformSelect.swift
//  Sonic Speaker Unclogger
//
//  Created by Guilherme Carvalho on 25/10/23.
//

import SwiftUI

struct WaveformSelect: View {
    @EnvironmentObject var synth: Synth
    
    var body: some View {
        HStack {
            // Buttons for each waveform
            ForEach(synth.waves, id: \.self) { wave in
                Button(action: {
                    synth.waveform = wave
                }) {
                    Text(String(wave.rawValue).capitalized)
                        // Text color
                        .foregroundColor(synth.waveform == wave ? .blue : .white)
                        .font(.system(size: 14))
                        .padding(5)
                }
                // Highlight the current waveform
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(synth.waveform == wave ? Color.white : Color.blue)
                        .frame(minWidth: 80)
                ).frame(minWidth: 80)
            }
        }
    }
}
