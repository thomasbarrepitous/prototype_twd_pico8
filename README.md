# prototype_twd_pico8


v.1.0.1 - 23/04/2018

Added : - AABB Collisions.
	- The player's character has now a state called A.State which define which 		sprite/action to use.
	- The code is now easier to read, it's now separated within tabs (Zombies, Player, 		Draw, ...).
	- The HUD has now a noise bar associated with a number corresponding to the noise 		you make. The bigger it is, more the zombies will be attracted by you.

Changes : - The hitboxes of the zombies are now bigger.
	  - The hitboxes of the player is now thinner.
	  - The zombies have now 7HP instead of 15HP.
	  - The zombies cannot walk through obstacles.

Bugfixes : - Fixed a bug where the bullet wouldn't hit the zombie
	   - Fixed a bug where you the only way to shoot was to spam the keys. This is now 		   fixed by using a cooldown.

To do : - Fix obstacles that are shown but are not solid when changing maps.
	- Fix the zombies that one shot you.
	- Fix the invincibility time.
	- Make the zombies come from underground with an animation which let the player
	the time to react to the spawning.
	- Make interactions.
	- Make zombies follow you even when off-screen --> Don't delete the zombies anymore.


Thomas Barré-Pitous.


-- CONCEPT --

This is a prototype of a future game made on Pico8.
This project is a part of my internship abroad at the University of Tsukuba (筑波大学), Japan proposed by the IUT Computer Science Department of Bordeaux.

The subject of this internship is "Game Development". 

Our goal is to create a video game from scratch using Java or LUA and understand the process of creating a video game.

This project is supervised by Claus Aranha, professor at the University of Tsukuba and in colaboration with Nathan Lesne also from the same Computer Science department.

-- THE CODE --

I'm relatively new in the GitHub community and I don't really know anything about the licenses etc ...
So this code is completly open-source but I don't think everyone will ever read this anyway.

-- THANK YOU --

If you checked this README it's maybe becuase you are interested in my work, if that's the case don't hesitate to ask any questions at barrepitousthomas@gmail.com , I really appreciate that you're taking your time to see what I made.

Thank you.

Thomas Barré-Pitous.
