//
//  ConnectLineView.swift
//  JXPatternLock
//
//  Created by jiaxin on 2019/6/25.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import Foundation

open class ConnectLineView: UIView, ConnectLine {
    public var lineNormalColor: UIColor = UIColor.lightGray
    public var lineErrorColor: UIColor = UIColor.red
    public let line: CAShapeLayer = CAShapeLayer()
    private var currentPoint: CGPoint?
    private var connectedGridViews: [PatternLockGrid]?
    public var isTriangleHidden: Bool = false {
        didSet {
            triangles.forEach { $0.isHidden = isTriangleHidden }
        }
    }
    public var triangleNormalColor: UIColor = UIColor.lightGray
    public var triangleErrorColor: UIColor = UIColor.red
    public var triangleOffset: CGFloat = 20
    //   /\    -
    //  /  \   height
    //  ----   -
    // | width |
    public var triangleHeight: CGFloat = 8
    public var triangleWidth: CGFloat = 15
    private var triangles: [CAShapeLayer] = [CAShapeLayer]()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        line.fillColor = nil
        layer.addSublayer(line)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setStatus(_ status: ConnectLineStatus) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        switch status {
            case .normal:
                line.strokeColor = lineNormalColor.cgColor
                if !isTriangleHidden {
                    triangles.forEach { $0.fillColor = triangleNormalColor.cgColor }
                }
            case .error:
                currentPoint = nil
                drawLine()
                line.strokeColor = lineErrorColor.cgColor
                if !isTriangleHidden {
                    triangles.forEach { $0.fillColor = triangleErrorColor.cgColor }
                }
        }
        CATransaction.commit()
    }

    public func appendPoint(_ point: CGPoint, connectedGridViews: [PatternLockGrid]) {
        currentPoint = point
        self.connectedGridViews = connectedGridViews
        drawLine()
    }

    public func reset() {
        currentPoint = nil
        line.path = nil
        triangles.forEach { $0.removeFromSuperlayer() }
        triangles.removeAll()
        setStatus(.normal)
    }

    func drawLine() {
        guard connectedGridViews?.isEmpty == false else {
            return
        }
        if !isTriangleHidden {
            triangles.forEach { $0.removeFromSuperlayer() }
            triangles.removeAll()
        }
        let path = UIBezierPath()
        for (index, gridView) in connectedGridViews!.enumerated() {
            if index == 0 {
                path.move(to: gridView.center)
            }else {
                path.addLine(to: gridView.center)
            }
            if !isTriangleHidden {
                if connectedGridViews!.count - 1 == index && currentPoint != nil {
                    //最后一个
                    addTriangle(from: gridView.center, to: currentPoint!)
                }else if connectedGridViews!.count > index + 1  {
                    let nextGridView = connectedGridViews![index + 1]
                    addTriangle(from: gridView.center, to: nextGridView.center)
                }
            }

        }
        if currentPoint != nil {
            path.addLine(to: currentPoint!)
        }
        line.path = path.cgPath
    }

    private func addTriangle(from: CGPoint, to: CGPoint) {
        let triangle = CAShapeLayer()
        triangle.frame = CGRect(x: from.x, y: from.y - triangleWidth/2, width: triangleOffset + triangleHeight, height: triangleWidth)
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: triangleOffset, y: 0))
        trianglePath.addLine(to: CGPoint(x: triangle.bounds.width, y: triangle.bounds.height/2))
        trianglePath.addLine(to: CGPoint(x: triangleOffset, y: triangle.bounds.height))
        trianglePath.fill()
        triangle.path = trianglePath.cgPath
        triangle.anchorPoint = CGPoint(x: 0, y: 0.5)
        triangle.frame.origin.x -= triangle.bounds.width/2
        triangle.fillColor = triangleNormalColor.cgColor

        let xDistance = to.x - from.x
        let yDistance = to.y - from.y
        let degress = atan2(yDistance, xDistance)
        triangle.setAffineTransform(CGAffineTransform(rotationAngle: degress))
        layer.addSublayer(triangle)
        triangles.append(triangle)
    }
}
