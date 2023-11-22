//
//  AudioPlayer.swift
//  NSPureDOOM
//
//  Created by Nadia on 19/11/2023.
//

import Foundation
import AudioToolbox

class AudioPlayer {
    var audioUnit: AudioUnit?
    
    var callback: ((Int) -> (data: UnsafeMutablePointer<Int16>, length: Int))? = nil
    private let renderCallback: AURenderCallback
    
    init() {
        var status = noErr
        
        var desc = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_DefaultOutput,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        guard let component = AudioComponentFindNext(nil, &desc) else {
            fatalError("Could not find audio component.")
        }
        
        status = AudioComponentInstanceNew(component, &audioUnit)
        
        guard let audioUnit else { fatalError("Couldn't create AudioUnit") }
        
        var outFormat = AudioStreamBasicDescription()
        var outSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        
        AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, &outSize)
        outFormat.mSampleRate = 11025.0
        outFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger
        outFormat.mBytesPerFrame = 4
        outFormat.mChannelsPerFrame = 2
        outFormat.mBitsPerChannel = 16
        
        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        guard status == noErr else { fatalError("shit! \(status)") }
        
        self.renderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
            let player = Unmanaged<AudioPlayer>.fromOpaque(inRefCon).takeUnretainedValue()
            
            guard let ioData else { return -1 }
            
            let bufs = UnsafeMutableAudioBufferListPointer(&ioData.pointee)
            let data1 = UnsafeMutablePointer<Int16>(OpaquePointer(bufs[0].mData))!
                
            if let cb = player.callback {
                let (samples, length) = cb(Int(bufs[0].mDataByteSize / 2))
                data1.initialize(from: samples, count: length)
            }
            
            return noErr
        }
        
        var callback = AURenderCallbackStruct(inputProc: renderCallback, inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callback, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        
        status = AudioUnitInitialize(audioUnit)
        guard status == noErr else { fatalError("Initializing AudioUnit failed") }
        status = AudioOutputUnitStart(audioUnit)
        guard status == noErr else { fatalError("Couldn't start AudioUnit") }
    }
    
    deinit {
        if let audioUnit {
            AudioOutputUnitStop(audioUnit)
            AudioUnitUninitialize(audioUnit)
            AudioComponentInstanceDispose(audioUnit)
        }
    }
}
