# TODO:
 - prevent player clipping on jumping with ceilings with certain heights *(**VERY HIGH**)*
 - clean up repetitive code in entity script
 - add a new tile script
 - add entities to two rooms
 - increase frames on button that toggles dark palette
 - add dialog/menu upon the collection of an item *(**MED**)*
    - for the first item, inform user on how to switch bullets
 - prevent player's death particles from overflowing on the Y-axis
 - add another background palette
 - remove and replace `room2x0`'s puzzle that is easily spoofable *(**MED**)*
 - add enough rooms to allow the player to collect an egg
 - have the minimap flash for the room the player is in *(LOW)*
 - boss spawning (**HIGH**)
 - add exploding sound to `gfx_screenShake` routine
 - add `quick reset from checkpoint` button
 
---

# DONE:
 - allow player to keep some upward momentum upon colliding with a tile above the player *(**VERY HIGH**, 1/9/21)*
 - fixed `gfx_fadeIn` bug not loading palette correctly in DMG mode *(1/9/21)*
 - fix bug that occurs when the player first dies, the wrong room is drawn *(**HIGH**, 1/9/21)*
 - add screen shake when `bomb blaster` hits something *(1/9/21)*
 - bullets can now shoot through select entities *(1/8/21)*
 - rework entity scripts to use `ent_foreach` *(1/7/21)*
 - `ent_delete` SHOULD SET REDRAW FLAG!!! *(**HIGH**, 9/5/20)*
 - create a `telebullet` that will teleport the player upon deletion *(**HIGH**)*
 - Fix the window graphical glitch *(9/4/20)*
 - enable tile collision scripts to be only activated by player *(**HIGH**)*
 - slime enemy
 - complete entity tables for completed rooms
 - entity animation *(**HIGH**)*
 - make shooting useful
 - entity-entity collision
 - gfx routine to replace colors of a tile *(**HIGH**)*
 - enable more time for falling tiles
