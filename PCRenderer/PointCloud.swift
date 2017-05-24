//
//  PointCloud.swift
//  MixedReality
//
//  Created by Evgeniy Upenik on 21.05.17.
//  Copyright © 2017 Evgeniy Upenik. All rights reserved.
//

import SceneKit

@objc class PointCloud: NSObject {
    
    var n : Int = 0
    var pointCloud : Array<SCNVector3> = []
    
    override init() {
        super.init()
        
        let file: String = "bun_zipper_points.ply"
        self.n = 0
        var x, y, z : Double
        (x,y,z) = (0,0,0)
        
        // Open file
        if let path = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .ascii)
                var myStrings = data.components(separatedBy: "\n")
                
                // Read header
                while !myStrings.isEmpty {
                    let line = myStrings.removeFirst()
                    if line.hasPrefix("element vertex ") {
                        n = Int(line.components(separatedBy: " ")[2])!
                        continue
                    }
                    if line.hasPrefix("end_header") {
                        break
                    }
                }
                
                pointCloud = Array<SCNVector3>(repeating: SCNVector3(x:0,y:0,z:0), count: n)
                
                // Read data
                for i in 0...(self.n-1) {
                    let line = myStrings[i]
                    x = Double(line.components(separatedBy: " ")[0])!
                    y = Double(line.components(separatedBy: " ")[1])!
                    z = Double(line.components(separatedBy: " ")[2])!
                    
                    pointCloud[i].x = Float(x)
                    pointCloud[i].y = Float(y)
                    pointCloud[i].z = Float(z)
                }
                NSLog("Point cloud data loaded: %d points",n)
            } catch {
                print(error)
            }
        }
        
    }
    
    
    public func getNode() -> SCNNode {
        let points = self.pointCloud
        var vertices = Array(repeating: PointCloudVertex(x: 0,y: 0,z: 0,r: 0,g: 0,b: 0), count: points.count)
        
        for i in 0...(points.count-1) {
            let p = points[i]
            vertices[i].x = Float(p.x)
            vertices[i].y = Float(p.y)
            vertices[i].z = Float(p.z)
            vertices[i].r = Float(0.0)
            vertices[i].g = Float(1.0)
            vertices[i].b = Float(1.0)
        }
        
        let node = buildNode(points: vertices)
        NSLog(String(describing: node))
        return node
    }
    
    private func buildNode(points: [PointCloudVertex]) -> SCNNode {
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [elements])
        
        return SCNNode(geometry: pointsGeometry)
    }
}
