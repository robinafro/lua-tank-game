
#  lua-tank-game

an infinite, wave-based PvE game with tanks.

##  game mechanics

###  controls

- the player can control their tank using W, A, S, D keys. they can fire a bullet by pressing the spacebar.

###  shooting

- there is a finite amount of ammo that the player has to work with. it slowly regenerates when the player runs out of bullets.

- an aim-assist system helps the player shoot more accurately.

###  enemies
- all enemies have an infinite amount of bullets.

- the enemy AI (although it's not a 'real' neural-network based AI) has an A* pathfinding algorithm that computes the nearest path to the player.

- the enemies stop to fire when the player is near enough (determined by the 'aggressivity' weight).

- all enemy AI weights, such as aggressivity, are randomized, to make them look more natural.

###  game loop

- the game is wave-based, each wave, enemies spawn and the game waits until all of them are dead.

- the enemy spawn count, as well as firerate, health, damage and more, is determined by the current wave number.

- when an enemy is killed, the player gains a random upgrade. examples include 'more health', 'firerate' and 'damage'

- for each enemy killed and wave completed, the player gets a set amount of score. this score adds up until the end of the game.

- when the player dies, an end screen is displayed, showing the player their score and a restart button.

###  map generation

- the map has a set size. at the border of the map are walls, which prevent the player and enemies from exiting it.

- the map composes of smaller chunks to save performance. the chunks change color based on the biome they are in.

- the biomes are calculated at the start of the game using multiple layers of Perlin noise and they blend smoothly with the biomes around them.

- to add variety, different pre-defined structures are spawned at random positions on the map. they collide with the tanks and bullets and can be used as cover.

### user interface
- the game has a simple user interface system, that allows us to render text, images and containers.
- this UI system is heavily inspired by Roblox' UI classes, such as ScreenGui, ImageLabel, Frame, etc.
- the game includes a few UIs for displaying health, ammo, the current wave, a death screen, and more.

##  technical side of things

###  game engine

- the game is written in [Lua 5.2](https://www.lua.org/manual/5.2/), a fast and lightweight language designed mainly for embedded use.

- the framework used for rendering and input is [Love2D](https://love2d.org/).

- everything else was written from scratch.

###  collisions

the collisions are handled using [separating axis theorem](http://programmerart.weebly.com/separating-axis-theorem.html).

- first, a collision is detected using the SAT method above for every other collider.

- the shortest axis of the collision is found and the object is moved along it, away from the other object, until it no longer collides (determined by the collision magnitude)

- this is done for each collider in the game.

- but that would be very **performance-heavy**. for only 50 colliders, the number of iterations would grow to 50 * 49, which is **2450** computations, every frame. and the SAT function is not cheap either, as it needs to find all axes of both objects, project the objects onto them and determine whether they are overlapping.

- to save performance, we can use a cheaper collision method first, to determine if the objects are actually even able to collide.

- all colliders are split into aligned groups based on their position and size. the groups are pre-defined and aligned to a grid. an object can belong to multiple groups, provided that it collides with them.

- we check whether an object collides with a group using an [AABB intersection](https://noonat.github.io/intersect/) test.

- then, instead of iterating through all objects globally, we iterate through all objects **within a group**.

- this massivelly decreases the number of iterations, from 2450 to about 600, assuming that the objects are aligned to a grid 10 units away from each other and there are 4 groups. the number of groups can be tweaked by adjusting their size.

- we can also save performance by ignoring objects that we already computed collisions for. this is as simple as adding an ignoreList table before the for-loop and appending objects to it as they are calculated.

- this will cut the number of iterations in half, from 2450 to **1225**. combine both methods and we've made it 8 times more performant.

###  A* pathfinding

- at the start of the game, a pathfinding grid is created. this an array consisting of arrays of cells: {x: {y: isCellOccupied}}.

- using the grid, a path from the enemy to the player can be computed using an [A* pathfinding algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm).

- this alone would normally work, but since the grid has lower resolution than the map itself, it is possible that the target is inside of an occupied cell. in that case, the path would not finish computing and the enemy would have nowhere to move.

- to fix this, when the player is in an occupied cell, we attempt to find the closest reachable point that has no intersection between itself and the target.

- this is achieved by creating a bunch of points X units away from the player in a circular pattern. then, a [raycast](https://create.roblox.com/docs/workspace/raycasting) is sent from the point to the player. if there is no intersection, the point can be used as an alternative pathfinding target.

###  raycasting

- raycasting in games can involve complex math calculations, but here, I just reused the SAT colliders.

- each ray is just a very thin collider that spans from the start to the end.

- if it doesn't collide, there is no intersection.

###  camera and rendering

- in the Love2D framework, images or rectangles and other shapes can be drawn to the screen at a specific position in pixels.

- however, since the world is large and the camera needs to move along with the tank, we can't just hard-code a position for each object.

- we instead need to translate each objects on-screen position by the world position of the camera.

- attempting to render objects that are outside of the camera's view would have performance impact, but we can ignore that, as the framework takes care of excluding the objects for us.

- we also need to determine which objects to render first, so that they overlap in the correct order. this is achieved by assigning a 'ZIndex' property to each objects and then sorting them using Lua's ```table.sort``` function.

###  modular code structure

- all code is split into modules, these are separate .lua files that each do a specific thing.

- modules run asynchronously, each in its own [lua coroutine](https://www.lua.org/pil/9.1.html).

- this allows them to use a sleep function without freezing the game.

- but this would result in the modules getting out of sync because each function takes a different amount of milliseconds to finish running.

- this is fixed by using a central 'task scheduler', which fires events at a specific time in the frame.

- this task scheduler is inspired by Roblox' [task scheduler](https://create.roblox.com/docs/studio/microprofiler/task-scheduler#scheduler-priority). for example, it includes events such as "RenderStepped" and "Heartbeat".

### classes
- to reduce code repetition, classes are specialized modules that have their functions and properties, and can inherit from other clases. [see here](https://www.tutorialspoint.com/lua/lua_object_oriented.htm) for more information.
