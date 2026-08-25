# NClickLib V2.0
An Into the Breach library for making complex targeting systems.



Thanks Lenonymous for the weaponArmed and menu library and also for making replacerepair which is how I figured out UI crap and also stole stuff so the button fades out when you hit a menu

Thanks Truelch for inspiring this, helping find some bugs, and for making some super cool weapons using the library!

Link will be posted when he's set up a github repo for the squad.

Thanks to Das Kiefer for attempting to help with some UI stuff [I ended up doing it myself from scratch]

Thanks to the ITB Modding community for being awesome

If you want a demo of how to use this, check out https://github.com/TheBoardsCousin/ITB-TargetAcquirers [Is missing a couple of the newest features]

And if you want to know how to use the most recent version's new features [Expanding capabilities of confirmation functions] you can try and use https://github.com/TheBoardsCousin/ITB-BoomWeapon to figure it out

It is sphaghetti code but making it burnt me out so as of now I'm not working on a more understandable demo :cry:

thanks generic for letting me make funny boom bot weapons


Changelog:

8/15/2026: Version 1.1

Added a clickable button for confirmation weapons. No changes should be needed to your code to implement but it's reccomended you replace any "function() end" in confirmation function lists with nil. It just makes the button go away when it's supposed to [But if you don't make these changes, the button won't have any odd gameplay affects]



8/25/2026: Version 2.0


List of changes:
	*'d changes require you to change existing NClickSkills to be compatible with the new NClickVersion.

  *PhaseChange, SkillEffect, and TargetArea functions all now take the inputs p1, p2, self, Clicks, and PhaseClicks, in that order.
	this makes Clicks and PhaseClicks no longer global, meaning you ou can edit the lists in your functions without messing stuff up.

  *You must now define and return ret in the applicable functions.
	This improves parity with base-game weapons.

  *Confirmation Functions, instead of directly changing the phase, now return a value. nil, false, or the function not existing all do nothing. Returning true fires the weapon. Returning a number sets the weapon to that phase.


  TipImages can now be included inside the NClickSkill.
	They are defined with the standard TipImage board layout, minus the Target point.
	Then, define a second field called TipImageData, which is a keyed list of p2, Phase, Clicks, and PhaseClicks. This just directly calls the SkillEffect for a specific phase. You don't need to define values that you aren't using.
	TipImageData can take a list of those keyed arrays, and it will cycle through the given data.

  See X_MissileSpam in https://github.com/TheBoardsCousin/ITB-TargetAcquirers for an example of almost all these changes

  New functions: CopyTable and FilteredPointList, CopyTable perfectly copies a table [Including nested ones] and FilteredPointList takes a list of points and returns them in the same order but with duplicates removed.
