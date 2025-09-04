//
//  Popover.swift
//  SwiftPopover
//
//  Created by LC on 2025/1/7.
//

import UIKit

public enum PopoverDirection {
    case up
    case down
    case left
    case right
}

public protocol PopoverDelegate : AnyObject {
    func willShowPopover(_ popover: Popover)
    func willDismissPopover(_ popover: Popover)
    func didShowPopover(_ popover: Popover)
    func didDismissPopover(_ popover: Popover)
}

public extension PopoverDelegate {
    func willShowPopover(_ popover: Popover) {}
    func willDismissPopover(_ popover: Popover) {}
    func didShowPopover(_ popover: Popover) {}
    func didDismissPopover(_ popover: Popover) {}
}

open class Popover: UIView {
    
    open var arrowSize: CGSize = CGSize(width: 16.0, height: 10.0)
    open var animationIn: TimeInterval = 0.6
    open var animationOut: TimeInterval = 0.3
    open var cornerRadius: CGFloat = 6.0
    open var sideEdge: CGFloat = 20.0
    open var direction: PopoverDirection?
    open var fillColor: UIColor = UIColor.white
    open var showOverlay: Bool = true
    open var springDamping: CGFloat = 0.7
    open var initialSpringVelocity: CGFloat = 3
    open var sideOffset: CGFloat = 6.0
    open weak var delegate: PopoverDelegate?
    
    public let overlayView = UIControl()
    
    fileprivate var containerView: UIView!
    fileprivate var contentViewFrame: CGRect!
    fileprivate var arrowShowPoint: CGPoint!
    fileprivate let contentView: UIView

    public init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        self.contentView.backgroundColor = UIColor.clear
        self.overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        self.backgroundColor = .clear
        self.accessibilityViewIsModal = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func show(from fromView: UIView, in inView: UIView) {
        let point: CGPoint
        
        if self.direction == nil {
            let point = inView.convert(fromView.bounds, from: fromView).origin
            if point.y + fromView.frame.height + self.arrowSize.height + contentView.frame.height > inView.frame.height {
                self.direction = .up
            } else {
                self.direction = .down
            }
        }
        
        switch self.direction! {
        case .up:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y - sideOffset
                ), from: fromView.superview)
        case .down:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y + fromView.frame.size.height + sideOffset
                ), from: fromView.superview)
        case .left:
            point = inView.convert(
                CGPoint(x: fromView.frame.origin.x - sideOffset,
                        y: fromView.frame.origin.y + 0.5 * fromView.frame.height
                       ), from: fromView.superview)
        case .right:
            point = inView.convert(
                CGPoint(x: fromView.frame.origin.x + fromView.frame.size.width + sideOffset,
                        y: fromView.frame.origin.y + 0.5 * fromView.frame.height
                       ), from: fromView.superview)
        }
                
        self.show(point: point, in: inView)
    }
    
    open func show(point: CGPoint, in inView: UIView) {
        if self.showOverlay {
            self.overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.overlayView.frame = inView.bounds
            inView.addSubview(self.overlayView)
            self.overlayView.alpha = 0
            self.overlayView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        }
        
        self.containerView = inView
        self.contentView.layer.cornerRadius = self.cornerRadius
        self.contentView.layer.masksToBounds = true
        self.arrowShowPoint = point
        self.show()
    }
    
    open override func accessibilityPerformEscape() -> Bool {
        self.dismiss()
        return true
    }
    
    @objc open func dismiss() {
        if self.superview != nil {
            delegate?.willDismissPopover(self)
            UIView.animate(withDuration: self.animationOut, delay: 0,
                           options: UIView.AnimationOptions(),
                           animations: {
                self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                self.overlayView.alpha = 0
            }){ _ in
                self.contentView.removeFromSuperview()
                self.overlayView.removeFromSuperview()
                self.removeFromSuperview()
                self.transform = CGAffineTransform.identity
                self.delegate?.didDismissPopover(self)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let direction = self.direction else {
            return
        }

        let arrow = UIBezierPath()
        let color = self.fillColor
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        switch direction {
        case .up:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: self.bounds.height))
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x - self.arrowSize.width * 0.5,
                    y: self.isCornerLeftArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
            
            arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height - self.arrowSize.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: 0))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.arrowSize.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.width * 0.5,
                    y: self.isCornerRightArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
            
        case .down:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: 0))
            
            if self.isCloseToCornerRightArrow && !self.isCornerRightArrow {
                if !isBehindCornerRightArrow {
                    arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: self.arrowSize.height))
                    arrow.addArc(
                        withCenter: CGPoint(x: self.bounds.width - self.cornerRadius, y: self.arrowSize.height + self.cornerRadius),
                        radius: self.cornerRadius,
                        startAngle: self.radians(270.0),
                        endAngle: self.radians(0),
                        clockwise: true)
                } else {
                    arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.arrowSize.height + self.cornerRadius))
                    arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.arrowSize.height))
                }
            } else {
                arrow.addLine(
                    to: CGPoint(
                        x: self.isBehindCornerLeftArrow ? self.frame.minX - self.arrowSize.width * 0.5 : arrowPoint.x + self.arrowSize.width * 0.5,
                        y: self.isCornerRightArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height
                    )
                )
                arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: self.arrowSize.height))
                arrow.addArc(
                    withCenter: CGPoint(
                        x: self.bounds.width - self.cornerRadius,
                        y: self.arrowSize.height + self.cornerRadius
                    ),
                    radius: self.cornerRadius,
                    startAngle: self.radians(270.0),
                    endAngle: self.radians(0),
                    clockwise: true)
            }
            
            arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.arrowSize.height + self.cornerRadius))
            
            if !isBehindCornerLeftArrow {
                arrow.addArc(
                    withCenter: CGPoint(
                        x: self.cornerRadius,
                        y: self.arrowSize.height + self.cornerRadius
                    ),
                    radius: self.cornerRadius,
                    startAngle: self.radians(180),
                    endAngle: self.radians(270),
                    clockwise: true)
            }
            
            if isBehindCornerRightArrow {
                arrow.addLine(to: CGPoint(
                    x: self.bounds.width - self.arrowSize.width * 0.5,
                    y: self.isCornerLeftArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height))
            } else if isCloseToCornerLeftArrow && !isCornerLeftArrow {
                () // skipping this line in that case
            } else {
                arrow.addLine(to: CGPoint(x: arrowPoint.x - self.arrowSize.width * 0.5,
                                          y: self.isCornerLeftArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height))
            }
            
        case .left:
            arrow.move(to: CGPoint(x: self.bounds.width, y: self.bounds.height * 0.5))
            arrow.addLine(
                to: CGPoint(
                    x: self.bounds.width - self.arrowSize.height,
                    y: self.bounds.height * 0.5 + self.arrowSize.width * 0.5
                ))
            
            arrow.addLine(to: CGPoint(x:self.bounds.width - self.arrowSize.height, y: self.bounds.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.arrowSize.height - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0.0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.arrowSize.height - self.cornerRadius, y: 0))
            arrow.addArc(
                withCenter: CGPoint(x: self.bounds.width - self.arrowSize.height - self.cornerRadius,
                                    y: self.cornerRadius
                                   ),
                radius: self.cornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.arrowSize.height,
                                      y: self.bounds.height * 0.5 - self.arrowSize.width * 0.5
                                     ))
        case .right:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: self.bounds.height * 0.5))
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.height,
                    y: self.bounds.height * 0.5 + 0.5 * self.arrowSize.width
                ))
            
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.height,
                    y: self.bounds.height - self.cornerRadius
                ))
            arrow.addArc(
                withCenter: CGPoint(
                    x: arrowPoint.x + self.arrowSize.height + self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180.0),
                endAngle: self.radians(90),
                clockwise: false)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width + arrowPoint.x - self.cornerRadius, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width + arrowPoint.x - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(0),
                clockwise: false)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width + arrowPoint.x, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width + arrowPoint.x - self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(-90),
                clockwise: false)
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x + self.arrowSize.height - self.cornerRadius, y: 0))
            arrow.addArc(
                withCenter: CGPoint(x: arrowPoint.x + self.arrowSize.height + self.cornerRadius,
                                    y: self.cornerRadius
                                   ),
                radius: self.cornerRadius,
                startAngle: self.radians(-90),
                endAngle: self.radians(-180),
                clockwise: false)
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x + self.arrowSize.height,
                                      y:  self.bounds.height * 0.5 - self.arrowSize.width * 0.5))
        }
        
        color.setFill()
        arrow.fill()

    }
}

private extension Popover {

    func create() {
        guard let direction = self.direction else {
            return
        }

        var frame = self.contentView.frame
        
        switch direction {
        case .up, .down:
            frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5
        case .left, .right:
            frame.origin.y = self.arrowShowPoint.y - frame.size.height * 0.5
        }
        
        var sideEdge: CGFloat = 0.0
        if frame.size.width < self.containerView.frame.size.width {
            sideEdge = self.sideEdge
        }
        
        let outerSideEdge = frame.maxX - self.containerView.bounds.size.width
        if outerSideEdge > 0 {
            frame.origin.x -= (outerSideEdge + sideEdge)
        } else {
            if frame.minX < 0 {
                frame.origin.x += abs(frame.minX) + sideEdge
            }
        }
        self.frame = frame
        
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        var anchorPoint: CGPoint
        switch direction {
        case .up:
            frame.origin.y = self.arrowShowPoint.y - frame.height - self.arrowSize.height
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 1)
        case .down:
            frame.origin.y = self.arrowShowPoint.y
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
        case .left:
            frame.origin.x = self.arrowShowPoint.x - frame.size.width - self.arrowSize.height
            anchorPoint = CGPoint(x: 1, y: 0.5)
        case .right:
            frame.origin.x = self.arrowShowPoint.x
            anchorPoint = CGPoint(x: 0, y: 0.5)
        }
        
        if self.arrowSize == .zero {
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        
        let lastAnchor = self.layer.anchorPoint
        self.layer.anchorPoint = anchorPoint
        let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width
        let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height
        self.layer.position = CGPoint(x: x, y: y)
        
        switch direction {
        case .up, .down:
            frame.size.height += self.arrowSize.height
        case .left, .right:
            frame.size.width += self.arrowSize.height
        }
        
        self.frame = frame
    }
        
    func show() {
        guard let direction = self.direction else {
#if DEBUG
            print("Please set the value of `direction`.")
#endif
            return
        }
        self.setNeedsDisplay()
        self.addSubview(self.contentView)
        self.containerView.addSubview(self)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        switch direction {
        case .up:
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
                contentView.topAnchor.constraint(equalTo: self.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.arrowSize.height)
            ])
        case .down:
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
                contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.arrowSize.height),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        case .right:
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.arrowSize.height),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
                contentView.topAnchor.constraint(equalTo: self.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        case .left:
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -self.arrowSize.height),
                contentView.topAnchor.constraint(equalTo: self.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }

        self.create()
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.delegate?.willShowPopover(self)
        UIView.animate(
            withDuration: self.animationIn,
            delay: 0,
            usingSpringWithDamping: self.springDamping,
            initialSpringVelocity: self.initialSpringVelocity,
            options: UIView.AnimationOptions(),
            animations: {
                self.transform = CGAffineTransform.identity
            }){ _ in
                self.delegate?.didShowPopover(self)
            }
        UIView.animate(
            withDuration: self.animationIn / 3,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.overlayView.alpha = 1
            }, completion: nil)
    }
    
    var isCloseToCornerLeftArrow: Bool {
        return self.arrowShowPoint.x < self.frame.origin.x + arrowSize.width/2 + cornerRadius
    }
    
    var isCloseToCornerRightArrow: Bool {
        return self.arrowShowPoint.x > (self.frame.origin.x + self.bounds.width) - arrowSize.width/2 - cornerRadius
    }
    
    var isCornerLeftArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x
    }
    
    var isCornerRightArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.width
    }
    
    var isBehindCornerLeftArrow: Bool {
        return self.arrowShowPoint.x < self.frame.origin.x
    }
    
    var isBehindCornerRightArrow: Bool {
        return self.arrowShowPoint.x > self.frame.origin.x + self.bounds.width
    }
    
    func radians(_ degrees: CGFloat) -> CGFloat {
        return CGFloat.pi * degrees / 180
    }
}
