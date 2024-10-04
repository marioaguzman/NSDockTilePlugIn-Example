//
//  SherlockDockTilePlugIn.swift
//  SherlockDockTilePlugIn
//
//  Created by Mario Guzman on 10/3/24.
//

import AppKit
import Combine

class SherlockDockTilePlugIn: NSObject, NSDockTilePlugIn {

    private var appearancePublisher: AnyCancellable? = nil
    private enum DockTileImage: String {
        case light = "DockTile"
        case dark  = "DockTile-Dark"
    }

    /// The associated Dock icon images will be provided in this bundle, not the host application's
    /// bundle. This is a convenience property to get the appropriate icon when it needs to change.
    private var dockTilePlugInBundle: Bundle = {
        Bundle(for: SherlockDockTilePlugIn.self)
    }()

    /// When you drag this app into the Dock, it will call this function, `setDockTile(_ :)` with
    /// a non-nil value for its `dockTile` parameter. When you drag out this app's icon out of the
    /// Dock, it will call this again with the `dockTile` parameter set to `nil`.
    /// Perform any setup when `dockTile` has a value and any cleanup when it is `nil`.
    func setDockTile(_ dockTile: NSDockTile?) {

        if  let dockTile = dockTile {
            
            // A DockTile was provided by the system. Perform setup to listen
            // for appearance changes and system launch/termination events.
            
            // Start with an initial update to match the system immediately.
            updateTile(tile: dockTile)
            
            // Add a publisher for the appearance. Will get called whenever
            // the system appearance changes.
            appearancePublisher = NSApp.publisher(for: \.effectiveAppearance)
                .removeDuplicates()
                .sink(receiveValue: { appearance in
                    self.updateTile(tile: dockTile, appearance: appearance)
                })
        } else {
            
            // Application icon was removed from the Dock. We don't need to do
            // unnecessary listening and event handling since the icon is not
            // showing in the Dock.
            
            appearancePublisher?.cancel()
            appearancePublisher = nil
        }
    }
    
    /// Implement this function if you'd like to provide additional menu items for when the host
    /// application is not running. These will appear in addition to the system-provided options when
    /// the user control-clicks on the Host app's Dock icon.
    func dockMenu() -> NSMenu? { return nil }
    
    // MARK: - Helper Functions
    
    private func updateTile(tile: NSDockTile, appearance: NSAppearance = NSApp.effectiveAppearance) {
        let isLightMode = appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua
        let iconName: DockTileImage = isLightMode ? .light : .dark
        
        guard let image = self.dockTilePlugInBundle.image(forResource: iconName.rawValue)
        else { return }
        
        let imageView = NSImageView(image: image)
        tile.contentView = imageView
        tile.display()
    }
}
