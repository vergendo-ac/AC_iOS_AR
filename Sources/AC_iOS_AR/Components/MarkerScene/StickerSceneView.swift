//
//  StickerSceneView.swift
//  myPlace
//
//  Created by Rustam Shigapov on 28/09/2019.
//  Copyright (c) 2019 SKZ. All rights reserved.
//

import UIKit

enum StickerPosition {
    case up
    case down
    
    var invert: StickerPosition {
        switch self {
        case .up: return .down
        case .down: return .up
        }
    }
    
    var commonOffset: CGFloat {
        switch self {
        case .up: return 65.0
        case .down: return 110.0
        }
    }
    
    func position(p: CGPoint, size: CGSize) -> StickerPosition {
        if p.y < size.height / 2 {
            return .down
        }
        return .up
    }
}

func baseScreenSize() -> CGSize {
    let width = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    let height = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    return CGSize(width: width, height: height)
}

class StickerSceneView: PassthroughView {
    //MARK: Outlets
    
    private var textBlockView: UIView! = UIView()
    private var nameLabel: UILabel! = UILabel()
    private var ratingLabel: UILabel! = UILabel()
    private var descriptionLabel: UILabel! = UILabel()
    private var stickerMarkerImage: UIImageView = UIImageView(image: InfoStickerCategory.other.image)
    private var ratingLabelImage: UIImageView! = UIImageView(image: UIImage(named: "star"))
    private var stickerSceneContainerView: StickerSceneContainerView!
    private var distanceLabel: UILabel! = UILabel()
    private var scaledPinSize: CGSize = StickerSceneView.pinSize
    
    enum ViewType: String, CaseIterable {
        case pin
        case sticker
        case video
        case cluster
        
        var title: String {
            self.rawValue.capitalizingFirstLetter()
        }
        
        var isVideo: Bool {
            switch self {
            case .video: return true
            default: return false
            }
        }
        
        static var viewTypes: [StickerSceneView.ViewType] {
            StickerSceneView.ViewType.allCases
        }
        
        static var titles: [String] {
            StickerSceneView.ViewType.viewTypes.map({ $0.title })
        }
        
    }
    
    struct Design {
        static let width: CGFloat = 376
        static let distanceLabelHeight = 12/width
        static let cornerRadius = 4/width
        static let distanceLabelFontSize = 16/width
    }
    
    //MARK: Const
    static let textBlockViewSize: CGSize = CGSize(width: 175, height: 104)
    static var pinSize: CGSize = CGSize(width: 80, height: 80)
    var stickerPosition: StickerPosition = .up {
        didSet {
            //updateFrame(stickerCentralPoint)
        }
    }
    
    //MARK: Variable
    public var distance: Double = 0.0 {
        didSet {
            //updateFrame()
        }
    }
    private var textMarkerStackView: UIStackView = UIStackView()
    private var pinMarkerStackView: UIStackView = UIStackView()
    private var ratingStackView: UIStackView = UIStackView()
    
    private var topGap: CGFloat = 0.0
    private var leftGap: CGFloat = 5.0
    
    
    public var offsetY: CGFloat = 0.0 {
        didSet {
            updateFrame(stickerCentralPoint)
        }
    }
    
    lazy var textBlockSize: CGSize = { return self.textBlockView.frame.size }()
    lazy var rightSide: CGFloat = { return frame.origin.x + frame.size.width }()
    lazy var leftSide: CGFloat = { return frame.origin.x - leftGap }()
    
    
    var stickerId: Int = -1
    var stickerData: StickerModels.StickerData? = nil {
        didSet {
            updateStickerData()
        }
    }
    var completion: () -> Swift.Void = {}
    var stickerMarkerViewCompletion: (Int, StickerModels.StickerData?) -> Swift.Void = {_,_  in }
    
    var stickerCentralPoint: CGPoint = CGPoint(x: 150, y: 300) {
        willSet {
            self.updateFrame(newValue)
        }
    }
    
    open var isSelected: Bool = false {
        didSet {
            if oldValue != isSelected {
                self.setSelected(isSelected: isSelected)
            }
        }
    }
    
    var stickerMarkerIsHidden: Bool = false {
        willSet {
            self.stickerMarkerImage.isHidden = newValue
        }
    }
    
    var currentType: InfoStickerCategory = .other
    var circleView = RatingCellT2()
    public var viewType: ViewType = .sticker
    private var pinView: UIView! /*PassthroughView!*/
    
    //MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewSetup()
    }
    
    convenience init(
        stickerId: Int,
        stickerDistancePoint: PointModels.DistantPoint,
        stickerData: StickerModels.StickerData?,
        topGap: CGFloat = 10.0,
        hideStickerMarker: Bool,
        pinView: UIView /*PassthroughView*/,
        stickerMarkerViewCompletion: @escaping (Int, StickerModels.StickerData?) -> ()) {
        
        self.init(frame: StickerSceneView.makePinFrame(
                centralPoint: stickerDistancePoint.1,
                topGap: topGap,
                offsetY: 0.0,
                stickerPosition: .up,
                newPinSize: StickerSceneView.pinSize,
                pinView: pinView,
                textBlockSize: StickerSceneView.textBlockViewSize
            )
        )
        
        self.isUserInteractionEnabled = true

        self.stickerMarkerImage.isHidden = hideStickerMarker
        self.pinView = pinView
        self.topGap = topGap
        self.setSelected(isSelected: false)
        self.stickerCentralPoint = stickerDistancePoint.1
        self.distance = stickerDistancePoint.0 ?? 1.0
        self.stickerId = stickerId
        self.stickerMarkerViewCompletion = stickerMarkerViewCompletion
        self.stickerData = stickerData
        self.stickerMarkerIsHidden = hideStickerMarker
        self.backgroundColor = .clear
        
        setupView {
            self.updateDashedLine()
            self.updateStickerData()
            self.updateFrame(self.stickerCentralPoint)
        }
    }
    
    deinit {
        print("deinit StickerSceneView")
    }
    
    func setupView(completion: (()-> Void)? = nil) {
        stickerSceneContainerView = StickerSceneContainerView(frame: self.frame)
        
        self.addSubview(stickerSceneContainerView)
        stickerSceneContainerView.frame.origin = .zero
        stickerSceneContainerView.frame.size = self.frame.size
        stickerSceneContainerView.backgroundColor = UIColor.clear
        
        
//        stickerSceneContainerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        stickerSceneContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        stickerSceneContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        stickerSceneContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        //makeBgImageViewToView()
        
        makePinBlock()
        makeTextMarkerBlock()
        
        
        completion?()
    }
    //MARK: - setupFont
    
    func setupFont() {
        ratingLabel?.textColor = UIColor(hex: "263238")
        ratingLabel?.font = UIFont(name: "Roboto-Bold", size: 16.0)
        ratingLabel?.numberOfLines = .zero
        ratingLabelImage.setHeight(16.0)
        
        nameLabel?.textColor = UIColor(hex: "263238")
        nameLabel?.font = UIFont(name: "Roboto-Bold", size: 16.0)
        nameLabel?.numberOfLines = .zero
        nameLabel?.lineBreakMode = .byWordWrapping
        //textMarkerStackView.spacing = -20
        
        descriptionLabel.textColor = UIColor(hex: "263238")
        descriptionLabel?.font = UIFont(name: "Roboto-Regular", size: 14.0)
    }
    //MARK: - setupConstraintUI
    func setupConstraintUI() {
        textMarkerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // align ratingStackView from the left
        textBlockView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[view]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": ratingStackView]))

        // align ratingStackView from the top
        textBlockView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[view]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": ratingStackView]))
        
        // align textMarkerStackView from the left and right
        textBlockView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[view]-8-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": textMarkerStackView]))

        // align textMarkerStackView from the top
        textBlockView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[view]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": textMarkerStackView]))
        
        // height constraint
//        stickerSceneContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(>=50)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": textBlockView]))
//
//        textMarkerStackView.heightAnchor.constraint(equalTo: textBlockView.heightAnchor, multiplier: 1).isActive = true
//        textMarkerStackView.widthAnchor.constraint(equalTo: textBlockView.widthAnchor, multiplier: 1).isActive = true
        

    }
    
    func makeTextMarkerBlock() {
        ratingStackView = UIStackView(arrangedSubviews: [ratingLabelImage, ratingLabel])
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .equalSpacing
        ratingStackView.alignment = .center
        ratingStackView.spacing = -30.0

               
        textMarkerStackView = UIStackView(arrangedSubviews: [ratingStackView, nameLabel, descriptionLabel])
        textMarkerStackView.axis = .vertical
        textMarkerStackView.distribution = .equalSpacing
        textMarkerStackView.alignment = .leading
        
        textBlockView.frame.size = StickerSceneView.textBlockViewSize
        textBlockView.layer.cornerRadius = 5.0
        
        textMarkerStackView.frame.origin = CGPoint(x: 5.0, y: 5.0)
        textMarkerStackView.frame.size = CGSize(width: StickerSceneView.textBlockViewSize.width - 10.0, height: StickerSceneView.textBlockViewSize.height - 10.0)
        
        textBlockView.addSubview(textMarkerStackView)
        stickerSceneContainerView.addSubview(textBlockView)
        setupConstraintUI()
        setupFont()
    }
    
    func makePinBlock() {
        pinMarkerStackView = UIStackView(arrangedSubviews: [stickerMarkerImage, distanceLabel])
        pinMarkerStackView.frame.size = StickerSceneView.pinSize
        
        pinMarkerStackView.axis = .vertical
        pinMarkerStackView.distribution = .equalSpacing
        pinMarkerStackView.spacing = .zero
        pinMarkerStackView.alignment = .center
        
        pinMarkerStackView.frame.origin.x = StickerSceneView.textBlockViewSize.width / 2 - StickerSceneView.pinSize.width / 2
        //pinMarkerStackView.alpha = 0.5
        
        stickerSceneContainerView.addSubview(pinMarkerStackView)
    }
    
//    func makeBgImageViewToView() {
//        bgImageView = UIImageView(frame: self.frame)
//        self.addSubview(bgImageView)
//
//        bgImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//    }
    
    //MARK: Tag work
    func set(tag: Tags.value) {
        self.tag = tag.rawValue
    }
    
    //MARK: Make pin frame
    static func makePinFrame(
        centralPoint: CGPoint,
        topGap: CGFloat = 5.0,
        offsetY: CGFloat,
        stickerPosition: StickerPosition,
        newPinSize: CGSize,
        pinView: UIView,
        textBlockSize: CGSize) -> CGRect {
        
        let pinViewSize = pinView.frame.size
        
        var xibHeight: CGFloat = .zero
        var newRect: CGRect = .zero
        var topY = offsetY
        
        if stickerPosition == .up {
            xibHeight = (centralPoint.y + newPinSize.height / 2 - offsetY)
        } else {
            xibHeight = (pinViewSize.height - offsetY) - (centralPoint.y - newPinSize.height / 2)
            topY = centralPoint.y - newPinSize.height / 2
        }
        
        newRect = CGRect(
            x: centralPoint.x - textBlockSize.width / 2,
            y: topY,
            width:  textBlockSize.width,
            height: max(0, xibHeight)
        )

        return newRect
    }
    
    private func updateTextPinPosition(frame: CGRect, pinSize: CGSize) {
        pinPosition(frame: frame, pinSize: pinSize)
        textPosition(frame: frame)
    }
    
    private func pinPosition(frame: CGRect, pinSize: CGSize) {
       switch stickerPosition {
        case .up:
            pinMarkerStackView.frame.origin.y = frame.size.height - pinSize.height
        case .down:
            pinMarkerStackView.frame.origin.y = .zero
        }
    }
    
    private func textPosition(frame: CGRect) {
        
        DispatchQueue.main.async {
            self.textBlockView.frame.size.height = self.textMarkerStackView.frame.size.height + 16
            self.textBlockView.frame.size.width = self.textMarkerStackView.frame.size.width + 16
            
            switch self.stickerPosition {
            case .up:
                self.textBlockView.frame.origin.y = .zero
            case .down:
                self.textBlockView.frame.origin.y = frame.size.height - self.textBlockView.frame.height
            }
        }
    }
    
    static func distanceToScale(distance: Double) -> CGSize {
        if distance >= 0 && distance < 25 {
            return StickerSceneView.pinSize //75px
        } else if distance >= 25 && distance < 50 {
            return CGSize(width: 57, height: 57)
        } else if distance >= 50 && distance <= 100 {
            return CGSize(width: 39, height: 39)
        } else {
            return CGSize(width: 21, height: 21)
        }
    }
    
    // MARK: Setup
    private func viewSetup() {
        //self.xibSetup()
        self.gestureSetup()
        self.setupUI()
    }
    
    
    //sticker position func 
    private func change(position: StickerPosition) {
        DispatchQueue.main.async {
            self.updateFrame(self.stickerCentralPoint)
        }
    }
        
    private func updateStickerData() {
        self.updateData(rating: stickerData?.options[StickerOptions.rating],
                        name: stickerData?.options[StickerOptions.title],
                        desc: stickerData?.options[StickerOptions.stickerDetailedType],
                        type: stickerData?.options[StickerOptions.stickerType],
                        time: stickerData?.options[StickerOptions.phoneNumber],
                        image: stickerData?.options[StickerOptions.stickerType],
                        price: stickerData?.options[StickerOptions.priceCategory],
                        fback: stickerData?.options[StickerOptions.feedbackAmount],
                        path: stickerData?.options[StickerOptions.path])
    }
    
//    private func makePointsdashLineCenter() -> (CGPoint, CGPoint) {
//        let stickerViewSize = stickerView.frame.size
//        let pinViewSize = stickerMarkerImage.frame.size
//        let pinViewOrigin = stickerMarkerImage.frame.origin
//        let bottomViewFrame = bottomBorderLineView.frame
//        let point1 = CGPoint(x: stickerViewSize.width / 2, y: bottomViewFrame.origin.y + bottomViewFrame.size.height / 2 )
//        let point2 = CGPoint(x: pinViewOrigin.x + pinViewSize.width / 2, y: self.frame.size.height - pinViewSize.height / 2)
//        return (point1, point2)
//    }
    
    private func updateDashedLine() {
        guard viewType == .sticker else {
            stickerSceneContainerView.removeDashedPoints()
            return
        }
        
        var p0 = CGPoint.zero
        var p1 = CGPoint.zero
        
        let dashColor = UIColor(red: currentType.rgbar.0, green: currentType.rgbar.1, blue: currentType.rgbar.2, alpha: 0.5)
        stickerSceneContainerView.setDashColor(color: dashColor)
        switch stickerPosition {
        case .up:
            p0 = CGPoint(x: stickerSceneContainerView.frame.size.width/2, y: textBlockView.frame.size.height + textBlockView.frame.origin.y)
            p1 = CGPoint(x: stickerSceneContainerView.frame.size.width/2, y: self.pinMarkerStackView.frame.origin.y + self.pinMarkerStackView.frame.size.height / 2)
        case .down:
            p0 = CGPoint(x: stickerSceneContainerView.frame.size.width/2, y: textBlockView.frame.origin.y)
            p1 = CGPoint(x: stickerSceneContainerView.frame.size.width/2, y: self.pinMarkerStackView.frame.origin.y + self.pinMarkerStackView.frame.size.height / 2)
        }
        stickerSceneContainerView.setDashPoints(startPoint: p0, endPoint: p1)
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.clear
        self.tag = Tags.value.HalfRealtimeStickerMarkerView.rawValue
        //self.textBlockView.roundViewCorners(corners: [.topLeft, .topRight], radius: 2.0)
        
        //self.textBlockView.alpha = 0.7
        
        //self.stickerView.bringSubviewToFront(self.bottomBorderLineView)
        //self.bottomBorderLineView.alpha = 1.0
        //self.ratingLabelImage.setImageColor(color: UIColor.black)
        
        // MARK: distance label
        let w = baseScreenSize().width
        self.distanceLabel.textColor = UIColor(hex: "#263238")
        self.distanceLabel.layer.masksToBounds = true
        self.distanceLabel.font = UIFont(name: "Roboto-Bold", size: Design.distanceLabelFontSize*w)
        self.distanceLabel.layer.cornerRadius = Design.cornerRadius*w
    }
    
    private func gestureSetup() {
        self.isUserInteractionEnabled = true
        self.textBlockView.isUserInteractionEnabled = true
        self.pinMarkerStackView.isUserInteractionEnabled = true
        self.stickerMarkerImage.isUserInteractionEnabled = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMarkerAndPinGesture))
        self.textBlockView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureStickerRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMarkerAndPinGesture))
        self.stickerMarkerImage.addGestureRecognizer(tapGestureStickerRecognizer)

    }
    
    @objc func didTapMarkerAndPinGesture(_ sender: UITapGestureRecognizer) {
        self.stickerMarkerViewCompletion(self.stickerId, self.stickerData)
        self.stickerMarkerImage.isHighlighted = false
    }
    
    private func isVideoSticker(path: String?) -> Bool {
        if let urlString = path, urlString.suffix(4) == ".mp4", let _ = URL(string: urlString)  {
            return true
        }
        return false
    }
    
    private func updateData(
        rating: String?,
        name: String?,
        desc: String?,
        type: String?,
        time: String?,
        image: String?,
        price: String?,
        fback: String?,
        path: String?
    ) {
        DispatchQueue.main.async { [self] in
            
            if self.isVideoSticker(path: path) {
                self.setViewType(.video, distance: nil)
            }
            
            //name
            self.nameLabel.text = name
            
            let isHidden: Bool = rating == nil
            self.ratingLabel.isHidden = isHidden
            self.ratingLabelImage.isHidden = isHidden
            
            //description
            if let desc = desc {
                self.descriptionLabel.text = desc
            } else {
                self.descriptionLabel.text = type
            }
            
            //rating
            if let rating = rating {
                self.ratingLabel.text = rating
                
//                if let ratingForCircleView = self.stickerData?.options[StickerOptions.rating],
//                    let rating = Float(ratingForCircleView) {
//                }
            } else {
                self.ratingLabel.isHidden = isHidden
            }
            
            self.currentType = InfoStickerCategory.category(for: image)
            self.stickerMarkerImage.image = self.currentType.image
            self.textBlockView.backgroundColor = self.currentType.color
            self.circleView.backgroundColor = self.currentType.color
            //self.bottomBorderLineView.backgroundColor = self.currentType.borderColor
            self.textBlockView.setNeedsLayout()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.updateDashedLine()
                //TODO: - Dispatch Group
                self.textBlockSize = self.textBlockView.frame.size
            })
        }
    }
    
    private func setSelected(isSelected: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.stickerMarkerImage.isHighlighted = isSelected
            self.nameLabel.isHighlighted = isSelected
        }
    }
    
    
    //MARK: UPDATE
    private func updateFrame(_ centralPoint: CGPoint) {
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateFrame(centralPoint)
            }
            return
        }
        
        self.textBlockView.isHidden = viewType == .pin
        
        scaledPinSize = StickerSceneView.distanceToScale(distance: self.distance)
        self.stickerMarkerImage.frame.size = scaledPinSize
        
        var newRect = CGRect(
            x: centralPoint.x - textBlockSize.width / 2,
            y: centralPoint.y - scaledPinSize.height / 2,
            width: textBlockSize.width,
            height: scaledPinSize.height)
        
        if viewType == .sticker {
            newRect = StickerSceneView.makePinFrame(
                centralPoint: centralPoint,
                topGap: self.topGap,
                offsetY: self.offsetY,
                stickerPosition: self.stickerPosition,
                newPinSize: self.scaledPinSize,
                pinView: self.pinView,
                textBlockSize: textBlockSize)
        }
        self.frame = newRect
        
        self.stickerSceneContainerView.frame.origin = .zero
        self.stickerSceneContainerView.frame.size = newRect.size
        
        //print("[!] newRect:\(newRect), stickerSceneContainerView:\(self.stickerSceneContainerView.frame)")
        
        //Update constraint by UIView Extension
        self.stickerMarkerImage.heightConstaint?.constant = scaledPinSize.height
        self.stickerMarkerImage.widthConstaint?.constant = scaledPinSize.width
        
        //self.setNeedsLayout()
        self.updateDashedLine()
        
        self.updateTextPinPosition(frame: newRect, pinSize: scaledPinSize)
        
    }
    
    public func move(centralPoint: CGPoint) {
        self.stickerCentralPoint = centralPoint
        //self.updateFrame()
    }
    
    func setViewType(_ type: ViewType, distance: Double?) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.setViewType(type, distance: distance)
            }
            return
        }
        
        self.viewType = type
        if let dist = distance {
        self.distance = dist
        } else {
            print("distance is nil - \(distance == nil)")
        }
        
        if let dist = distance {
            self.distanceLabel.text = dist < 3 ? String(format: " %.1fm ", dist) : String(format: " %dm ", Int(dist))
            self.distanceLabel.frame.size = CGSize(width: 34.0, height: 24.0)
            self.distanceLabel.backgroundColor = currentType.color
            self.distanceLabel.isHidden = false
            pinMarkerStackView.frame.size.height = self.scaledPinSize.height + self.distanceLabel.frame.size.height
        } else {
            self.distanceLabel.isHidden = true
            pinMarkerStackView.frame.size.height = self.scaledPinSize.height
        }
    }
}

// MARK: Extension - roundViewCorners

extension UIView {
    func roundViewCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIView {
    var heightConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    var widthConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
