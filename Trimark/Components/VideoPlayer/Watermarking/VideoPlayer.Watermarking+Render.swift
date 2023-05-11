//
//  VideoPlayer.Watermarking+Render.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

import MetalKit

extension VideoPlayer.Watermarking {
    class Render: NSObject {
        weak var view: MTKView?
        
        let device: MTLDevice
        let queue: MTLCommandQueue
        let pipelineState: MTLComputePipelineState
        let texture: MTLTexture

        var time: TimeInterval = 0
        var timer: Float = 0
        var speed: Float = 0
        var intensity: Float = 200
        
        var timerBuffer: MTLBuffer
        var intensityBuffer: MTLBuffer
        var speedBuffer: MTLBuffer
        
        init?(
            metalView: MTKView,
            image: UIImage? = UIImage(named: "watermark")
        ) {
            // For demo purposes only objects are being created here
            // that should be managed at an app level. (like the device)
            guard let device = MTLCreateSystemDefaultDevice(),
                  let queue = device.makeCommandQueue(),
                  let library = device.makeDefaultLibrary(),
                  let kernel = library.makeFunction(name: "computeWaterDance"),
                  let pipelineState = try? device.makeComputePipelineState(function: kernel),
                  let cgImage = image?.cgImage
            else {
                return nil
            }
            
            self.view = metalView
            self.device = device
            self.queue = queue
            self.pipelineState = pipelineState
            
            let textureLoader = MTKTextureLoader(device: device)
            guard let texture = try? textureLoader.newTexture(cgImage: cgImage) else {
                return nil
            }
            
            self.texture = texture
            
            guard let timerBuffer = device.makeBuffer(length: MemoryLayout<Float>.size),
                  let speedBuffer = device.makeBuffer(length: MemoryLayout<Float>.size),
                  let intensityBuffer = device.makeBuffer(length: MemoryLayout<Float>.size)
            else { return nil }

            self.timerBuffer = timerBuffer
            self.speedBuffer = speedBuffer
            self.intensityBuffer = intensityBuffer
            
            super.init()
            
            view?.framebufferOnly = false
            view?.delegate = self
            view?.device = device
        }
        
        private func updateWithTimeStep(_ step: TimeInterval) {
            time += step
            timer = Float(time)
            
            let bufferPointer = timerBuffer.contents()
            memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
        }
    }
}

extension VideoPlayer.Watermarking.Render: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // not being used in this app
    }
    
    func draw(in metalView: MTKView) {
        guard let view = view, let drawable = view.currentDrawable
        else {
            return
        }
        
        let commandBuffer = queue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(pipelineState)
        
        metalView.framebufferOnly = false
        
        commandEncoder?.setTexture(drawable.texture, index: 0)
        commandEncoder?.setTexture(texture, index: 1)
        commandEncoder?.setBuffer(timerBuffer, offset: 0, index: 0)
        
        let timeStep = 1.0 / TimeInterval(view.preferredFramesPerSecond)
        updateWithTimeStep(timeStep)
        
        commandEncoder?.setBuffer(speedBuffer, offset: 0, index: 1)
        commandEncoder?.setBytes(&speed, length: MemoryLayout<Float>.size, index: 1)
        
        commandEncoder?.setBuffer(intensityBuffer, offset: 0, index: 2)
        commandEncoder?.setBytes(&intensity, length: MemoryLayout<Float>.size, index: 2)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(
            drawable.texture.width / threadGroupCount.width,
            drawable.texture.height / threadGroupCount.height,
            1
        )
        
        commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
