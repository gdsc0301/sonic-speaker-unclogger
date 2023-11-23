//
//  Synth.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import AVFoundation

class Synth: ObservableObject {
    let audioEngine: AVAudioEngine
    let mainMixer: AVAudioMixerNode
    let outputNode: AVAudioOutputNode
    
    var time: Float = 0
    let sampleRate: Double
    let deltaTime: Float
    
    let waves: [Waveform] = [.sine, .triangle, .sawtooth, .square, .whiteNoise]
    
    var signal: Signal
    @Published var waveform: Waveform = .sine {
        didSet {
            switch waveform {
                case .sine: signal = Oscillator.sine
                case .triangle: signal = Oscillator.triangle
                case .sawtooth: signal = Oscillator.sawtooth
                case .square: signal = Oscillator.square
                case .whiteNoise: signal = Oscillator.whiteNoise
            }
        }
    }
    
    var frequencyRampValue: Float = 0
    
    @Published var frequency: Float = 165.0 {
        didSet {
            if oldValue != 0 {
                frequencyRampValue = frequency - oldValue
            } else {
                frequencyRampValue = 0
            }
        }
    }
    
    func isPlaying() -> Bool {
        audioEngine.mainMixerNode.outputVolume > 0
    }
    
    @Published var volume: Float = 0 {
        didSet {
            setVolume(volume)
        }
    }
    private func setVolume(_ volume: Float) {
        mainMixer.outputVolume = volume
    }
    
    // Changes the speaker that will play the sound
    @Published var pan: Double = 0 {
        didSet {
            sourceNode.pan = Float(pan)
        }
    }

    var sourceNode: AVAudioSourceNode = AVAudioSourceNode(renderBlock: {(_,_,_,_) -> OSStatus in noErr})
    func audioSourceRenderBlock(
        isSilent: UnsafeMutablePointer<ObjCBool>,
        timestamp: UnsafePointer<AudioTimeStamp>,
        frameCount: AVAudioFrameCount,
        audioBufferList: UnsafeMutablePointer<AudioBufferList>
    ) -> OSStatus {
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        let localFrequency = self.frequency - self.frequencyRampValue
        
        let period = 1 / localFrequency

        for frame in 0..<Int(frameCount) {
            let percentComplete = time / period
            let sampleVal = signal(localFrequency + self.frequencyRampValue * percentComplete, time)
            time += deltaTime
            time = fmod(time, period)
            
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        
        frequencyRampValue = 0
        
        return noErr
    }
    
    // Init
    init() {
        audioEngine = AVAudioEngine()
        mainMixer = audioEngine.mainMixerNode
        outputNode = audioEngine.outputNode
        
        signal = Oscillator.sine
        
        let format = outputNode.inputFormat(forBus: 0)
        sampleRate = format.sampleRate
        
        deltaTime = 1 / Float(format.sampleRate)
        
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
                                        sampleRate: format.sampleRate,
                                        channels: 1,
                                        interleaved: format.isInterleaved)
        
        sourceNode = AVAudioSourceNode(renderBlock: audioSourceRenderBlock)
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: Public Functions
    public func setWaveformTo(_ waveform: Waveform) {
    }
}
