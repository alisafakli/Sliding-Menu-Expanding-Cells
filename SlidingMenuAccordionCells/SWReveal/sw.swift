/*
 
 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Early code inspired on a similar class by Philip Kluz (Philip.Kluz@zuui.org)
 
 */
/*
 
 RELEASE NOTES
 
 Version 2.4.0 (Current Version)
 
 - Updated behaviour of appearance method calls on child controllers
 - Removes Xcode 6.3.1 warnings
 
 Version 2.3.0
 
 - StoryBoard initializing bug fix
 - Minor Code refactoring
 
 Version 2.2.0
 
 - State Restoration support.
 - Reverted panGestureRecognizer implementation to before v2.1.0 (works better).
 - New properties 'toggleAnimationType', 'springDampingRatio'. Default reveal animation is 'Spring'
 - New property 'frontViewShadowColor'
 - New properties 'clipsViewsToBounds' and '_extendedPointInsideHit'
 - New delegate methods for finer control of front view location in the overdraw area, as long as deprecation note on former delegate methods
 - Other minor changes that should not affect current implementations
 
 Version 2.1.0
 
 - Removed SWDirectionPanGestureRecognizer. Horizontal panning is filtered on the shouldBegin delegate. This is cleaner, I hope it does not break previous funcionality
 - Took a cleaner approach to storyboard support. SWRevealViewControllerSegue is now deprecated and you should use SWRevealViewControllerSegueSetController and SWRevealViewControllerSeguePushController instead.
 - A minor change on the autoresizingMask of the internal views to fix a glitch on iOS8. This should not affect iOS7
 
 Version 2.0.2
 
 - Added new delegates for better control of gesture recognizers
 
 Version 2.0.1
 
 - Fix: draggableBorderWidth now correctly handles the cases where one of the rear controllers is not provided
 - Fix: the shadow related properties are now granted at any time after view load, not just after initialization.
 
 Version 2.0.0
 
 - Dropped support for iOS6 and earlier. This version will only work on iOS7
 
 - The method setFrontViewController:animated: does not longer perform a full reveal animation. Instead it just replaces the frontViewController in
 its current position. Use the new pushFrontViewController:animated: method to perform a replacement of the front controlles with reveal animation
 as in the previous version
 
 IMPORTANT: You must replace all calls to setFrontViewController:animated by calls to pushFrontViewController:animated to prevent breaking
 functionality on existing projects.
 
 - Added support for animated replacement of child controllers: setRearViewController, setFrontViewController, setRightViewController now have animated versions.
 
 - The new 'replaceViewAnimationDuration' property sets the default duration of child viewController replacement.
 
 - Added the following new delegate methods
 revealController:willAddViewController:forOperation:animated:
 revealController:didAddViewController:forOperation:animated:
 
 - The class also supports custom UIViewControllerAnimatedTransitioning related with the replacement of child viewControllers.
 You can implement the following new delegate method: revealController:animationControllerForOperation:fromViewController:toViewController:
 and provide an object conforming to UIViewControllerAnimatedTransitioning to implement custom animations.
 
 Version 1.1.3
 
 - Reverted the supportedInterfaceOrientations to the default behavior. This is consistent with Apple provided controllers
 
 - The presentFrontViewHierarchically now dynamically takes into account the smaller header height of bars on iPhone landscape orientation
 
 Version 1.1.2
 
 - The status bar style and appearance are now handled in sync with the class animations.
 You can implement the methods preferredStatusBarStyle and prefersStatusBarHidden on your child controllers to define the desired appearance
 
 - The loadView method now calls a method, loadStoryboardControllers, just for the purpose of loading child controllers from a storyboard.
 You can override this method and remove the @try @catch statements if you want the debugger not to stop at them in case you have set an exception breakpoint.
 
 Version 1.1.1
 
 - You can now get a tapGestureRecognizer from the class. See the tapGestureRecognizer method for more information.
 
 - Both the panGestureRecognizer and the tapGestureRecognizer are now attached to the revealViewController's front content view
 by default, so they will start working just by calling their access methods even if you do not attach them to any of your views.
 This enables you to dissable interactions on your views -for example based on position- without breaking normal gesture behavior.
 
 - Corrected a bug that caused a crash on iOS6 and earlier.
 
 Version 1.1.0
 
 - The method setFrontViewController:animated now performs the correct animations both for left and right controllers.
 
 - The class now automatically handles the status bar appearance depending on the currently shown child controller.
 
 Version 1.0.8
 
 - Support for constant width frontView by setting a negative value to reveal widths. See properties rearViewRevealWidth and rightViewRevealWidth
 
 - Support for draggableBorderWidth. See property of the same name.
 
 - The Pan gesture recongnizer can be disabled by implementing the following delegate method and returning NO
 revealControllerPanGestureShouldBegin:
 
 - Added the ability to track pan gesture reveal progress through the following new delegate methods
 revealController:panGestureBeganFromLocation:progress:
 revealController:panGestureMovedToLocation:progress:
 revealController:panGestureEndedToLocation:progress:
 
 Previous Versions
 
 - No release notes were updated for previous versions.
 
 */
import UIKit

// MARK: - SWRevealViewController Class
// Enum values for setFrontViewPosition:animated:
enum FrontViewPosition : Int {
    // Front controller is removed from view. Animated transitioning from this state will cause the same
    // effect than animating from FrontViewPositionLeftSideMost. Use this instead of FrontViewPositionLeftSideMost when
    // you want to remove the front view controller view from the view hierarchy.
    case LeftSideMostRemoved
    // Left most position, front view is presented left-offseted by rightViewRevealWidth+rigthViewRevealOverdraw
    case LeftSideMost
    // Left position, front view is presented left-offseted by rightViewRevealWidth
    case LeftSide
    // Center position, rear view is hidden behind front controller
    case Left
    // Right possition, front view is presented right-offseted by rearViewRevealWidth
    case Right
    // Right most possition, front view is presented right-offseted by rearViewRevealWidth+rearViewRevealOverdraw
    case RightMost
    // Front controller is removed from view. Animated transitioning from this state will cause the same
    // effect than animating from FrontViewPositionRightMost. Use this instead of FrontViewPositionRightMost when
    // you intent to remove the front controller view from the view hierarchy.
    case RightMostRemoved
}

// Enum values for toggleAnimationType
enum SWRevealToggleAnimationType : Int {
    case Spring
    // <- produces a spring based animation
    case EaseOut
}

class SWRevealViewController: UIViewController {
    /* Basic API */
    // Object instance init and rear view setting
    override init(rearViewController: UIViewController, frontViewController: UIViewController) {
        super.init()
        
        self._initDefaultProperties()
        self._performTransitionOperation(SWRevealControllerOperationReplaceRearController, withViewController: rearViewController, animated: false)
        self._performTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: frontViewController, animated: false)
        
    }
    // Rear view controller, can be nil if not used
    var rearViewController: UIViewController!
    
    func setRearViewController(rearViewController: UIViewController, animated: Bool) {
        if !self.isViewLoaded() {
            self._performTransitionOperation(SWRevealControllerOperationReplaceRearController, withViewController: rearViewController, animated: false)
            return
        }
        self._dispatchTransitionOperation(SWRevealControllerOperationReplaceRearController, withViewController: rearViewController, animated: animated)
    }
    // Optional right view controller, can be nil if not used
    var rightViewController: UIViewController!
    
    func setRightViewController(rightViewController: UIViewController, animated: Bool) {
        if !self.isViewLoaded() {
            self._performTransitionOperation(SWRevealControllerOperationReplaceRightController, withViewController: rightViewController, animated: false)
            return
        }
        self._dispatchTransitionOperation(SWRevealControllerOperationReplaceRightController, withViewController: rightViewController, animated: animated)
    }
    // Front view controller, can be nil on initialization but must be supplied by the time the view is loaded
    var frontViewController: UIViewController!
    
    func setFrontViewController(frontViewController: UIViewController, animated: Bool) {
        if !self.isViewLoaded() {
            self._performTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: frontViewController, animated: false)
            return
        }
        self._dispatchTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: frontViewController, animated: animated)
    }
    // Sets the frontViewController using a default set of chained animations consisting on moving the
    // presented frontViewController to the right most possition, replacing it, and moving it back to the left position
    
    func pushFrontViewController(frontViewController: UIViewController, animated: Bool) {
        if !self.isViewLoaded() {
            self._performTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: frontViewController, animated: false)
            return
        }
        self._dispatchPushFrontViewController(frontViewController, animated: animated)
    }
    // Sets the frontViewController position. You can call the animated version several times with different
    // positions to obtain a set of animations that will be performed in order one after the other.
    var frontViewPosition = FrontViewPosition()
    
    func setFrontViewPosition(frontViewPosition: FrontViewPosition, animated: Bool) {
        if !self.isViewLoaded() {
            self.frontViewPosition = frontViewPosition
            self.rearViewPosition = frontViewPosition
            self.rightViewPosition = frontViewPosition
            return
        }
        self._dispatchSetFrontViewPosition(frontViewPosition, animated: animated)
    }
    // The following methods are meant to be directly connected to the action method of a button
    // to perform user triggered postion change of the controller views. This is ussually added to a
    // button on top left or right of the frontViewController
    
    @IBAction func revealToggle(sender: AnyObject) {
        self.revealToggleAnimated(true)
    }
    
    @IBAction func rightRevealToggle(sender: AnyObject) {
        self.rightRevealToggleAnimated(true)
    }
    // <-- simetric implementation of the above for the rightViewController
    // Toogles the current state of the front controller between Left or Right and fully visible
    // Use setFrontViewPosition to set a particular position
    
    func revealToggleAnimated(animated: Bool) {
        var toggledFrontViewPosition = .Left
        if frontViewPosition <= .Left {
            toggledFrontViewPosition = .Right
        }
        self.setFrontViewPosition(toggledFrontViewPosition, animated: animated)
    }
    
    func rightRevealToggleAnimated(animated: Bool) {
        var toggledFrontViewPosition = .Left
        if frontViewPosition >= .Left {
            toggledFrontViewPosition = .LeftSide
        }
        self.setFrontViewPosition(toggledFrontViewPosition, animated: animated)
    }
    // <-- simetric implementation of the above for the rightViewController
    // The following method will provide a panGestureRecognizer suitable to be added to any view
    // in order to perform usual drag and swipe gestures to reveal the rear views. This is usually added to the top bar
    // of a front controller, but it can be added to your frontViewController view or to the reveal controller view to provide full screen panning.
    // By default, the panGestureRecognizer is added to the view containing the front controller view. To keep this default behavior
    // you still need to call this method, just don't add it to any of your views. The default setup allows you to dissable
    // user interactions on your controller views without affecting the recognizer.
    
    override func panGestureRecognizer() -> UIPanGestureRecognizer {
        if panGestureRecognizer == nil {
            self.panGestureRecognizer = SWRevealViewControllerPanGestureRecognizer(target: self, action: #selector(self._handleRevealGesture))
            self.panGestureRecognizer.delegate! = self
            contentView.frontView.addGestureRecognizer(panGestureRecognizer)
        }
        return panGestureRecognizer
    }
    // The following method will provide a tapGestureRecognizer suitable to be added to any view on the frontController
    // for concealing the rear views. By default no tap recognizer is created or added to any view, however if you call this method after
    // the controller's view has been loaded the recognizer is added to the reveal controller's front container view.
    // Thus, you can disable user interactions on your frontViewController view without affecting the tap recognizer.
    
    func tapGestureRecognizer() -> UITapGestureRecognizer {
        if tapGestureRecognizer == nil {
            var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self._handleTapGesture))
            tapRecognizer.delegate! = self
            contentView.frontView.addGestureRecognizer(tapRecognizer)
            self.tapGestureRecognizer = tapRecognizer
        }
        return tapGestureRecognizer
    }
    /* The following properties are provided for further customization, they are set to default values on initialization,
     you do not generally have to set them */
    // Defines how much of the rear or right view is shown, default is 260.
    // Negative values indicate that the reveal width should be computed by substracting the full front view width,
    // so the revealed frontView width is kept constant when bounds change as opposed to the rear or right width.
    var rearViewRevealWidth: CGFloat = 0.0
    var rightViewRevealWidth: CGFloat = 0.0
    // <-- simetric implementation of the above for the rightViewController
    // Defines how much of an overdraw can occur when dragging further than 'rearViewRevealWidth', default is 60.
    var rearViewRevealOverdraw: CGFloat = 0.0
    var rightViewRevealOverdraw: CGFloat = 0.0
    // <-- simetric implementation of the above for the rightViewController
    // Defines how much displacement is applied to the rear view when animating or dragging the front view, default is 40.
    var rearViewRevealDisplacement: CGFloat = 0.0
    var rightViewRevealDisplacement: CGFloat = 0.0
    // <-- simetric implementation of the above for the rightViewController
    // Defines a width on the border of the view attached to the panGesturRecognizer where the gesture is allowed,
    // default is 0 which means no restriction.
    var draggableBorderWidth: CGFloat = 0.0
    // If YES (the default) the controller will bounce to the Left position when dragging further than 'rearViewRevealWidth'
    var bounceBackOnOverdraw = false
    var bounceBackOnLeftOverdraw = false
    // <-- simetric implementation of the above for the rightViewController
    // If YES (default is NO) the controller will allow permanent dragging up to the rightMostPosition
    var stableDragOnOverdraw = false
    var stableDragOnLeftOverdraw = false
    // <-- simetric implementation of the above for the rightViewController
    // If YES (default is NO) the front view controller will be ofsseted vertically by the height of a navigation bar.
    // Use this on iOS7 when you add an instance of RevealViewController as a child of a UINavigationController (or another SWRevealViewController)
    // and you want the front view controller to be presented below the navigation bar of its UINavigationController grand parent.
    // The rearViewController will still appear full size and blurred behind the navigation bar of its UINavigationController grand parent
    var presentFrontViewHierarchically = false
    // Velocity required for the controller to toggle its state based on a swipe movement, default is 250
    var quickFlickVelocity: CGFloat = 0.0
    // Duration for the revealToggle animation, default is 0.25
    var toggleAnimationDuration = NSTimeInterval()
    // Animation type, default is SWRevealToggleAnimationTypeSpring
    var toggleAnimationType = SWRevealToggleAnimationType()
    // When animation type is SWRevealToggleAnimationTypeSpring determines the damping ratio, default is 1
    var springDampingRatio: CGFloat = 0.0
    // Duration for animated replacement of view controllers
    var replaceViewAnimationDuration = NSTimeInterval()
    // Defines the radius of the front view's shadow, default is 2.5f
    var frontViewShadowRadius: CGFloat = 0.0
    // Defines the radius of the front view's shadow offset default is {0.0f,2.5f}
    var frontViewShadowOffset = CGSize.zero
    // Defines the front view's shadow opacity, default is 1.0f
    var frontViewShadowOpacity: CGFloat = 0.0
    // Defines the front view's shadow color, default is blackColor
    var frontViewShadowColor: UIColor!
    // Defines whether the controller should clip subviews to its view bounds. Default is NO.
    // Set this to YES when you are presenting this controller as a non full-screen child of a
    // custom container controller which does not explicitly clips its subviews.
    var clipsViewsToBounds = false
    // Defines whether your views clicable area extends beyond the bounds of this controller. Default is NO.
    // Set this to YES if you are presenting this controller as a non full-screen child of a custom container and you are not
    // clipping your front view to this controller bounds.
    var extendsPointInsideHit = false
    /* The class properly handles all the relevant calls to appearance methods on the contained controllers.
     Moreover you can assign a delegate to let the class inform you on positions and animation activity */
    // Delegate
    weak var delegate: SWRevealViewControllerDelegate?
    var panInitialFrontPosition = FrontViewPosition()
    var animationQueue = [AnyObject]()
    var userInteractionStore = false
    
    
    let .None = 0xff
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._initDefaultProperties()
        
    }
    
    convenience override init() {
        return self.init(rearViewController: nil, frontViewController: nil)
    }
    
    func _initDefaultProperties() {
        self.frontViewPosition = .Left
        self.rearViewPosition = .Left
        self.rightViewPosition = .Left
        self.rearViewRevealWidth = 260.0
        self.rearViewRevealOverdraw = 60.0
        self.rearViewRevealDisplacement = 40.0
        self.rightViewRevealWidth = 260.0
        self.rightViewRevealOverdraw = 60.0
        self.rightViewRevealDisplacement = 40.0
        self.bounceBackOnOverdraw = true
        self.bounceBackOnLeftOverdraw = true
        self.stableDragOnOverdraw = false
        self.stableDragOnLeftOverdraw = false
        self.presentFrontViewHierarchically = false
        self.quickFlickVelocity = 250.0
        self.toggleAnimationDuration = 0.3
        self.toggleAnimationType = .Spring
        self.springDampingRatio = 1
        self.replaceViewAnimationDuration = 0.25
        self.frontViewShadowRadius = 2.5
        self.frontViewShadowOffset = CGSizeMake(0.0, 2.5)
        self.frontViewShadowOpacity = 1.0
        self.frontViewShadowColor = UIColor.blackColor()
        self.userInteractionStore = true
        self.animationQueue = [AnyObject]()
        self.draggableBorderWidth = 0.0
        self.clipsViewsToBounds = false
        self.extendsPointInsideHit = false
    }
    // MARK: - StatusBar
    
    override func childViewControllerForStatusBarStyle() -> UIViewController {
        var positionDif = frontViewPosition - .Left
        var controller = frontViewController
        if positionDif > 0 {
            controller = rearViewController
        }
        else if positionDif < 0 {
            controller = rightViewController
        }
        
        return controller
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController {
        var controller = self.childViewControllerForStatusBarStyle()!
        return controller
    }
    // MARK: - View lifecycle
    
    override func loadView() {
        // Do not call super, to prevent the apis from unfruitful looking for inexistent xibs!
        //[super loadView];
        // load any defined front/rear controllers from the storyboard before
        self.loadStoryboardControllers()
        // This is what Apple used to tell us to set as the initial frame, which is of course totally irrelevant
        // with view controller containment patterns, let's leave it for the sake of it!
        // CGRect frame = [[UIScreen mainScreen] applicationFrame];
        // On iOS7 the applicationFrame does not return the whole screen. This is possibly a bug.
        // As a workaround we use the screen bounds, this still works on iOS6, any zero based frame would work anyway!
        var frame = UIScreen.mainScreen().bounds
        // create a custom content view for the controller
        self.contentView = SWRevealView(frame: frame, controller: self)
        // set the content view to resize along with its superview
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // set the content view to clip its bounds if requested
        contentView.clipsToBounds = clipsViewsToBounds
        // set our contentView to the controllers view
        self.view = contentView
        // Apple also tells us to do this:
        self.contentView.backgroundColor = UIColor.blackColor()
        // we set the current frontViewPosition to none before seting the
        // desired initial position, this will force proper controller reload
        var initialPosition = frontViewPosition
        self.frontViewPosition = .None
        self.rearViewPosition = .None
        self.rightViewPosition = .None
        // now set the desired initial position
        self._setFrontViewPosition(initialPosition, withDuration: 0.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Uncomment the following code if you want the child controllers
        // to be loaded at this point.
        //
        // We leave this commented out because we think loading childs here is conceptually wrong.
        // Instead, we refrain view loads until necesary, for example we may never load
        // the rear controller view -or the front controller view- if it is never displayed.
        //
        // If you need to manipulate views of any of your child controllers in an override
        // of this method, you can load yourself the views explicitly on your overriden method.
        // However we discourage it as an app following the MVC principles should never need to do so
        //  [_frontViewController view];
        //  [_rearViewController view];
        // we store at this point the view's user interaction state as we may temporarily disable it
        // and resume it back to the previous state, it is possible to override this behaviour by
        // intercepting it on the panGestureBegan and panGestureEnded delegates
        self.userInteractionStore = contentView.userInteractionEnabled
    }
    
    override func supportedInterfaceOrientations() -> Int {
        // we could have simply not implemented this, but we choose to call super to make explicit that we
        // want the default behavior.
        return super.supportedInterfaceOrientations()
    }
    // MARK: - Public methods and property accessors
    
    func setFrontViewController(frontViewController: UIViewController) {
        self.setFrontViewController(frontViewController, animated: false)
    }
    
    func setRearViewController(rearViewController: UIViewController) {
        self.setRearViewController(rearViewController, animated: false)
    }
    
    func setRightViewController(rightViewController: UIViewController) {
        self.setRightViewController(rightViewController, animated: false)
    }
    
    func setFrontViewPosition(frontViewPosition: FrontViewPosition) {
        self.setFrontViewPosition(frontViewPosition, animated: false)
    }
    
    func setFrontViewShadowRadius(frontViewShadowRadius: CGFloat) {
        self.frontViewShadowRadius = frontViewShadowRadius
        contentView.reloadShadow()
    }
    
    func setFrontViewShadowOffset(frontViewShadowOffset: CGSize) {
        self.frontViewShadowOffset = frontViewShadowOffset
        contentView.reloadShadow()
    }
    
    func setFrontViewShadowOpacity(frontViewShadowOpacity: CGFloat) {
        self.frontViewShadowOpacity = frontViewShadowOpacity
        contentView.reloadShadow()
    }
    
    func setFrontViewShadowColor(frontViewShadowColor: UIColor) {
        self.frontViewShadowColor = frontViewShadowColor
        contentView.reloadShadow()
    }
    
    func setClipsViewsToBounds(clipsViewsToBounds: Bool) {
        self.clipsViewsToBounds = clipsViewsToBounds
        contentView.clipsToBounds = clipsViewsToBounds
    }
    // MARK: - Provided acction methods
    // MARK: - UserInteractionEnabling
    // disable userInteraction on the entire control
    
    func _disableUserInteraction() {
        contentView.userInteractionEnabled = false
        contentView.disableLayout = true
    }
    // restore userInteraction on the control
    
    func _restoreUserInteraction() {
        // we use the stored userInteraction state just in case a developer decided
        // to have our view interaction disabled beforehand
        contentView.userInteractionEnabled = userInteractionStore
        contentView.disableLayout = false
    }
    // MARK: - PanGesture progress notification
    
    func _notifyPanGestureBegan() {
        if delegate!.respondsToSelector(#selector(self.revealControllerPanGestureBegan)) {
            delegate!.revealControllerPanGestureBegan(self)
        }
        var xLocation: CGFloat
        var dragProgress: CGFloat
        var overProgress: CGFloat
        self._getDragLocation(xLocation, progress: dragProgress, overdrawProgress: overProgress)
        if delegate!.respondsToSelector(Selector("revealController:panGestureBeganFromLocation:progress:overProgress:")) {
            delegate!.revealController(self, panGestureBeganFromLocation: xLocation, progress: dragProgress, overProgress: overProgress)
        }
        else if delegate!.respondsToSelector(Selector("revealController:panGestureBeganFromLocation:progress:")) {
            delegate!.revealController(self, panGestureBeganFromLocation: xLocation, progress: dragProgress)
        }
        
    }
    
    func _notifyPanGestureMoved() {
        var xLocation: CGFloat
        var dragProgress: CGFloat
        var overProgress: CGFloat
        self._getDragLocation(xLocation, progress: dragProgress, overdrawProgress: overProgress)
        if delegate!.respondsToSelector(Selector("revealController:panGestureMovedToLocation:progress:overProgress:")) {
            delegate!.revealController(self, panGestureMovedToLocation: xLocation, progress: dragProgress, overProgress: overProgress)
        }
        else if delegate!.respondsToSelector(Selector("revealController:panGestureMovedToLocation:progress:")) {
            delegate!.revealController(self, panGestureMovedToLocation: xLocation, progress: dragProgress)
        }
        
    }
    
    func _notifyPanGestureEnded() {
        var xLocation: CGFloat
        var dragProgress: CGFloat
        var overProgress: CGFloat
        self._getDragLocation(xLocation, progress: dragProgress, overdrawProgress: overProgress)
        if delegate!.respondsToSelector(Selector("revealController:panGestureEndedToLocation:progress:overProgress:")) {
            delegate!.revealController(self, panGestureEndedToLocation: xLocation, progress: dragProgress, overProgress: overProgress)
        }
        else if delegate!.respondsToSelector(Selector("revealController:panGestureEndedToLocation:progress:")) {
            delegate!.revealController(self, panGestureEndedToLocation: xLocation, progress: dragProgress)
        }
        
        if delegate!.respondsToSelector(#selector(self.revealControllerPanGestureEnded)) {
            delegate!.revealControllerPanGestureEnded(self)
        }
    }
    // MARK: - Symetry
    
    func _getRevealWidth(pRevealWidth: CGFloat, revealOverDraw pRevealOverdraw: CGFloat, forSymetry symetry: Int) {
        if symetry < 0 {
            pRevealWidth = rightViewRevealWidth, pRevealOverdraw = rightViewRevealOverdraw
        }
        else {
            pRevealWidth = rearViewRevealWidth, pRevealOverdraw = rearViewRevealOverdraw
        }
        if pRevealWidth < 0 {
            pRevealWidth = contentView.bounds.size.width + pRevealWidth
        }
    }
    
    func _getBounceBack(pBounceBack: Bool, pStableDrag: Bool, forSymetry symetry: Int) {
        if symetry < 0 {
            pBounceBack = bounceBackOnLeftOverdraw, pStableDrag = stableDragOnLeftOverdraw
        }
        else {
            pBounceBack = bounceBackOnOverdraw, pStableDrag = stableDragOnOverdraw
        }
    }
    
    func _getAdjustedFrontViewPosition(frontViewPosition: FrontViewPosition, forSymetry symetry: Int) {
        if symetry < 0 {
            frontViewPosition = .Left + symetry * (frontViewPosition - .Left)
        }
    }
    
    func _getDragLocationx(xLocation: CGFloat, progress: CGFloat) {
        var frontView = contentView.frontView
        xLocation = frontView.frame.origin.x
        var symetry = xLocation < 0 ? -1 : 1
        var xWidth: CGFloat = symetry < 0 ? rightViewRevealWidth : rearViewRevealWidth
        if xWidth < 0 {
            xWidth = contentView.bounds.size.width + xWidth
        }
        progress = xLocation / xWidth * symetry
    }
    
    func _getDragLocation(xLocation: CGFloat, progress: CGFloat, overdrawProgress overProgress: CGFloat) {
        var frontView = contentView.frontView
        xLocation = frontView.frame.origin.x
        var symetry = xLocation < 0 ? -1 : 1
        var xWidth: CGFloat = symetry < 0 ? rightViewRevealWidth : rearViewRevealWidth
        var xOverWidth: CGFloat = symetry < 0 ? rightViewRevealOverdraw : rearViewRevealOverdraw
        if xWidth < 0 {
            xWidth = contentView.bounds.size.width + xWidth
        }
        progress = xLocation * symetry / xWidth
        overProgress = (xLocation * symetry - xWidth) / xOverWidth
    }
    // MARK: - Deferred block execution queue
    // Define a convenience macro to enqueue single statements
    //#define _enqueue(code) [self _enqueueBlock:^{code;}];
    // Defers the execution of the passed in block until a paired _dequeue call is received,
    // or executes the block right away if no pending requests are present.
    
    func _enqueueBlock(block: () -> Void) {
        animationQueue.insert(block, atIndex: 0)
        if animationQueue.count == 1 {
            block()
        }
    }
    // Removes the top most block in the queue and executes the following one if any.
    // Calls to this method must be paired with calls to _enqueueBlock, particularly it may be called
    // from within a block passed to _enqueueBlock to remove itself when done with animations.
    
    func _dequeue() {
        animationQueue.removeLast()
        if animationQueue.count > 0 {
            var block = animationQueue.last!
            block()
        }
    }
    // MARK: - Gesture Delegate
    
    override func gestureRecognizerShouldBegin(recognizer: UIGestureRecognizer) -> Bool {
        // only allow gesture if no previous request is in process
        if animationQueue.count == 0 {
            if recognizer == panGestureRecognizer {
                return self._panGestureShouldBegin()
            }
            if recognizer == tapGestureRecognizer {
                return self._tapGestureShouldBegin()
            }
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            if delegate!.respondsToSelector(Selector("revealController:panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:")) {
                if delegate!.revealController(self, panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer) != false {
                    return true
                }
            }
        }
        if gestureRecognizer == tapGestureRecognizer {
            if delegate!.respondsToSelector(Selector("revealController:tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:")) {
                if delegate!.revealController(self, tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer) != false {
                    return true
                }
            }
        }
        return false
    }
    
    func _tapGestureShouldBegin() -> Bool {
        if frontViewPosition == .Left || frontViewPosition == .RightMostRemoved || frontViewPosition == .LeftSideMostRemoved {
            return false
        }
        // forbid gesture if the following delegate is implemented and returns NO
        if delegate!.respondsToSelector(#selector(self.revealControllerTapGestureShouldBegin)) {
            if delegate!.revealControllerTapGestureShouldBegin(self) == false {
                return false
            }
        }
        return true
    }
    
    func _panGestureShouldBegin() -> Bool {
        // forbid gesture if the initial translation is not horizontal
        var recognizerView = panGestureRecognizer.view!
        var translation = panGestureRecognizer.translationInView(recognizerView)
        //        NSLog( @"translation:%@", NSStringFromCGPoint(translation) );
        //    if ( fabs(translation.y/translation.x) > 1 )
        //        return NO;
        // forbid gesture if the following delegate is implemented and returns NO
        if delegate!.respondsToSelector(#selector(self.revealControllerPanGestureShouldBegin)) {
            if delegate!.revealControllerPanGestureShouldBegin(self) == false {
                return false
            }
        }
        var xLocation: CGFloat = panGestureRecognizer.locationInView(recognizerView).x
        var width: CGFloat = recognizerView.bounds.size.width
        var draggableBorderAllowing = (/*_frontViewPosition != FrontViewPositionLeft ||*/
            draggableBorderWidth == 0.0 || (rearViewController && xLocation <= draggableBorderWidth) || (rightViewController && xLocation >= (width - draggableBorderWidth)))
        var translationForbidding = (frontViewPosition == .Left && (rearViewController == nil && translation.x > 0) || (rightViewController == nil && translation.x < 0))
        // allow gesture only within the bounds defined by the draggableBorderWidth property
        return draggableBorderAllowing && !translationForbidding
    }
    // MARK: - Gesture Based Reveal
    
    func _handleTapGesture(recognizer: UITapGestureRecognizer) {
        var duration = toggleAnimationDuration
        self._setFrontViewPosition(.Left, withDuration: duration)
    }
    
    func _handleRevealGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            self._handleRevealGestureStateBeganWithRecognizer(recognizer)
        case .Changed:
            self._handleRevealGestureStateChangedWithRecognizer(recognizer)
        case .Ended:
            self._handleRevealGestureStateEndedWithRecognizer(recognizer)
        case .Cancelled:
            //case UIGestureRecognizerStateFailed:
            self._handleRevealGestureStateCancelledWithRecognizer(recognizer)
        default:
            break
        }
        
    }
    
    func _handleRevealGestureStateBeganWithRecognizer(recognizer: UIPanGestureRecognizer) {
        // we know that we will not get here unless the animationQueue is empty because the recognizer
        // delegate prevents it, however we do not want any forthcoming programatic actions to disturb
        // the gesture, so we just enqueue a dummy block to ensure any programatic acctions will be
        // scheduled after the gesture is completed
        self._enqueueBlock({() -> Void in
        })
        // <-- dummy block
        // we store the initial position and initialize a target position
        self.panInitialFrontPosition = frontViewPosition
        // we disable user interactions on the views, however programatic accions will still be
        // enqueued to be performed after the gesture completes
        self._disableUserInteraction()
        self._notifyPanGestureBegan()
    }
    
    func _handleRevealGestureStateChangedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        var translation: CGFloat = recognizer.translationInView(contentView).x
        var baseLocation: CGFloat = contentView.frontLocationForPosition(panInitialFrontPosition)
        var xLocation: CGFloat = baseLocation + translation
        if xLocation < 0 {
            if rightViewController == nil {
                xLocation = 0
            }
            self._rightViewDeploymentForNewFrontViewPosition(.LeftSide)()
            self._rearViewDeploymentForNewFrontViewPosition(.LeftSide)()
        }
        if xLocation > 0 {
            if rearViewController == nil {
                xLocation = 0
            }
            self._rightViewDeploymentForNewFrontViewPosition(.Right)()
            self._rearViewDeploymentForNewFrontViewPosition(.Right)()
        }
        contentView.dragFrontViewToXLocation(xLocation)
        self._notifyPanGestureMoved()
    }
    
    func _handleRevealGestureStateEndedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        var frontView = contentView.frontView
        var xLocation: CGFloat = frontView.frame.origin.x
        var velocity: CGFloat = recognizer.velocityInView(contentView).x
        //NSLog( @"Velocity:%1.4f", velocity);
        // depending on position we compute a simetric replacement of widths and positions
        var symetry = xLocation < 0 ? -1 : 1
        // simetring computing of widths
        var revealWidth: CGFloat
        var revealOverdraw: CGFloat
        var bounceBack: Bool
        var stableDrag: Bool
        self._getRevealWidth(revealWidth, revealOverDraw: revealOverdraw, forSymetry: symetry)
        self._getBounceBack(bounceBack, pStableDrag: stableDrag, forSymetry: symetry)
        // simetric replacement of position
        xLocation = xLocation * symetry
        // initially we assume drag to left and default duration
        var frontViewPosition = .Left
        var duration = toggleAnimationDuration
        // Velocity driven change:
        if abs(velocity) > quickFlickVelocity {
            // we may need to set the drag position and to adjust the animation duration
            var journey: CGFloat = xLocation
            if velocity * symetry > 0.0 {
                frontViewPosition = .Right
                journey = revealWidth - xLocation
                if xLocation > revealWidth {
                    if !bounceBack && stableDrag {
                        frontViewPosition = .RightMost
                        journey = revealWidth + revealOverdraw - xLocation
                    }
                }
            }
            duration = abs(journey / velocity)
        }
        else {
            // we may need to set the drag position
            if xLocation > revealWidth * 0.5 {
                frontViewPosition = .Right
                if xLocation > revealWidth {
                    if bounceBack {
                        frontViewPosition = .Left
                    }
                    else if stableDrag && xLocation > revealWidth + revealOverdraw * 0.5 {
                        frontViewPosition = .RightMost
                    }
                }
            }
        }
        // symetric replacement of frontViewPosition
        self._getAdjustedFrontViewPosition(frontViewPosition, forSymetry: symetry)
        // restore user interaction and animate to the final position
        self._restoreUserInteraction()
        self._notifyPanGestureEnded()
        self._setFrontViewPosition(frontViewPosition, withDuration: duration)
    }
    
    func _handleRevealGestureStateCancelledWithRecognizer(recognizer: UIPanGestureRecognizer) {
        self._restoreUserInteraction()
        self._notifyPanGestureEnded()
        self._dequeue()
    }
    // MARK: Enqueued position and controller setup
    
    func _dispatchSetFrontViewPosition(frontViewPosition: FrontViewPosition, animated: Bool) {
        var duration = animated ? toggleAnimationDuration : 0.0
        weak var theSelf = self
        enqueue(theSelf!._setFrontViewPosition(frontViewPosition, withDuration: duration))
    }
    
    func _dispatchPushFrontViewController(newFrontViewController: UIViewController, animated: Bool) {
        var preReplacementPosition = .Left
        if frontViewPosition > .Left {
            preReplacementPosition = .RightMost
        }
        if frontViewPosition < .Left {
            preReplacementPosition = .LeftSideMost
        }
        var duration = animated ? toggleAnimationDuration : 0.0
        var firstDuration = duration
        var initialPosDif = abs(frontViewPosition - preReplacementPosition)
        if initialPosDif == 1 {
            firstDuration *= 0.8
        }
        else if initialPosDif == 0 {
            firstDuration = 0
        }
        
        weak var theSelf = self
        if animated {
            enqueue(theSelf!._setFrontViewPosition(preReplacementPosition, withDuration: firstDuration))
            enqueue(theSelf!._performTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: newFrontViewController, animated: false))
            enqueue(theSelf!._setFrontViewPosition(.Left, withDuration: duration))
        }
        else {
            enqueue(theSelf!._performTransitionOperation(SWRevealControllerOperationReplaceFrontController, withViewController: newFrontViewController, animated: false))
        }
    }
    
    func _dispatchTransitionOperation(operation: SWRevealControllerOperation, withViewController newViewController: UIViewController, animated: Bool) {
        weak var theSelf = self
        enqueue(theSelf!._performTransitionOperation(operation, withViewController: newViewController, animated: animated))
    }
    // MARK: Animated view controller deployment and layout
    // Primitive method for view controller deployment and animated layout to the given position.
    
    func _setFrontViewPosition(newPosition: FrontViewPosition, withDuration duration: NSTimeInterval) {
        var rearDeploymentCompletion = self._rearViewDeploymentForNewFrontViewPosition(newPosition)
        var rightDeploymentCompletion = self._rightViewDeploymentForNewFrontViewPosition(newPosition)
        var frontDeploymentCompletion = self._frontViewDeploymentForNewFrontViewPosition(newPosition)
        var animations = {() -> Void in
            // Calling this in the animation block causes the status bar to appear/dissapear in sync with our own animation
            self.setNeedsStatusBarAppearanceUpdate()
            // We call the layoutSubviews method on the contentView view and send a delegate, which will
            // occur inside of an animation block if any animated transition is being performed
            contentView.layoutSubviews()
            if delegate!.respondsToSelector(Selector("revealController:animateToPosition:")) {
                delegate!.revealController(self, animateToPosition: frontViewPosition)
            }
        }
        var completion = {(finished: Bool) -> Void in
            rearDeploymentCompletion()
            rightDeploymentCompletion()
            frontDeploymentCompletion()
            self._dequeue()
        }
        if duration > 0.0 {
            if toggleAnimationType == .EaseOut {
                UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseOut, animations: animations, completion: completion)
            }
            else {
                UIView.animateWithDuration(toggleAnimationDuration, delay: 0.0, usingSpringWithDamping: springDampingRatio, initialSpringVelocity: 1 / duration, options: [], animations: animations, completion: completion)
            }
        }
        else {
            animations()
            completion(true)
        }
    }
    // Primitive method for animated controller transition
    //- (void)_performTransitionToViewController:(UIViewController*)new operation:(SWRevealControllerOperation)operation animated:(BOOL)animated
    
    func _performTransitionOperation(operation: SWRevealControllerOperation, withViewController new: UIViewController, animated: Bool) {
        if delegate!.respondsToSelector(Selector("revealController:willAddViewController:forOperation:animated:")) {
            delegate!.revealController(self, willAddViewController: new, forOperation: operation, animated: animated)
        }
        var old: UIViewController? = nil
        var view: UIView? = nil
        if operation == SWRevealControllerOperationReplaceRearController {
            old = rearViewController, self.rearViewController = new, view = contentView.rearView
        }
        else if operation == SWRevealControllerOperationReplaceFrontController {
            old = frontViewController, self.frontViewController = new, view = contentView.frontView
        }
        else if operation == SWRevealControllerOperationReplaceRightController {
            old = rightViewController, self.rightViewController = new, view = contentView.rightView!
        }
        
        var completion = self._transitionFromViewController(old, toViewController: new, inView: view)
        var animationCompletion = {() -> Void in
            completion()
            if delegate!.respondsToSelector(Selector("revealController:didAddViewController:forOperation:animated:")) {
                delegate!.revealController(self, didAddViewController: new, forOperation: operation, animated: animated)
            }
            self._dequeue()
        }
        if animated {
            weak var animationController: UIViewControllerAnimatedTransitioning? = nil
            if delegate!.respondsToSelector(Selector("revealController:animationControllerForOperation:fromViewController:toViewController:")) {
                animationController = delegate!.revealController(self, animationControllerForOperation: operation, fromViewController: old, toViewController: new)
            }
            if animationController == nil {
                animationController = SWDefaultAnimationController(duration: replaceViewAnimationDuration)
            }
            var transitioningObject = SWContextTransitionObject(revealController: self, containerView: view, fromVC: old, toVC: new, completion: animationCompletion)
            if animationController!.transitionDuration(transitioningObject) > 0 {
                animationController!.animateTransition(transitioningObject)
            }
            else {
                animationCompletion()
            }
        }
        else {
            animationCompletion()
        }
    }
    // MARK: Position based view controller deployment
    // Deploy/Undeploy of the front view controller following the containment principles. Returns a block
    // that must be invoked on animation completion in order to finish deployment
    
    func _frontViewDeploymentForNewFrontViewPosition(newPosition: FrontViewPosition) -> () -> Void {
        if (rightViewController == nil && newPosition < .Left) || (rearViewController == nil && newPosition > .Left) {
            newPosition = .Left
        }
        var positionIsChanging = (frontViewPosition != newPosition)
        var appear = (frontViewPosition >= .RightMostRemoved || frontViewPosition <= .LeftSideMostRemoved || frontViewPosition == .None) && (newPosition < .RightMostRemoved && newPosition > .LeftSideMostRemoved)
        var disappear = (newPosition >= .RightMostRemoved || newPosition <= .LeftSideMostRemoved) && (frontViewPosition < .RightMostRemoved && frontViewPosition > .LeftSideMostRemoved && frontViewPosition != .None)
        if positionIsChanging {
            if delegate!.respondsToSelector(Selector("revealController:willMoveToPosition:")) {
                delegate!.revealController(self, willMoveToPosition: newPosition)
            }
        }
        self.frontViewPosition = newPosition
        var deploymentCompletion = self._deploymentForViewController(frontViewController, inView: contentView.frontView, appear: appear, disappear: disappear)
        var completion = {() -> Void in
            deploymentCompletion()
            if positionIsChanging {
                if delegate!.respondsToSelector(Selector("revealController:didMoveToPosition:")) {
                    delegate!.revealController(self, didMoveToPosition: newPosition)
                }
            }
        }
        return completion
    }
    // Deploy/Undeploy of the left view controller following the containment principles. Returns a block
    // that must be invoked on animation completion in order to finish deployment
    
    func _rearViewDeploymentForNewFrontViewPosition(newPosition: FrontViewPosition) -> () -> Void {
        if presentFrontViewHierarchically {
            newPosition = .Right
        }
        if rearViewController == nil && newPosition > .Left {
            newPosition = .Left
        }
        var appear = (rearViewPosition <= .Left || rearViewPosition == .None) && newPosition > .Left
        var disappear = newPosition <= .Left && (rearViewPosition > .Left && rearViewPosition != .None)
        if appear {
            contentView.prepareRearViewForPosition(newPosition)
        }
        self.rearViewPosition = newPosition
        var deploymentCompletion = self._deploymentForViewController(rearViewController, inView: contentView.rearView, appear: appear, disappear: disappear)
        var completion = {() -> Void in
            deploymentCompletion()
            if disappear {
                contentView.unloadRearView()
            }
        }
        return completion
    }
    // Deploy/Undeploy of the right view controller following the containment principles. Returns a block
    // that must be invoked on animation completion in order to finish deployment
    
    func _rightViewDeploymentForNewFrontViewPosition(newPosition: FrontViewPosition) -> () -> Void {
        if rightViewController == nil && newPosition < .Left {
            newPosition = .Left
        }
        var appear = (rightViewPosition >= .Left || rightViewPosition == .None) && newPosition < .Left
        var disappear = newPosition >= .Left && (rightViewPosition < .Left && rightViewPosition != .None)
        if appear {
            contentView.prepareRightViewForPosition(newPosition)
        }
        self.rightViewPosition = newPosition
        var deploymentCompletion = self._deploymentForViewController(rightViewController, inView: contentView.rightView!, appear: appear, disappear: disappear)
        var completion = {() -> Void in
            deploymentCompletion()
            if disappear {
                contentView.unloadRightView()
            }
        }
        return completion
    }
    
    func _deploymentForViewController(controller: UIViewController, inView view: UIView, appear: Bool, disappear: Bool) -> () -> Void {
        if appear {
            return self._deployForViewController(controller, inView: view)
        }
        if disappear {
            return self._undeployForViewController(controller)
        }
        return {() -> Void in
        }
    }
    // MARK: Containment view controller deployment and transition
    // Containment Deploy method. Returns a block to be invoked at the
    // animation completion, or right after return in case of non-animated deployment.
    
    func _deployForViewController(controller: UIViewController, inView view: UIView) -> () -> Void {
        if !controller || !view {
            return {() -> Void in
            }
        }
        var frame = view!.bounds
        var controllerView = controller.view
        controllerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        controllerView.frame = frame
        if (controllerView is UIScrollView) {
            var adjust = controller.automaticallyAdjustsScrollViewInsets
            if adjust {
                (controllerView as! AnyObject).contentInset = UIEdgeInsetsMake(statusBarAdjustment(contentView), 0, 0, 0)
            }
        }
        view!.addSubview(controllerView)
        var completionBlock = {() -> Void in
            // nothing to do on completion at this stage
        }
        return completionBlock
    }
    // Containment Undeploy method. Returns a block to be invoked at the
    // animation completion, or right after return in case of non-animated deployment.
    
    func _undeployForViewController(controller: UIViewController) -> () -> Void {
        if !controller {
            return {() -> Void in
            }
        }
        // nothing to do before completion at this stage
        var completionBlock = {() -> Void in
            controller.view.removeFromSuperview()
        }
        return completionBlock
    }
    // Containment Transition method. Returns a block to be invoked at the
    // animation completion, or right after return in case of non-animated transition.
    
    func _transitionFromViewController(fromController: UIViewController, toViewController toController: UIViewController, inView view: UIView) -> () -> Void {
        if fromController == toController {
            return {() -> Void in
            }
        }
        if toController {
            self.addChildViewController(toController)
        }
        var deployCompletion = self._deployForViewController(toController, inView: view)
        fromController.willMoveToParentViewController(nil)
        var undeployCompletion = self._undeployForViewController(fromController)
        var completionBlock = {() -> Void in
            undeployCompletion()
            fromController.removeFromParentViewController()
            deployCompletion()
            toController.didMoveToParentViewController(self)
        }
        return completionBlock
    }
    // Load any defined front/rear controllers from the storyboard
    // This method is intended to be overrided in case the default behavior will not meet your needs
    
    func loadStoryboardControllers() {
        if self.storyboard! && rearViewController == nil {
            //Try each segue separately so it doesn't break prematurely if either Rear or Right views are not used.
            do {
                self.performSegueWithIdentifier(SWSegueRearIdentifier, sender: nil)
            }             catch let exception {
            }
            do {
                self.performSegueWithIdentifier(SWSegueFrontIdentifier, sender: nil)
            }             catch let exception {
            }
            do {
                self.performSegueWithIdentifier(SWSegueRightIdentifier, sender: nil)
            }             catch let exception {
            }
        }
    }
    // MARK: state preservation / restoration
    
    class func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController {
        var vc: SWRevealViewController? = nil
        var sb = coder.decodeObjectForKey(UIStateRestorationViewControllerStoryboardKey)!
        if sb {
            vc = (sb.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController)
            vc!.restorationIdentifier! = identifierComponents.last!
            vc!.restorationClass = SWRevealViewController.self
        }
        return vc
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeDouble(rearViewRevealWidth, forKey: "_rearViewRevealWidth")
        coder.encodeDouble(rearViewRevealOverdraw, forKey: "_rearViewRevealOverdraw")
        coder.encodeDouble(rearViewRevealDisplacement, forKey: "_rearViewRevealDisplacement")
        coder.encodeDouble(rightViewRevealWidth, forKey: "_rightViewRevealWidth")
        coder.encodeDouble(rightViewRevealOverdraw, forKey: "_rightViewRevealOverdraw")
        coder.encodeDouble(rightViewRevealDisplacement, forKey: "_rightViewRevealDisplacement")
        coder.encodeBool(bounceBackOnOverdraw, forKey: "_bounceBackOnOverdraw")
        coder.encodeBool(bounceBackOnLeftOverdraw, forKey: "_bounceBackOnLeftOverdraw")
        coder.encodeBool(stableDragOnOverdraw, forKey: "_stableDragOnOverdraw")
        coder.encodeBool(stableDragOnLeftOverdraw, forKey: "_stableDragOnLeftOverdraw")
        coder.encodeBool(presentFrontViewHierarchically, forKey: "_presentFrontViewHierarchically")
        coder.encodeDouble(quickFlickVelocity, forKey: "_quickFlickVelocity")
        coder.encodeDouble(toggleAnimationDuration, forKey: "_toggleAnimationDuration")
        coder.encodeInteger(toggleAnimationType, forKey: "_toggleAnimationType")
        coder.encodeDouble(springDampingRatio, forKey: "_springDampingRatio")
        coder.encodeDouble(replaceViewAnimationDuration, forKey: "_replaceViewAnimationDuration")
        coder.encodeDouble(frontViewShadowRadius, forKey: "_frontViewShadowRadius")
        coder.encodeCGSize(frontViewShadowOffset, forKey: "_frontViewShadowOffset")
        coder.encodeDouble(frontViewShadowOpacity, forKey: "_frontViewShadowOpacity")
        coder.encodeObject(frontViewShadowColor, forKey: "_frontViewShadowColor")
        coder.encodeBool(userInteractionStore, forKey: "_userInteractionStore")
        coder.encodeDouble(draggableBorderWidth, forKey: "_draggableBorderWidth")
        coder.encodeBool(clipsViewsToBounds, forKey: "_clipsViewsToBounds")
        coder.encodeBool(extendsPointInsideHit, forKey: "_extendsPointInsideHit")
        coder.encodeObject(rearViewController, forKey: "_rearViewController")
        coder.encodeObject(frontViewController, forKey: "_frontViewController")
        coder.encodeObject(rightViewController, forKey: "_rightViewController")
        coder.encodeInteger(frontViewPosition, forKey: "_frontViewPosition")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        self.rearViewRevealWidth = coder.decodeDoubleForKey("_rearViewRevealWidth")
        self.rearViewRevealOverdraw = coder.decodeDoubleForKey("_rearViewRevealOverdraw")
        self.rearViewRevealDisplacement = coder.decodeDoubleForKey("_rearViewRevealDisplacement")
        self.rightViewRevealWidth = coder.decodeDoubleForKey("_rightViewRevealWidth")
        self.rightViewRevealOverdraw = coder.decodeDoubleForKey("_rightViewRevealOverdraw")
        self.rightViewRevealDisplacement = coder.decodeDoubleForKey("_rightViewRevealDisplacement")
        self.bounceBackOnOverdraw = coder.decodeBoolForKey("_bounceBackOnOverdraw")
        self.bounceBackOnLeftOverdraw = coder.decodeBoolForKey("_bounceBackOnLeftOverdraw")
        self.stableDragOnOverdraw = coder.decodeBoolForKey("_stableDragOnOverdraw")
        self.stableDragOnLeftOverdraw = coder.decodeBoolForKey("_stableDragOnLeftOverdraw")
        self.presentFrontViewHierarchically = coder.decodeBoolForKey("_presentFrontViewHierarchically")
        self.quickFlickVelocity = coder.decodeDoubleForKey("_quickFlickVelocity")
        self.toggleAnimationDuration = coder.decodeDoubleForKey("_toggleAnimationDuration")
        self.toggleAnimationType = coder.decodeIntegerForKey("_toggleAnimationType")
        self.springDampingRatio = coder.decodeDoubleForKey("_springDampingRatio")
        self.replaceViewAnimationDuration = coder.decodeDoubleForKey("_replaceViewAnimationDuration")
        self.frontViewShadowRadius = coder.decodeDoubleForKey("_frontViewShadowRadius")
        self.frontViewShadowOffset = coder.decodeCGSizeForKey("_frontViewShadowOffset")
        self.frontViewShadowOpacity = coder.decodeDoubleForKey("_frontViewShadowOpacity")
        self.frontViewShadowColor = coder.decodeObjectForKey("_frontViewShadowColor")!
        self.userInteractionStore = coder.decodeBoolForKey("_userInteractionStore")
        self.animationQueue = [AnyObject]()
        self.draggableBorderWidth = coder.decodeDoubleForKey("_draggableBorderWidth")
        self.clipsViewsToBounds = coder.decodeBoolForKey("_clipsViewsToBounds")
        self.extendsPointInsideHit = coder.decodeBoolForKey("_extendsPointInsideHit")
        self.rearViewController = coder.decodeObjectForKey("_rearViewController")!
        self.frontViewController = coder.decodeObjectForKey("_frontViewController")!
        self.rightViewController = coder.decodeObjectForKey("_rightViewController")!
        self.frontViewPosition = coder.decodeIntForKey("_frontViewPosition")
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func applicationFinishedRestoringState() {
        // nothing to do at this stage
    }
    
    func _getRevealWidth(pRevealWidth: CGFloat, revealOverDraw pRevealOverdraw: CGFloat, forSymetry symetry: Int) {
    }
    
    func _getBounceBack(pBounceBack: Bool, pStableDrag: Bool, forSymetry symetry: Int) {
    }
    
    func _getAdjustedFrontViewPosition(frontViewPosition: FrontViewPosition, forSymetry symetry: Int) {
    }
}
// MARK: - SWRevealViewControllerDelegate Protocol
enum SWRevealControllerOperation : Int {
    case None
    case ReplaceRearController
    case ReplaceFrontController
    case ReplaceRightController
}

protocol SWRevealViewControllerDelegate: NSObject {
    // The following delegate methods will be called before and after the front view moves to a position
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition)
    
    func revealController(revealController: SWRevealViewController, didMoveToPosition position: FrontViewPosition)
    // This will be called inside the reveal animation, thus you can use it to place your own code that will be animated in sync
    
    func revealController(revealController: SWRevealViewController, animateToPosition position: FrontViewPosition)
    // Implement this to return NO when you want the pan gesture recognizer to be ignored
    
    func revealControllerPanGestureShouldBegin(revealController: SWRevealViewController) -> Bool
    // Implement this to return NO when you want the tap gesture recognizer to be ignored
    
    func revealControllerTapGestureShouldBegin(revealController: SWRevealViewController) -> Bool
    // Implement this to return YES if you want other gesture recognizer to share touch events with the pan gesture
    
    func revealController(revealController: SWRevealViewController, panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    // Implement this to return YES if you want other gesture recognizer to share touch events with the tap gesture
    
    func revealController(revealController: SWRevealViewController, tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    // Called when the gestureRecognizer began and ended
    
    func revealControllerPanGestureBegan(revealController: SWRevealViewController)
    
    func revealControllerPanGestureEnded(revealController: SWRevealViewController)
    // The following methods provide a means to track the evolution of the gesture recognizer.
    // The 'location' parameter is the X origin coordinate of the front view as the user drags it
    // The 'progress' parameter is a number ranging from 0 to 1 indicating the front view location relative to the
    //   rearRevealWidth or rightRevealWidth. 1 is fully revealed, dragging ocurring in the overDraw region will result in values above 1.
    // The 'overProgress' parameter is a number ranging from 0 to 1 indicating the front view location relative to the
    //   overdraw region. 0 is fully revealed, 1 is fully overdrawn. Negative values occur inside the normal reveal region
    
    func revealController(revealController: SWRevealViewController, panGestureBeganFromLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat)
    
    func revealController(revealController: SWRevealViewController, panGestureMovedToLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat)
    
    func revealController(revealController: SWRevealViewController, panGestureEndedToLocation location: CGFloat, progress: CGFloat, overProgress: CGFloat)
    // Notification of child controller replacement
    
    func revealController(revealController: SWRevealViewController, willAddViewController viewController: UIViewController, forOperation operation: SWRevealControllerOperation, animated: Bool)
    
    func revealController(revealController: SWRevealViewController, didAddViewController viewController: UIViewController, forOperation operation: SWRevealControllerOperation, animated: Bool)
    // Support for custom transition animations while replacing child controllers. If implemented, it will be fired in response
    // to calls to 'setXXViewController' methods
    
    func revealController(revealController: SWRevealViewController, animationControllerForOperation operation: SWRevealControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning
    // DEPRECATED - The following delegate methods will be removed some time in the future
    
    func revealController(revealController: SWRevealViewController, panGestureBeganFromLocation location: CGFloat, progress: CGFloat)
    // (DEPRECATED)
    
    func revealController(revealController: SWRevealViewController, panGestureMovedToLocation location: CGFloat, progress: CGFloat)
    // (DEPRECATED)
    
    func revealController(revealController: SWRevealViewController, panGestureEndedToLocation location: CGFloat, progress: CGFloat)
}
// MARK: - UIViewController(SWRevealViewController) Category
// A category of UIViewController to let childViewControllers easily access their parent SWRevealViewController
extension UIViewController {
    func revealViewController() -> SWRevealViewController {
        var parent = self
        var revealClass = SWRevealViewController.self
        while nil != (parent = parent.parentViewController!) && !(parent is revealClass) {
            
        }
        return (parent as! AnyObject)
    }
}
// MARK: - StoryBoard support Classes
/* StoryBoard support */
// String identifiers to be applied to segues on a storyboard
let SWSegueRearIdentifier = ""

// this is @"sw_rear"
let SWSegueFrontIdentifier = ""

// this is @"sw_front"
let SWSegueRightIdentifier = ""

// this is @"sw_right"
/* This will allow the class to be defined on a storyboard */
// Use this along with one of the above segue identifiers to segue to the initial state
class SWRevealViewControllerSegueSetController: UIStoryboardSegue {
    
    
    override func perform() {
        var operation = .None
        var identifier = self.identifier
        var rvc = self.sourceViewController
        var dvc = self.destinationViewController
        if (identifier == SWSegueFrontIdentifier) {
            operation = .ReplaceFrontController
        }
        else if (identifier == SWSegueRearIdentifier) {
            operation = .ReplaceRearController
        }
        else if (identifier == SWSegueRightIdentifier) {
            operation = .ReplaceRightController
        }
        
        if operation != .None {
            rvc._performTransitionOperation(operation, withViewController: dvc, animated: false)
        }
    }
}
// Use this to push a view controller
class SWRevealViewControllerSeguePushController: UIStoryboardSegue {
    
    
    override func perform() {
        var rvc = self.sourceViewController.revealViewController()
        var dvc = self.destinationViewController
        rvc.pushFrontViewController(dvc, animated: true)
    }
}
//#pragma mark - SWRevealViewControllerSegue (DEPRECATED)
//
//@interface SWRevealViewControllerSegue : UIStoryboardSegue     // DEPRECATED: USE SWRevealViewControllerSegueSetController instead
//@property (nonatomic, strong) void(^performBlock)( SWRevealViewControllerSegue* segue, UIViewController* svc, UIViewController* dvc );
//@end
/*
 
 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Early code inspired on a similar class by Philip Kluz (Philip.Kluz@zuui.org)
 
 */
import QuartzCore
// MARK: - StatusBar Helper Function
// computes the required offset adjustment due to the status bar for the passed in view,
// it will return the statusBar height if view fully overlaps the statusBar, otherwise returns 0.0f
func statusBarAdjustment(view: UIView) -> CGFloat {
    var adjustment: CGFloat = 0.0
    var app = UIApplication.sharedApplication()
    var viewFrame = view!.convertRect(view!.bounds, toView: app.keyWindow)
    var statusBarFrame = app.statusBarFrame
    if CGRectIntersectsRect(viewFrame, statusBarFrame) {
        adjustment = fminf(statusBarFrame.size.width, statusBarFrame.size.height)
    }
    return adjustment
}

// MARK: - SWRevealView Class
class SWRevealView: UIView {
    var c: SWRevealViewController!
    
    private(set) var rearView: UIView!
    private(set) var rightView: UIView!
    private(set) var frontView: UIView!
    var disableLayout = false
    
    func scaledValue(v1: CGFloat, min2: CGFloat, max2: CGFloat, min1: CGFloat, max1: CGFloat) -> CGFloat {
        var result: CGFloat = min2 + (v1 - min1) * (max2 - min2) / (max1 - min1)
        if result != result {
            return min2
        }
        // nan
        if result < min2 {
            return min2
        }
        if result > max2 {
            return max2
        }
        return result
    }
    
    override init(frame: CGRect, controller: SWRevealViewController) {
        super.init(frame: frame)
        
        self.c = controller
        var bounds = self.bounds
        self.frontView = UIView(frame: bounds)
        self.frontView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.reloadShadow()
        self.addSubview(frontView)
        
    }
    
    func reloadShadow() {
        var frontViewLayer = frontView.layer
        frontViewLayer.shadowColor = c.frontViewShadowColor.CGColor
        frontViewLayer.shadowOpacity = c.frontViewShadowOpacity
        frontViewLayer.shadowOffset = c.frontViewShadowOffset
        frontViewLayer.shadowRadius = c.frontViewShadowRadius
    }
    
    func hierarchycalFrameAdjustment(frame: CGRect) -> CGRect {
        if c.presentFrontViewHierarchically {
            var dummyBar = UINavigationBar()
            var barHeight: CGFloat = dummyBar.sizeThatFits(CGSizeMake(100, 100)).height
            var offset: CGFloat = barHeight + statusBarAdjustment(self)
            frame.origin.y += offset
            frame.size.height -= offset
        }
        return frame
    }
    
    func prepareRearViewForPosition(newPosition: FrontViewPosition) {
        if rearView == nil {
            self.rearView = UIView(frame: self.bounds)
            self.rearView.autoresizingMask =             /*UIViewAutoresizingFlexibleWidth|*/
                .FlexibleHeight
            self.insertSubview(rearView, belowSubview: frontView)
        }
        var xLocation: CGFloat = self.frontLocationForPosition(c.frontViewPosition)
        self._layoutRearViewsForLocation(xLocation)
        self._prepareForNewPosition(newPosition)
    }
    
    func prepareRightViewForPosition(newPosition: FrontViewPosition) {
        if rightView == nil {
            self.rightView = UIView(frame: self.bounds)
            self.rightView.autoresizingMask =             /*UIViewAutoresizingFlexibleWidth|*/
                .FlexibleHeight
            self.insertSubview(rightView, belowSubview: frontView)
        }
        var xLocation: CGFloat = self.frontLocationForPosition(c.frontViewPosition)
        self._layoutRearViewsForLocation(xLocation)
        self._prepareForNewPosition(newPosition)
    }
    
    func unloadRearView() {
        rearView.removeFromSuperview()
        self.rearView = nil
    }
    
    func unloadRightView() {
        rightView.removeFromSuperview()
        self.rightView = nil
    }
    
    func frontLocationForPosition(frontViewPosition: FrontViewPosition) -> CGFloat {
        var revealWidth: CGFloat
        var revealOverdraw: CGFloat
        var location: CGFloat = 0.0
        var symetry = frontViewPosition < .Left ? -1 : 1
        c._getRevealWidth(revealWidth, revealOverDraw: revealOverdraw, forSymetry: symetry)
        c._getAdjustedFrontViewPosition(frontViewPosition, forSymetry: symetry)
        if frontViewPosition == .Right {
            location = revealWidth
        }
        else if frontViewPosition > .Right {
            location = revealWidth + revealOverdraw
        }
        
        return location * symetry
    }
    
    func dragFrontViewToXLocation(xLocation: CGFloat) {
        var bounds = self.bounds
        xLocation = self._adjustedDragLocationForLocation(xLocation)
        self._layoutRearViewsForLocation(xLocation)
        var frame = CGRectMake(xLocation, 0.0, bounds.size.width, bounds.size.height)
        self.frontView.frame = self.hierarchycalFrameAdjustment(frame)
    }
}
func layoutSubviews() {
    if disableLayout {
        return
    }
    var bounds = self.bounds
    var position = c.frontViewPosition
    var xLocation: CGFloat = self.frontLocationForPosition(position)
    // set rear view frames
    self._layoutRearViewsForLocation(xLocation)
    // set front view frame
    var frame = CGRectMake(xLocation, 0.0, bounds.size.width, bounds.size.height)
    self.frontView.frame = self.hierarchycalFrameAdjustment(frame)
    // setup front view shadow path if needed (front view loaded and not removed)
    var frontViewController = c.frontViewController
    var viewLoaded = frontViewController != nil && frontViewController.isViewLoaded()
    var viewNotRemoved = position > .LeftSideMostRemoved && position < .RightMostRemoved
    var shadowBounds = viewLoaded && viewNotRemoved ? frontView.bounds : CGRectZero
    var shadowPath = UIBezierPath(rect: shadowBounds)
    self.frontView.layer.shadowPath = shadowPath.CGPath
}

func event() {
    var isInside = super.pointInside(point, withEvent: event)
    if c.extendsPointInsideHit {
        if !isInside && rearView && c.rearViewController.isViewLoaded() {
            var pt = self.convertPoint(point, toView: rearView)
            isInside = rearView.pointInside(pt, withEvent: event)
        }
        if !isInside && frontView && c.frontViewController.isViewLoaded() {
            var pt = self.convertPoint(point, toView: frontView)
            isInside = frontView.pointInside(pt, withEvent: event)
        }
        if !isInside && rightView && c.rightViewController.isViewLoaded() {
            var pt = self.convertPoint(point, toView: rightView)
            isInside = rightView.pointInside(pt, withEvent: event)
        }
    }
    return isInside
}

func event() {
    var isInside = super.pointInside(point, withEvent: event)
    if !isInside && c.extendsPointInsideHit {
        var testViews = [rearView, frontView, rightView]
        var testControllers = [c.rearViewController, c.frontViewController, c.rightViewController]
        for i in 0..<3 {
            if testViews[i] && testControllers[i].isViewLoaded() {
                var pt = self.convertPoint(point, toView: testViews[i])
                isInside = testViews[i].pointInside(pt, withEvent: event)
            }
        }
    }
    return isInside
}

func xLocation() {
    var bounds = self.bounds
    var rearRevealWidth: CGFloat = c.rearViewRevealWidth
    if rearRevealWidth < 0 {
        rearRevealWidth = bounds.size.width + c.rearViewRevealWidth
    }
    var rearXLocation: CGFloat = scaledValue(xLocation, -c.rearViewRevealDisplacement, 0, 0, rearRevealWidth)
    var rearWidth: CGFloat = rearRevealWidth + c.rearViewRevealOverdraw
    self.rearView.frame = CGRectMake(rearXLocation, 0.0, rearWidth, bounds.size.height)
    var rightRevealWidth: CGFloat = c.rightViewRevealWidth
    if rightRevealWidth < 0 {
        rightRevealWidth = bounds.size.width + c.rightViewRevealWidth
    }
    var rightXLocation: CGFloat = scaledValue(xLocation, 0, c.rightViewRevealDisplacement, -rightRevealWidth, 0)
    var rightWidth: CGFloat = rightRevealWidth + c.rightViewRevealOverdraw
    self.rightView.frame = CGRectMake(bounds.size.width - rightWidth + rightXLocation, 0.0, rightWidth, bounds.size.height)
}

var newPosition = ()

var symetry = newPosition < .Left ? -1 : 1

var subViews = self.subviews

var rearIndex = (subViews as NSArray).indexOfObjectIdenticalTo(rearView)

var rightIndex = (subViews as NSArray).indexOfObjectIdenticalTo(rightView)

func x() {
    var result: CGFloat
    var revealWidth: CGFloat
    var revealOverdraw: CGFloat
    var bounceBack: Bool
    var stableDrag: Bool
    var position = c.frontViewPosition
    var symetry = x < 0 ? -1 : 1
    c._getRevealWidth(revealWidth, revealOverDraw: revealOverdraw, forSymetry: symetry)
    c._getBounceBack(bounceBack, pStableDrag: stableDrag, forSymetry: symetry)
    var stableTrack = !bounceBack || stableDrag || position == .RightMost || position == .LeftSideMost
    if stableTrack {
        revealWidth += revealOverdraw
        revealOverdraw = 0.0
    }
    x = x * symetry
    if x <= revealWidth {
        result = x
    }
    else if x <= revealWidth + 2 * revealOverdraw {
        result = revealWidth + (x - revealWidth) / 2
    }
    else {
        result = revealWidth + revealOverdraw
    }
    
    // keep at the rightMost location.
    return result * symetry
}

// MARK: - SWContextTransitioningObject
class SWContextTransitionObject: NSObject, UIViewControllerContextTransitioning {
    var revealVC: SWRevealViewController!
    var view: UIView!
    var toVC: UIViewController!
    var fromVC: UIViewController!
    var completion = Void()
    
    
    
    override init(revealController revealVC: SWRevealViewController, containerView view: UIView, fromVC: UIViewController, toVC: UIViewController, completion: () -> Void) {
        super.init()
        
        self.revealVC = revealVC
        self.view = view
        self.fromVC = fromVC
        self.toVC = toVC
        self.completion = completion
        
    }
    
    override func containerView() -> UIView? {
        return view
    }
    
    override func isAnimated() -> Bool {
        return true
    }
    
    override func isInteractive() -> Bool {
        return false
        // not supported
    }
    
    override func transitionWasCancelled() -> Bool {
        return false
        // not supported
    }
    
    override func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }
    
    override func presentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationNone
        // not applicable
    }
    
    override func updateInteractiveTransition(percentComplete: CGFloat) {
        // not supported
    }
    
    override func finishInteractiveTransition() {
        // not supported
    }
    
    override func cancelInteractiveTransition() {
        // not supported
    }
    
    override func completeTransition(didComplete: Bool) {
        completion()
    }
    
    override func viewControllerForKey(key: String) -> UIViewController {
        if (key == UITransitionContextFromViewControllerKey) {
            return fromVC
        }
        if (key == UITransitionContextToViewControllerKey) {
            return toVC
        }
        return nil
    }
    
    override func viewForKey(key: String) -> UIView? {
        return nil
    }
    
    override func initialFrameForViewController(vc: UIViewController) -> CGRect {
        return view.bounds
    }
    
    override func finalFrameForViewController(vc: UIViewController) -> CGRect {
        return view.bounds
    }
}
// MARK: - SWDefaultAnimationController Class
class SWDefaultAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var duration = NSTimeInterval()
    
    
    
    override init(duration: NSTimeInterval) {
        super.init()
        
        self.duration = duration
        
    }
    
    override func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        if fromViewController {
            UIView.transitionFromView(fromViewController.view, toView: toViewController.view, duration: duration, options: [.TransitionCrossDissolve, .OverrideInheritedOptions], completion: {(finished: Bool) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
        else {
            // tansitionFromView does not correctly handle the case where the fromView is nil (at least on iOS7) it just pops up the toView view with no animation,
            // so in such case we replace the crossDissolve animation by a simple alpha animation on the appearing view
            var toView = toViewController.view
            var alpha: CGFloat = toView.alpha
            toView.alpha = 0
            UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {() -> Void in
                toView.alpha = alpha
            }, completion: {(finished: Bool) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
// MARK: - SWRevealViewControllerPanGestureRecognizer
import UIKit
class SWRevealViewControllerPanGestureRecognizer: UIPanGestureRecognizer {
    var dragging = false
    var beginPoint = CGPoint.zero
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        var touch = touches.first!
        self.beginPoint = touch.locationInView(self.view)
        self.dragging = false
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if dragging || self.state == .Failed {
            return
        }
        let kDirectionPanThreshold: CGFloat = 5
        var touch = touches.first!
        var nowPoint = touch.locationInView(self.view)
        if abs(nowPoint.x - beginPoint.x) > kDirectionPanThreshold {
            self.dragging = true
        }
        else if abs(nowPoint.y - beginPoint.y) > kDirectionPanThreshold {
            self.state = .Failed
        }
        
    }
}
// MARK: - SWRevealViewController Class

// MARK: - UIViewController(SWRevealViewController) Category

// MARK: - SWRevealViewControllerSegueSetController segue identifiers
let SWSegueRearIdentifier = "sw_rear"

let SWSegueFrontIdentifier = "sw_front"

let SWSegueRightIdentifier = "sw_right"

// MARK: - SWRevealViewControllerSegueSetController class

// MARK: - SWRevealViewControllerSeguePushController class
