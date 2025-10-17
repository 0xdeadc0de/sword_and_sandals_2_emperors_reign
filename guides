here's some interesting builds i have experimented with.

the easiest build possible is to just go all charisma and use taunt,
after a while when you got bored you can spend some in magicka to spice things
up a bit.

second interesting build is going 60 agility and 
getting the most strong bow asap. this strategy is somewhat fragile
especially the first tournament where you have to deal with butcher the RNG king.
also some tournaments where you have archer and magicians will also test you
but i found it easy to pass after 2-3 tries thanks to game having save/load feature

and lastly, i was attempting to build the strongest possible character given
game's constraints (without obvious cheating) at 50 level (max) you will have about 216 stats.

i found that colossus gives 3x str and 2x attack for about 16 rounds.
and ghost strike + whirlwind does massive damage and only uses mana equaling to magicka
so the problem statement here is that whether should we spend 60 agility and get katana
or go full strength and get maul for 440 damage. the statement is below:

a for attack, s for strength, w for weapon damage
f(a,s)=min(0.99,((2*a+10)/(60+10)*0.5))*((s*3*2+w)*1.5) 
maximize f with given constraints below: 
a+s=159, w=480 
a+s=99, w=676

the gpt solves this with:
1
s=64.3 a=94.7	fmax ≈ 1556.6
2	
s=64.3 a=34.7 fmax ≈ 1313.0

and it did work marvelously... the ww attack does indeed damage around 1.5k.
here i gave defender 60 defence points since this is the stat of the final emperor
you're going to face.
my final build is as follows here:
```
parnew.characters[3].strength.string = '97'
parnew.characters[3].speed.string    = '1'
parnew.characters[3].attack.string   = '64'
parnew.characters[3].defence.string  = '1'
parnew.characters[3].vitality.string = '1'
parnew.characters[3].charisma.string = '1'
parnew.characters[3].stamina.string  = '1'
parnew.characters[3].magicka.string  = '50'
```
and items : colossus, 2x ww, 3x ghost.
strategy:
1st round: cast colossus
2nd+ if enemy is in range (if you see power,normal attacks and not charge) use ww, otherwise ghost
