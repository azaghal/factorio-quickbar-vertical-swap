Quickbar Vertical Swap
======================


About
-----

*Quickbar Vertical Swap* is a simple quality-of-life mod that swaps first and last five slots in a quickbar slot using a custom control. This allows easy access to all quickbar slots using just the first five digits on the keyboard.


Features
--------


-   Press `C` to vertically swap qucikbar slots. **NOTE:** Default control overlaps with built-in *Shoot selected* control. It is recommended to rebind the *Shoot selected* control to avoid accidents (for example to `Shift + Spacebar`), or to rebind the vertical swap control instead.
-   Configurable mode of operation. Choose between all quickbars (both visible and hidden), or one or more of the active (visible) quickbars.
-   Black-listing quickbar rows. Provide a comma-separated list of quickbars (numbers 1 through 10) that should be excluded from vertical swapping.


Known issues
------------

This is a list of known issues:

-   [CANTFIX] Blueprints are not swapped. Modding API does not provide means to successfully swap blueprints in quickbars.
-   [CANTFIX] When enabling swapping for only active quickbars, player has to manually match the *Interface* / *Active quickbars* value since modding API does not provide the means to retrieve number of configured active quickbars.
-   [WONTFIX] Empty slots are not swapped with non-empty slots. When library blueprints are placed in the quickbar, it is not possible to distinguish them from empty slots. Instead of clearing such slot configurations by mistake, the mod insteads opts not to touch anything that looks like an empty slot.


Contributions
-------------

Bugs and feature requests can be reported through discussion threads or through project's issue tracker. For general questions, please use discussion threads.

Pull requests for implementing new features and fixing encountered issues are always welcome.


Credits
-------

Implementation was inspired by the following (existing) mods:

-   [Quick Swap](https://mods.factorio.com/mod/QuickSwap)
-   [Vertical Swap](https://mods.factorio.com/mod/vertical-swap)


License
-------

All code, documentation, and assets implemented as part of this modpack are released under the terms of MIT license (see the accompanying `LICENSE`) file, with the following exceptions:

-   [assets/back-and-forth.svg](https://game-icons.net/1x1/lorc/back-forth.html), by Lorc, under [CC BY 3.0](http://creativecommons.org/licenses/by/3.0/), used in creation of modpack thumbnail.
