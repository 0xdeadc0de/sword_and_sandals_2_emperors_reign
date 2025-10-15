
also might be interesting to share some of the combat mechanics i've found before i discard all the work and forget about it.

```
   game_attacker.power_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.33);
   game_attacker.normal_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.5);
   game_attacker.quick_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.66);
   game_attacker.bash_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.2);
   game_attacker.taunt_percentage = Math.round((game_attacker.charisma + 9) / (game_defender.charisma + 9) * 100 * 0.4);
   game_attacker.bombard_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.6);
   game_attacker.bombard_percentage_bonus = get_percentage(100 + game_attacker.shield * 1.5,100);
   game_attacker.bombard_percentage = add_percentage(game_attacker.bombard_percentage,game_attacker.bombard_percentage_bonus);
   game_attacker.snipe_percentage = Math.round((game_attacker.attack + 9) / (game_defender.defence + 9) * 100 * 0.9);
   game_attacker.snipe_percentage_bonus = get_percentage(100 + game_attacker.shield * 1.5,100);
   game_attacker.snipe_percentage = add_percentage(game_attacker.snipe_percentage,game_attacker.snipe_percentage_bonus);
   game_attacker.magicka_percentage = Math.round((game_attacker.magicka + 9) / (game_defender.magicka + 9) * 100 * 0.5);
```
some dice and damage mechanics
```
checkattackroll = function()
{
   attack_chances(game_attacker,game_defender);
   diceroll = randomBetween(1,100);
   if(attack_direction >= 1 && attack_direction <= 4)
   {
      damage = game_attacker.min_damage;
      criticalhit = randomBetween(-20,20);
      rollneeded = 100 - game_attacker.quick_percentage;
   }
   else if(attack_direction >= 5 && attack_direction <= 8)
   {
      damage = randomBetween(game_attacker.min_damage,game_attacker.max_damage);
      criticalhit = randomBetween(1,20);
      rollneeded = 100 - game_attacker.normal_percentage;
   }
   else if(attack_direction >= 9 && attack_direction <= 12)
   {
      criticalhit = randomBetween(5,20);
      damage = game_attacker.max_damage;
      rollneeded = 100 - game_attacker.power_percentage;
   }
   else if(attack_direction == 20)
   {
      criticalhit = 21;
      damage = Math.round(game_attacker.charisma * 4) - game_defender.charisma;
      if(damage < 1)
      {
         damage = randomBetween(1,3);
      }
      rollneeded = 100 - game_attacker.taunt_percentage;
   }
   else if(attack_direction == 21)
   {
      criticalhit = randomBetween(-20,20);
      damage = randomBetween(game_attacker.min_damage,game_attacker.max_damage);
      rollneeded = 100 - game_attacker.bombard_percentage;
   }
   else if(attack_direction == 22)
   {
      criticalhit = 0;
      damage = game_attacker.min_damage;
      rollneeded = 100 - game_attacker.snipe_percentage;
   }
   else if(attack_direction == 23)
   {
      damage = Math.ceil(game_attacker.min_damage / 2);
      rollneeded = 100 - game_attacker.bash_percentage;
   }
   else if(attack_direction == 30)
   {
      criticalhit = 20;
      damage = Math.round(game_attacker.max_damage * 1.5);
      rollneeded = 100 - Math.round(game_attacker.normal_percentage);
   }
   if(diceroll >= rollneeded)
   {
      deflect_critical = randomBetween(1,100);
      deflect_needed = get_percentage(100 - game_defender.helmet * 1.5 + game_defender.greaves,100);
      if(deflect_critical >= deflect_needed)
      {
         criticalhit = 0;
      }
      if(attack_direction == 30)
      {
         defender_hurt("grievous");
      }
      else if(attack_direction == 20)
      {
         defender_hurt("taunt");
      }
      else if(criticalhit == 20 && attack_direction != 20)
      {
         defender_hurt("critical");
      }
      else
      {
         damage_method = "normal";
         defender_hurt("normal");
      }
   }
   else
   {
      defender_blocked();
   }
};
```
this section covers some life-mana regen at end of round
```
nextphase = function()
{
   demand_move = 1;
   check_spells(game_attacker,attacker);
   check_spells(game_defender,defender);
   game_attacker.staminaleft -= game_attacker.staminacost;
   game_attacker.staminaleft += 1 + Math.round(game_attacker.stamina / 3);
   game_attacker.hitpoints += 1 + Math.ceil(game_attacker.stamina / 2);
   check_stats(game_attacker);
   bonus = 1 + Math.round(game_attacker.stamina / 3);
   add_stats_icon(game_attacker,attacker,bonus,2);
   check_stats(game_attacker);
   if(attacker.spell_regenerate > 0)
   {
      game_attacker.hitpoints += Math.round(game_attacker.hitpointsmax / 4);
      bonus = Math.round(game_attacker.hitpointsmax / 4);
      add_stats_icon(game_attacker,attacker,bonus,1);
      check_stats(game_attacker);
   }
   if(attacker.spell_boundless_energy > 0)
   {
      game_attacker.staminaleft += Math.round(game_attacker.staminamax / 4);
      bonus = Math.round(game_attacker.stamina / 4);
      add_stats_icon(game_attacker,attacker,bonus,2);
      check_stats(game_attacker);
      check_stats(game_attacker);
   }
```
the movement speed in the game is calculated as `1.5 * agility` and capped at 60, so agility 40 should max out speed.

all special events:
```
day_night_cycle();
if(_global.special_event != 1)
{
   _global.special_for_day = true;
   _global.special_event = 2 + random(10);
}
_global.special_event_happening = true;
if(_global.special_event == 1)
{
   special_event_title.text = "Nightfall";
   special_event_story.text = "The hour is late and as the town quietens, you find yourself growing weary.\rWill you brave the streets, or spend some gold finding a tavern to rest for the night?";
   special_event_option1 = "Brave the streets";
   special_event_option2 = "Find a bed in a tavern ( " + 40 * _root.game.hero.herolevel + " gold)";
   special_event_result1_good_txt = "Finding a quiet corner in an alleyway, you try and settle down to sleep.\r\rYou eventually fall into an uneasy sleep listening to the sounds of the night. Next morning you awake, somewhat cold but overall rested.";
   special_event_result1_bad_txt = "Finding a quiet corner in an alleyway, you try and settle down to sleep.\r\rAfter a turbulent sleep, you wake to find you have been robbed by cutpurses in the night! You have lost all your gold!";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = null;
   special_event_good_effect_item_1 = null;
   special_event_bad_effect_1 = "goldpieces";
   special_event_bad_effect_item_1 = - _root.game.hero.goldpieces;
   special_event_result2_good_txt = "You make your way to the Cosy Nook, a tavern in the merchant\'s quarter. Paying the innkeeper " + 40 * _root.game.hero.herolevel + " gold pieces, you are shown to a comfortable room with a view of the forests to the east." + "\n" + "\n" + "Your sleep is peaceful and you wake feeling ready to take on the world again.";
   special_event_cost_2 = 40 * _root.game.hero.herolevel;
}
if(_global.special_event == 2)
{
   special_event_title.text = "The fallen cart";
   special_event_story.text = "A merchant\'s cart has fallen over and the goods are spilt everywhere. A crowd of people has gathered round. The merchant is obviously struggling. Do you help him out, or sneakily steal some of his goods??\'";
   special_event_option1 = "Steal something and wander off nonchalantly";
   special_event_option2 = "Help the merchant repair his cart";
   special_event_result1_good_txt = "In the confusion, nobody notices you pocket some of the merchant\'s goods.\r\rCheck your inventory to see what you have pilfered...";
   special_event_result1_bad_txt = "Somebody notices you thieving, and the crowd turn on you! With jeers, they chase you down the road.\r\rYour popularity as a gladiator has plummeted. You lose 2 CHARISMA points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "inventory1";
   special_event_good_effect_item_1 = 2 + random(6);
   special_event_bad_effect_1 = "charisma";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "You spend some time repairing the cart. The grateful merchant thanks you and gives you " + Math.round(_root.game.hero.herolevel * 50) + " gold pieces for your efforts.";
   special_event_cost_2 = - Math.round(_root.game.hero.herolevel * 50);
}
if(_global.special_event == 3)
{
   special_event_title.text = "Box of mystery";
   special_event_story.text = "You are approached by a hooded man carrying an engraved rosewood box.\rHe looks around for a moment before whispering to you. \'Box of mystery! What lies inside? Hand me some gold, stranger and you shall see!\'";
   special_event_option1 = "Pay the man and open the box ( " + _root.game.hero.herolevel * 300 + " gold )";
   special_event_option2 = "Decline and walk away";
   special_event_result1_good_txt = "You hand over the gold.\r\rOpening the box, you find a tome of knowledge entitled \'Arcane Arts\'. The man disappears into the gloom, and you peer through the tome. After reading for an hour, you realise your MAGICKA has grown by 3 points!";
   special_event_result1_bad_txt = "You hand over the gold.\r\rInside the box is a rotten potato. The hooded man laughs at you before disappearing into the gloom.";
   special_event_cost_1 = _root.game.hero.herolevel * 300;
   special_event_good_effect_1 = "magicka";
   special_event_good_effect_item_1 = 3;
   special_event_bad_effect_1 = null;
   special_event_bad_effect_item_1 = null;
   special_event_result2_good_txt = "The hooded man mutters something nasty to you and disappears into the blackness of the night.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 4)
{
   special_event_title.text = "The child in the mill";
   special_event_story.text = "You are approached by a frantic woman. \'Please help me! My only child was playing in the old mill and is trapped under some heavy wooden blocks. I cannot free him.\'\rDo you help rescue the child, or decline and get about your business?";
   special_event_option1 = "Help rescue the child";
   special_event_option2 = "Do not help with the rescue";
   special_event_result1_good_txt = "You follow the woman to the mill, and get to work with the rescue effort. Although it takes an hour and most of your strength, eventually the child is free.\r\rYou have become a hero in both the mother and child\'s eyes. You gain 3 CHARISMA points.";
   special_event_result1_bad_txt = "You follow the woman to the mill, and try to rescue the child from under the blocks. In the attempt you do some serious damage to your back and are forced to abandon the rescue.\r\rEventually someone frees the child, but your back is killing you. Lose 3 STRENGTH points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "charisma";
   special_event_good_effect_item_1 = 3;
   special_event_bad_effect_1 = "strength";
   special_event_bad_effect_item_1 = -3;
   special_event_result2_good_txt = "\'I am a gladiator. \', you reply. \'Nothing more.\'\r\rYou walk away and get on with the business of killing.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 5)
{
   special_event_title.text = "A game of chance";
   special_event_story.text = "You are enjoying a meal in the tavern when a jester approaches you. \'Play a game of chance! Win, and double your gold! Only " + Math.ceil(_root.game.hero.goldpieces / 4 + 1) + " gold pieces to play." + "\n" + "\n" + "Do you take up the jester\'s offer?";
   special_event_option1 = "Play a game ( " + Math.ceil(_root.game.hero.goldpieces / 4 + 1) + " gold )";
   special_event_option2 = "Shoo the jester away and enjoy the rest of your meal";
   special_event_result1_good_txt = "You are given some dice to roll. Apparently the numbers you rolled were favourable, because the jester curses several profanities before throwing some coins at you.\r\rYou have doubled your winnings, earning " + Math.ceil((_root.game.hero.goldpieces / 4 + 1) * 2) + " gold pieces!";
   special_event_result1_bad_txt = "You are given some dice to roll. However, on this day the gods do not smile upon you. The jester takes your money and continues on his way, chuckling merrily.\r\rYou have lost " + Math.ceil(_root.game.hero.goldpieces / 4 + 1) + " gold pieces.";
   special_event_cost_1 = Math.ceil(_root.game.hero.goldpieces / 4 + 1);
   special_event_good_effect_1 = "goldpieces";
   special_event_good_effect_item_1 = Math.ceil(_root.game.hero.goldpieces / 4 + 1) * 2;
   special_event_bad_effect_1 = "goldpieces";
   special_event_bad_effect_item_1 = 0;
   special_event_result2_good_txt = "\'I make my own luck!\' you scowl. The jester shrugs and moves to the next table. You return to your meal.\r\rIt is simple fare but you are hungry. You call for an ale to wash it down.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 6)
{
   special_event_title.text = "The fastest man in town";
   special_event_story.text = "You are relaxing under a tree when you overhear a young man boasting to a fair maiden. \'I am the fastest man in town!\' he declares, \'Nobody can run like me.\' Quickly you size the man up. You seem to be of equal build and it\'s possible you could outrace him.";
   special_event_option1 = "Challenge the man to a race around town";
   special_event_option2 = "Let the man be, and return to relaxing in the shade";
   special_event_result1_good_txt = "A race is soon organised, a course decided, and several villagers gather to watch. Though you are evenly matched, eventually you pull away and are declared the winner.\r\rThe young man slinks away, and you find yourself feeling quicker than ever. Gain 2 AGILITY points.";
   special_event_result1_bad_txt = "A race is soon organised, a course decided, and several villagers gather to watch. Though you are evenly matched, you twist your ankle just before the finish line and are beaten.\r\rThe maiden gazes adoringly at young man, and you can only feel old and slow. Lose 2 AGILITY points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "speed";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "speed";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "You smile wistfully to yourself, thinking about the carefree days of your youth. The days before the dark years of prison...days of fishing, swimming and laughter. Days of love and adventure, and of honest work.\r\rAs you doze off to sleep, you wonder to yourself whether you will ever be truly free again.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 7)
{
   special_event_title.text = "The braggart";
   special_event_story.text = "You are sitting quietly outside the armoury when you overhear a loud boor bragging about his strength. \'Who can match my strength? Nobody here, certainly!\' Sizing the man up, you figure yourself at least as strong as him. Will you teach the cad a lesson?";
   special_event_option1 = "Challenge the braggart to a wrestling match";
   special_event_option2 = "Ignore his boasts";
   special_event_result1_good_txt = "You stride up to the man and push him in the chest. \'You talk a big game\', you sneer derisively, \'but you are weak.\' Soon you are wrestling in the dirt of the town square.\r\rYou quickly pin the boor and he yields and limps away. You have gained 2 STRENGTH points.";
   special_event_result1_bad_txt = "You stride up to the man and push him in the chest. \'You talk a big game\', you sneer derisively, \'but you are weak.\' Soon you are wrestling in the dirt of the town square.\r\rHowever, you find yourself overmatched, and are forced to yield, much to your shame! You have lost 2 CHARISMA points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "strength";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "charisma";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "You smile wistfully to yourself, thinking about the carefree days of your youth. The days before the dark years of prison.\r\rAs you doze off to sleep, you wonder to yourself whether you will ever be truly free again.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 8)
{
   special_event_title.text = "Fair maiden";
   special_event_story.text = "Whilst leaving the arena, you spot a pretty girl smiling at you. As it has been some time since you\'ve known a lady, you pluck up the courage to ask her out for a meal. Will you be extravagant, spoiling the lady with a fine restaurant, or take her for a simple meal at the tavern?";
   special_event_option1 = "Take her for a meal at a fine restaurant ( 1500 gold )";
   special_event_option2 = "Take her for beers and snacks at a cheap tavern ( 150 gold )";
   special_event_result1_good_txt = "She accepts your offer and that night you meet at one of the finest restaurants in town. The meal is splendid, the conversation flows and soon enough....\r\r...the next morning the maiden gives you a kiss and a rose. You shall be her champion. You have also gained 2 STAMINA points for your prowess.";
   special_event_result1_bad_txt = "She accepts your offer and that night you meet at a fine restaurant near the water. However, you make the mistake of ordering a particularly gassy seafood dish, which does not sit well at all.\r\rAmid a cloud of flatulence, you are forced to excuse yourself from the table, leaving the maiden incensed. You lose 2 CHARISMA points.";
   special_event_cost_1 = 1500;
   special_event_good_effect_1 = "stamina";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "charisma";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "The fair maiden is insulted and refuses to go with you. She storms off in a huff.\r\rYou console yourself with several pints of lager at the tavern. Alone.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 9)
{
   special_event_title.text = "The old soldier";
   special_event_story.text = "Just outside the weaponsmith, you are approached by an old soldier who offers to teach you a thing or two about defending with your weapon, in exchange for gold. Do you take him up on his offer, or decline, knowing that your defensive skills are unmatched already?";
   special_event_option1 = "Learn some defensive techniques from the old soldier ( " + _root.game.hero.herolevel * 500 + " gold )";
   special_event_option2 = "Decline his offer of help";
   special_event_result1_good_txt = "The wily soldier spends a few hours showing you how to dodge and parry your opponent\'s blows and you learn some valuable new techniques.\r\rSeveral hours later, you are weary but feel greatly encouraged by the results. You have gained 2 DEFENCE points.";
   special_event_result1_bad_txt = "The wily soldier spends a few hours showing you how to dodge and parry your opponent\'s blows - though you learn some new techniques, there is much you already knew.\r\rSeveral hours later, you are weary but have learnt a few new tricks. You have gained 1 DEFENCE point.";
   special_event_cost_1 = _root.game.hero.herolevel * 500;
   special_event_good_effect_1 = "defence";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "defence";
   special_event_bad_effect_item_1 = 1;
   special_event_result2_good_txt = "\'Suit yourself\', shrugs the soldier. \'I\'m sure there\'ll be other gladiators happy to learn from a former Captain of the Imperial Guard.\'\r\rWhether he was bluffing or not, who can say?";
   special_event_cost_2 = 0;
}
if(_global.special_event == 10)
{
   special_event_title.text = "Dabbling in magic";
   special_event_story.text = "You are browsing in the magic shop when a warlock corners you. \'I require several strong gladiators to help me with a dangerous magical spell. Will you lend me your skills?\' He stares at you intently.";
   special_event_option1 = "Go with the warlock to his tower to help with the spell";
   special_event_option2 = "Decline, leave the store at once and don\'t look back";
   special_event_result1_good_txt = "Along with several other warriors, you watch as the magician opens a portal. \'Hold back whatever comes through!\' he yells. Soon enough, several elemental fiends leap at you, but you make short work of them.\r\rThe magician darts through the portal and returns with " + _root.game.hero.herolevel * 1200 + " gold pieces for each warrior.";
   special_event_result1_bad_txt = "Along with several other gladiators, you watch as the magician opens a portal. \'Hold back whatever comes through!\' he yells. Soon enough, several elemental fiends leap at you and the battle is fierce.\r\rSeveral warriors die in the fight and you are forced to retreat with a nasty cut to your sword arm. Lose 3 ATTACK points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "goldpieces";
   special_event_good_effect_item_1 = _root.game.hero.herolevel * 1200;
   special_event_bad_effect_1 = "attack";
   special_event_bad_effect_item_1 = -3;
   special_event_result2_good_txt = "\'I thought you were a warrior of courage, " + _root.game.hero.heroname + ".\' says the warlock, turning away. \'Clearly I was mistaken.\'";
   special_event_cost_2 = 0;
}
if(_global.special_event == 11)
{
   special_event_title.text = "Skirmish at the gates ";
   special_event_story.text = "A crowd of soldiers rushes past you, armed with pikes and shields. One grabs you. \'Every able bodied warrior to the gates! Raiders from the south approach!\' Do you lend a hand in the defence of the city, or skulk away into a side alley?";
   special_event_option1 = "Help in the defence of the city";
   special_event_option2 = "Mind your own business";
   special_event_result1_good_txt = "You charge to the gates, weapon ready. Soon enough, barbarians attack the city. The fight lasts nearly an hour, but you fight valiantly and they are driven back.\r\rLater, you find that from fighting in the skirmish, your attack skills have grown somewhat. Gain 2 ATTACK points.";
   special_event_result1_bad_txt = "You charge to the gates, weapon ready. Soon enough, barbarians attack the city. The fight lasts nearly an hour, and in the fight you are hit hard in the chest by a mallet.\r\rLater, you find your breathing is somwehat more shallow and painful. Lose 2 STAMINA points.";
   special_event_cost_1 = 0;
   special_event_good_effect_1 = "attack";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "stamina";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "You run with the soldiers for a while but break off into a side street and bravely sit out the next hour huddled in a corner. The bards shall long sing of your courage this day.";
   special_event_cost_2 = 0;
}
if(_global.special_event == 12)
{
   special_event_title.text = "The urchin";
   special_event_story.text = "A smelly urchin sidles up to you in the street. It is clear he hasn\'t bathed in weeks and has spent more time down in the sewers than up here in the city. \'Sir.... got something you might want a look at, see?\'\r\'Only " + _root.game.hero.herolevel * 175 + " gold and this great gift is yours!\'";
   special_event_option1 = "Pay the urchin and receive your prize (" + _root.game.hero.herolevel * 175 + " gold)";
   special_event_option2 = "Beat the urchin away with a stick";
   special_event_result1_good_txt = "Somewhat skeptical, you hand over your gold to the urchin, who tosses you a leather pouch, obviously stolen. You almost dare not to look inside, but eventually you do, and find a strange magical scroll.\r\rReading it aloud, you feel a strange sensation. Your MAGICKA has grown by 2 points!";
   special_event_result1_bad_txt = "Somewhat skeptical, you hand over your gold to the urchin, who tosses you a leather pouch,obviously stolen. You almost dare not to look inside, but eventually you do, and find an odd magical ring.\r\rYou put on the ring, but immediately feel drained and dazed. It is cursed! You have lost 2 MAGICKA points!";
   special_event_cost_1 = _root.game.hero.herolevel * 175;
   special_event_good_effect_1 = "magicka";
   special_event_good_effect_item_1 = 2;
   special_event_bad_effect_1 = "magicka";
   special_event_bad_effect_item_1 = -2;
   special_event_result2_good_txt = "\'Away with you, scamp!\' you shout. The urchin hisses and slinks off to harass someone else.";
   special_event_cost_2 = 0;
}
if(special_event_cost_1 > _root.game.hero.goldpieces)
{
   special_event_option1 = "You do not have enough gold for the first option.";
   special_button1._visible = false;
}
if(special_event_cost_2 > _root.game.hero.goldpieces)
{
   special_event_option2 = "You do not have enough gold for the second option.";
   special_button2._visible = false;
}
special_event_title_var = special_event_title.text;
```
information about what items do:
```

attacker.onEnterFrame = function()
{
   if(_root.arena.fightdistance < 100)
   {
      if(_root.arena.gladiators.hero.gladiator_dir == "left")
      {
         _root.arena.gladiators.hero._x = _root.arena.gladiators.hero._x + 1;
         _root.arena.gladiators.villain._x--;
      }
      else
      {
         _root.arena.gladiators.hero._x--;
         _root.arena.gladiators.villain._x = _root.arena.gladiators.villain._x + 1;
      }
   }
   if(demand_move == null)
   {
      demand_move = 1;
   }
   demand_move++;
   if(demand_move >= 60 && attacker._y >= attacker.grounded && bullet_in_air != true || demand_move >= 200)
   {
      demand_move = 1;
      attacker.grounded = null;
      attacker.struck = null;
      defender.struck = null;
      defender.grounded = null;
      nextphase();
   }
   if(attacker != _root.arena.gladiators.hero)
   {
      _global.phasecomplete = false;
   }
   if(knock_defender == null || knock_defender == undefined)
   {
      if(attacker._x < -2100)
      {
         attacker._x = -2100;
         if(attacker._y >= attacker.grounded)
         {
            attacker._y = attacker.grounded;
            attacker.grounded = null;
            attacker.destination = null;
            nextphase();
         }
      }
      if(attacker._x > 2100)
      {
         attacker._x = 2100;
         if(attacker._y >= attacker.grounded)
         {
            attacker._y = attacker.grounded;
            attacker.grounded = null;
            attacker.destination = null;
            nextphase();
         }
      }
      if(defender._x < -2100)
      {
         defender._x = -2100;
      }
      if(defender._x > 2100)
      {
         defender._x = 2100;
      }
   }
   _root.arena.gladiators.overlay_villain.gotoAndStop(2);
   if(_global.battle_action == 1)
   {
      phase_decision = decisionA;
   }
   else if(_global.battle_action == 2)
   {
      phase_decision = villaindecisionA;
   }
   else if(_global.battle_action == 3)
   {
      phase_decision = decisionB;
   }
   else if(_global.battle_action == 4)
   {
      phase_decision = villaindecisionB;
   }
   else
   {
      phase_decision = null;
   }
   if(phase_decision == "walkleft")
   {
      game_attacker.staminacost = Math.round(game_attacker.movement_speed / 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("StepBack");
         attacker_x_walk = game_attacker.movement_speed * 16;
         walk_bonus = get_percentage(100 + game_attacker.boot * 2,100);
         attacker_x_walk = add_percentage(attacker_x_walk,walk_bonus);
         attacker.destination = attacker._x - attacker_x_walk;
         if(attacker.destination < defender._x + game_defender.physical_size && attacker.gladiator_dir == "left")
         {
            attacker.destination = defender._x + game_defender.physical_size;
         }
      }
      attacker._x -= Math.ceil((attacker._x - attacker.destination) / 8);
      if(attacker._x <= attacker.destination + 20)
      {
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "walkright")
   {
      game_attacker.staminacost = Math.round(game_attacker.movement_speed / 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("StepForward");
         attacker_x_walk = game_attacker.movement_speed * 16;
         walk_bonus = get_percentage(100 + game_attacker.boot * 2,100);
         attacker_x_walk = add_percentage(attacker_x_walk,walk_bonus);
         attacker.destination = attacker._x + attacker_x_walk;
         if(attacker.destination > defender._x - game_defender.physical_size && attacker.gladiator_dir == "right")
         {
            attacker.destination = defender._x - game_defender.physical_size;
         }
      }
      attacker._x += Math.ceil((attacker.destination - attacker._x) / 8);
      if(attacker._x >= attacker.destination - 20)
      {
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "runleft")
   {
      game_attacker.staminacost = Math.round(game_attacker.movement_speed / 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("RunBack");
         attacker.destination = attacker._x - game_attacker.movement_speed * 40;
      }
      attacker._x -= Math.ceil((attacker._x - attacker.destination) / 8);
      if(attacker.gladiator_dir == "left" && attacker._x < defender._x + attacker.physical_size)
      {
         attacker.destination = null;
         nextphase();
      }
      if(attacker._x <= attacker.destination + 10)
      {
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "runright")
   {
      game_attacker.staminacost = Math.round(game_attacker.movement_speed / 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("RunForward");
         attacker.destination = attacker._x + game_attacker.movement_speed * 40;
      }
      attacker._x += Math.ceil((attacker.destination - attacker._x) / 8);
      if(attacker.gladiator_dir == "right" && attacker._x > defender._x - attacker.physical_size)
      {
         attacker.destination = null;
         nextphase();
      }
      if(attacker._x >= attacker.destination - 10)
      {
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "chargeright")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.movement_speed * 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("Charge");
         attacker.destination = attacker._x + game_attacker.movement_speed * 20;
      }
      if(attacker._x <= Math.round(defender._x - game_attacker.weapon_range))
      {
         attacker._x += Math.ceil((attacker.destination - attacker._x) / 8);
      }
      if(attacker._x > Math.round(defender._x - game_attacker.weapon_range))
      {
         if(attacker.struck != true)
         {
            attacker.struck = true;
            attacker.gotoAndPlay("Chargeattack");
            attacker.attack_direction = 9;
            checkattackroll();
         }
         else if(attacker.charging == false)
         {
            attacker.struck = null;
            attacker.charging = null;
            attacker.destination = null;
            nextphase();
         }
      }
      else if(attacker.charging == true)
      {
         attacker.charging = null;
         attacker.struck = null;
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "chargeleft")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.movement_speed * 2);
      if(attacker.destination == null)
      {
         attacker.gotoAndPlay("Charge");
         attacker.destination = attacker._x - game_attacker.movement_speed * 20;
      }
      if(attacker._x >= Math.round(defender._x + game_attacker.weapon_range))
      {
         attacker._x -= Math.ceil((attacker._x - attacker.destination) / 8);
      }
      if(attacker._x < Math.round(defender._x + game_attacker.weapon_range))
      {
         if(attacker.struck != true)
         {
            attacker.struck = true;
            attacker.gotoAndPlay("Chargeattack");
            attacker.attack_direction = 9;
            checkattackroll();
         }
         else if(attacker.charging == false)
         {
            attacker.struck = null;
            attacker.charging = null;
            attacker.destination = null;
            nextphase();
         }
      }
      else if(attacker.charging == true)
      {
         attacker.charging = null;
         attacker.struck = null;
         attacker.destination = null;
         nextphase();
      }
   }
   if(phase_decision == "jumpright")
   {
      _global.crowd_action = -2;
      game_attacker.staminacost = Math.round(game_attacker.movement_speed);
      if(attacker.grounded == null)
      {
         attacker.grounded = attacker._y;
         attacker.gotoAndPlay("Jump");
         attacker.leap = - (3 + Math.ceil(game_attacker.movement_speed * 0.6));
         jump_bonus = get_percentage(100 + game_attacker.shinguard * 2,100);
         attacker.leap = add_percentage(attacker.leap,jump_bonus);
         if(attacker.leap > -8)
         {
            attacker.leap = -8;
         }
         if(attacker.leap < -36)
         {
            attacker.leap = -36;
            superjump = randomBetween(1,3);
            if(superjump == 3)
            {
               attacker.gotoAndPlay("Superjump");
            }
         }
      }
      jump_x_mov = Math.round(game_attacker.movement_speed * 0.6);
      jump_bonus = get_percentage(100 + game_attacker.shinguard * 2,100);
      jump_x_mov = add_percentage(jump_x_mov,jump_bonus);
      attacker._x += jump_x_mov;
      attacker._y += attacker.leap;
      attacker.leap += 1;
      if(attacker._y >= attacker.grounded)
      {
         attacker._y = attacker.grounded;
         attacker.grounded = null;
         nextphase();
      }
   }
   if(phase_decision == "jumpleft")
   {
      _global.crowd_action = -2;
      game_attacker.staminacost = Math.round(game_attacker.movement_speed);
      if(attacker.grounded == null)
      {
         attacker.grounded = attacker._y;
         attacker.gotoAndPlay("Jump");
         attacker.leap = 3 + Math.ceil(game_attacker.movement_speed * 0.6);
         jump_bonus = get_percentage(100 + game_attacker.shinguard * 2,100);
         attacker.leap = add_percentage(attacker.leap,jump_bonus);
         attacker.leap = - attacker.leap;
         if(attacker.leap > -8)
         {
            attacker.leap = -8;
         }
         if(attacker.leap < -36)
         {
            attacker.leap = -36;
            superjump = randomBetween(1,3);
            if(superjump == 3)
            {
               attacker.gotoAndPlay("Superjump");
            }
         }
      }
      jump_x_mov = Math.round(game_attacker.movement_speed * 0.6);
      jump_bonus = get_percentage(100 + game_attacker.shinguard * 2,100);
      jump_x_mov = add_percentage(jump_x_mov,jump_bonus);
      attacker._x -= jump_x_mov;
      attacker._y += attacker.leap;
      attacker.leap += 1;
      if(attacker._y >= attacker.grounded)
      {
         attacker._y = attacker.grounded;
         attacker.grounded = null;
         nextphase();
      }
   }
   if(phase_decision == "block")
   {
      game_attacker.staminacost = 7;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("Block");
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "swap_weapons")
   {
      game_attacker.staminacost = 1;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("Block");
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         if(game_attacker.equipped_weapon == 1)
         {
            game_attacker.equipped_weapon = 2;
            attacker.weapon.realweapon.attachMovie("weapon" + game_attacker.secondary_weapon,"weapon",0,{_x:0,_y:0});
            attacker.Rlowerarm.attachMovie("shield1","shield",3,{_x:0,_y:50});
            _root.itemglow(attacker.weapon,game_attacker.secondary_weapon_enchantment_type,game_attacker.secondary_weapon_enchantment_potency);
            _root.battlevalues(game_attacker);
         }
         else
         {
            game_attacker.equipped_weapon = 1;
            attacker.weapon.realweapon.attachMovie("weapon" + game_attacker.weapon,"weapon",0,{_x:0,_y:0});
            attacker.Rlowerarm.attachMovie("shield" + game_attacker.shield,"shield",3,{_x:0,_y:50});
            _root.itemglow(attacker.weapon,game_attacker.weapon_enchantment_type,game_attacker.weapon_enchantment_potency);
            _root.battlevalues(game_attacker);
         }
         nextphase();
      }
   }
   if(phase_decision == "wincrowd")
   {
      _global.crowd_action = Math.round(_root.game.hero.charisma / 2);
      game_attacker.staminacost = 3;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         if(attacker.wincrowd_move <= 0 || attacker.wincrowd_move == undefined)
         {
            attacker.wincrowd_move = 1 + random(6);
         }
         attacker.wincrowd_move += 1;
         if(attacker.wincrowd_move > 6)
         {
            attacker.wincrowd_move = 1;
         }
         animstate = String("wincrowd" + attacker.wincrowd_move);
         attacker.gotoAndPlay(animstate);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "rest")
   {
      _global.crowd_action = -2;
      game_attacker.staminacost = - Math.round(game_attacker.stamina * 15);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("rest");
         game_attacker.hitpoints += 3 + Math.ceil(game_attacker.stamina);
         bonus = game_attacker.stamina;
         game_attacker.staminaleft += bonus;
         add_stats_icon(game_attacker,attacker,bonus,1);
         check_stats(game_attacker);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "frozen")
   {
      _global.crowd_action = 0;
      game_attacker.staminacost = 0;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("frozen");
         if(game_attacker.equipped_weapon == 1)
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"frozen",5,game_defender.weapon_enchantment_damage);
         }
         else
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"frozen",5,game_defender.secondary_weapon_enchantment_damage);
         }
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "life_stolen")
   {
      _global.crowd_action = 0;
      game_attacker.staminacost = 0;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("lifesteal");
         if(game_attacker.equipped_weapon == 1)
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"lifesteal",6,game_defender.weapon_enchantment_damage);
         }
         else
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"lifesteal",6,game_defender.secondary_weapon_enchantment_damage);
         }
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "poisoned")
   {
      _global.crowd_action = 0;
      game_attacker.staminacost = 0;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("poisoned");
         if(game_attacker.equipped_weapon == 1)
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"poisoned",7,game_defender.weapon_enchantment_damage);
         }
         else
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"poisoned",7,game_defender.secondary_weapon_enchantment_damage);
         }
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "burning")
   {
      _global.crowd_action = 0;
      game_attacker.staminacost = 0;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("burning");
         if(game_attacker.equipped_weapon == 1)
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"burning",4,game_defender.weapon_enchantment_damage);
         }
         else
         {
            magic_damage_character(attacker,defender,game_attacker,game_defender,"burning",4,game_defender.secondary_weapon_enchantment_damage);
         }
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "drink_potion")
   {
      _global.crowd_action = -3;
      game_attacker.staminacost = 0;
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attacker.gotoAndPlay("drink_potion");
         attacker.potions.gotoAndPlay(game_attacker.inventory_action - 1);
         if(game_attacker.inventory_action == 2)
         {
            bonus = Math.round(game_attacker.hitpointsmax * 0.25);
            game_attacker.hitpoints += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(1);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 3)
         {
            bonus = Math.round(game_attacker.hitpointsmax * 0.5);
            game_attacker.hitpoints += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(1);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 4)
         {
            bonus = Math.round(game_attacker.hitpointsmax * 0.75);
            game_attacker.hitpoints += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(1);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 5)
         {
            bonus = game_attacker.hitpointsmax;
            game_attacker.hitpoints += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(1);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 6)
         {
            bonus = Math.round(game_attacker.staminamax * 0.5);
            game_attacker.staminaleft += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(2);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 7)
         {
            bonus = Math.round(game_attacker.staminamax);
            game_attacker.staminaleft += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(2);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 8)
         {
            bonus = Math.round(game_attacker.armourclass * 0.5);
            game_attacker.armourclass += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(3);
            bonus_icon.bonus = "+ " + bonus;
         }
         if(game_attacker.inventory_action == 9)
         {
            bonus = Math.round(game_attacker.armourclass_max);
            game_attacker.armourclass += bonus;
            bonus_icon = attacker.attachMovie("bonus_icon","bonus_icon",25001);
            bonus_icon.damage_splat.gotoAndStop(3);
            bonus_icon.bonus = "+ " + bonus;
         }
         check_flipping(bonus_icon,attacker);
         check_stats(game_attacker);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "shove")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.strength * 1.5);
      if(attacker.shove != true)
      {
         attacker.shove = true;
         attacker.gotoAndPlay("shove");
         if(attacker.gladiator_dir == "right")
         {
            force = game_attacker.strength * 12;
            force_bonus = get_percentage(100 + game_attacker.gauntlet * 2,100);
            force = add_percentage(force,force_bonus);
            if(force < 20)
            {
               force = 20;
            }
            if(force > 100)
            {
               defender.gotoAndPlay("knockback");
            }
         }
         else
         {
            force = game_attacker.strength * 12;
            force_bonus = get_percentage(100 + game_attacker.gauntlet * 2,100);
            force = add_percentage(force,force_bonus);
            force = - force;
            if(force > -20)
            {
               force = -20;
            }
            if(force < -100)
            {
               defender.gotoAndPlay("knockback");
            }
         }
         knockback(defender,force);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         attacker.shove = null;
         nextphase();
      }
   }
   if(phase_decision == "power_attack")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.strength * 3);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attack_direction = randomBetween(9,12);
         if(attack_direction == 9)
         {
            attacker.gotoAndPlay("Attack9");
         }
         if(attack_direction == 10)
         {
            attacker.gotoAndPlay("Attack10");
         }
         if(attack_direction == 11)
         {
            attacker.gotoAndPlay("Attack11");
         }
         if(attack_direction == 12)
         {
            attacker.gotoAndPlay("Attack12");
         }
         checkattackroll();
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "normal_attack")
   {
      game_attacker.staminacost = Math.round(game_attacker.strength * 2);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attack_direction = randomBetween(5,8);
         if(attack_direction == 5)
         {
            attacker.gotoAndPlay("Attack5");
         }
         if(attack_direction == 6)
         {
            attacker.gotoAndPlay("Attack6");
         }
         if(attack_direction == 7)
         {
            attacker.gotoAndPlay("Attack7");
         }
         if(attack_direction == 8)
         {
            attacker.gotoAndPlay("Attack8");
         }
         checkattackroll();
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "quick_attack")
   {
      _global.crowd_action = -1;
      game_attacker.staminacost = Math.round(game_attacker.strength);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attack_direction = randomBetween(1,4);
         if(attack_direction == 1)
         {
            attacker.gotoAndPlay("Attack1");
         }
         if(attack_direction == 2)
         {
            attacker.gotoAndPlay("Attack2");
         }
         if(attack_direction == 3)
         {
            attacker.gotoAndPlay("Attack3");
         }
         if(attack_direction == 4)
         {
            attacker.gotoAndPlay("Attack4");
         }
         checkattackroll();
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "bash_attack")
   {
      game_attacker.staminacost = Math.round(game_attacker.strength * 2);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         attack_direction = 23;
         attacker.gotoAndPlay("Attack2");
         checkattackroll();
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "psyche_up")
   {
      game_attacker.staminacost = Math.round(game_attacker.strength);
      if(attacker.struck == null)
      {
         attacker.struck = false;
         if(game_attacker.psyche_up == 1)
         {
            attacker.gotoAndPlay("psyche_up");
         }
         if(game_attacker.psyche_up == 2)
         {
            t;
            attacker.gotoAndPlay("psyche_up2");
         }
         if(game_attacker.psyche_up == 3)
         {
            _global.crowd_action = 3;
            attacker.gotoAndPlay("psyche_up3");
            if(game_attacker.psyche_up == 3)
            {
               if(attacker.gladiator_dir == "right")
               {
                  if(attacker._x > Math.round(defender._x - (game_attacker.weapon_range + 50)))
                  {
                     attack_direction = 30;
                     checkattackroll();
                  }
               }
               if(attacker.gladiator_dir == "left")
               {
                  if(attacker._x < Math.round(defender._x + (game_attacker.weapon_range + 50)))
                  {
                     attack_direction = 30;
                     checkattackroll();
                  }
               }
            }
            game_attacker.psyche_up = 1;
         }
      }
      if(attacker.struck == true)
      {
         game_attacker.psyche_up += 1;
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "taunt")
   {
      _global.crowd_action = -2;
      game_attacker.staminacost = Math.round(game_attacker.charisma * 2);
      taunttimer++;
      game_attacker.staminacost = - Math.round(game_attacker.stamina * 15);
      if(taunttimer > 60)
      {
         taunttimer = 0;
         attacker.struck = null;
         nextphase();
      }
      if(attacker.struck == null)
      {
         game_attacker.hitpoints += 3 + Math.ceil(game_attacker.stamina);
         bonus = game_attacker.stamina;
         game_attacker.staminaleft += bonus;
         add_stats_icon(game_attacker,attacker,bonus,1);
         check_stats(game_attacker);
         taunttimer = 1;
         attacker.struck = false;
         attacker.gotoAndPlay("taunt");
         defender.gotoAndPlay("taunted");
         diceroll = randomBetween(1,100);
         if(diceroll < game_attacker.taunt_percentage)
         {
            taunt_effect = randomBetween(1,2);
            if(taunt_effect == 1)
            {
               attack_direction = 20;
               checkattackroll();
            }
            else if(game_defender.equipped_weapon == 1)
            {
               if(attacker.gladiator_dir == "right")
               {
                  force = game_attacker.charisma * 25;
                  if(force < 20)
                  {
                     force = 20;
                  }
                  if(force > 100)
                  {
                     defender.gotoAndPlay("knockback");
                  }
               }
               else
               {
                  force = - game_attacker.charisma * 25;
                  if(force > -20)
                  {
                     force = -20;
                  }
                  if(force < -100)
                  {
                     defender.gotoAndPlay("knockback");
                  }
               }
               knockback(defender,force);
            }
            else
            {
               game_defender.psyche_up = 1;
               game_defender.taunted1 = true;
               if(game_defender == _root.game.hero.villain)
               {
                  villainChooseAction;
               }
            }
         }
         else
         {
            defender_blocked();
         }
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "bombardright" || phase_decision == "bombardleft" || phase_decision == "sniperight" || phase_decision == "snipeleft")
   {
      _global.crowd_action = -1;
      game_attacker.staminacost = Math.round(game_attacker.strength * 3);
      if(attacker.struck == null)
      {
         game_attacker.ammo_left -= 1;
         attacker.struck = false;
         bullet_in_air = true;
         if(phase_decision == "bombardright" || phase_decision == "bombardleft")
         {
            attacker.gotoAndPlay("bombard");
            attack_direction = 21;
         }
         else
         {
            attacker.gotoAndPlay("snipe");
            attack_direction = 22;
         }
      }
      if(bullet._y > 160 || bullet._x > defender._x && attacker.gladiator_dir == "right" || bullet._x < defender._x && attacker.gladiator_dir == "left")
      {
         checkattackroll();
         bullet_in_air = false;
         bullet.removeMovieClip();
      }
      if(attacker.fired == true)
      {
         attacker.fired = false;
         bulletdepth = 45000;
         bullet = _root.arena.gladiators.attachMovie("bullet","bullet" + bulletdepth,bulletdepth);
         bullet.gotoAndStop(game_attacker.secondary_weapon - 60);
         if(attacker.gladiator_dir == "right")
         {
            bullet._x = attacker._x + 30;
         }
         else
         {
            bullet._x = attacker._x - 30;
         }
         bullet._y = attacker._y - (attacker._yscale * 2 + 30);
         if(phase_decision == "sniperight" || phase_decision == "snipeleft")
         {
            bullet._y = attacker._y - (attacker._yscale * 1.5 + 5);
         }
         bullet.bulletlife = 1;
         bullet.bulletcounter = 1;
         bullet.gravity = 2;
         if(attacker.gladiator_dir == "right")
         {
            bullet.distance_to_enemy = Math.abs(attacker._x - defender._x);
         }
         else
         {
            bullet.distance_to_enemy = Math.abs(defender._x - attacker._x);
         }
         if(phase_decision == "bombardright" || phase_decision == "bombardleft")
         {
            if(_global.maxscale == 80)
            {
               bullet.Xvelocity = randomBetween(8,18);
            }
            if(_global.maxscale < 80)
            {
               bullet._xscale = bullet._yscale = 100;
               bullet.Xvelocity = randomBetween(16,24);
            }
            if(_global.maxscale <= 60)
            {
               bullet._xscale = bullet._yscale = 130;
               bullet.Xvelocity = randomBetween(20,30);
            }
            if(_global.maxscale <= 40)
            {
               bullet._xscale = bullet._yscale = 160;
               bullet.Xvelocity = randomBetween(30,36);
            }
         }
         else
         {
            bullet.Xvelocity = randomBetween(60,60);
         }
         bullet.Yvelocity = Math.ceil(bullet.distance_to_enemy / bullet.Xvelocity);
         bullet.onEnterFrame = function()
         {
            bullet.bulletcounter = bullet.bulletcounter + 1;
            if(bullet.bulletcounter >= 3)
            {
               bullet.bulletcounter = 1;
               bullettrail_depth = _root.arena.gladiators.getNextHighestDepth();
               bullet_trail = _root.arena.gladiators.attachMovie("bullet_trail","bullet_trail" + bullettrail_depth,bullettrail_depth,{_x:this._x,_y:this._y,_rotation:this._rotation});
               bullet_trail.bullet.gotoAndStop(game_attacker.secondary_weapon - 60);
            }
            bullet.Yvelocity -= bullet.gravity;
            if(phase_decision == "bombardright" || phase_decision == "bombardleft")
            {
               bullet._y -= bullet.Yvelocity;
            }
            if(phase_decision == "bombardright" || phase_decision == "sniperight")
            {
               bullet._x += bullet.Xvelocity;
               if(phase_decsion == "sniperight")
               {
                  bullet._x += bullet.Xvelocity;
               }
            }
            else
            {
               bullet._x -= bullet.Xvelocity;
               if(phase_decsion == "snipeleft")
               {
                  bullet._x -= bullet.Xvelocity;
               }
            }
            bullet.bulletlife += bullet.Xvelocity;
            if(phase_decision == "bombardright" || phase_decision == "bombardleft")
            {
               bullet.bulletrotus = Math.round(bullet.bulletlife / (bullet.Xvelocity / (bullet.gravity * 2)));
            }
            else if(phase_decision == "sniperight")
            {
               bullet._rotation = 90;
            }
            else
            {
               bullet._rotation = -90;
            }
            if(bullet.bulletrotus > 170)
            {
               bullet.bulletrotus = 170;
            }
            bullet._rotation = bullet.bulletrotus;
            if(attacker.gladiator_dir == "left")
            {
               bullet._rotation = - bullet.bulletrotus;
            }
         };
      }
   }
   if(phase_decision == "cast_teleport")
   {
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,48);
         _root.arena.gladiators.attachMovie("circlets","circlets",_root.arena.gladiators.getNextHighestDepth(),{_x:attacker._x,_y:200});
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
      }
      combatscale();
      if(attacker.struck == true)
      {
         attacker._x = randomBetween(-2000,2000);
         attacker.gotoAndPlay("Cast2");
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_adulation")
   {
      _global.crowd_action = 50;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,47);
         attacker.struck = false;
         attacker.gotoAndPlay("wincrowd1");
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_weaken_armour")
   {
      _global.crowd_action = 4;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,44);
         attacker.struck = false;
         attacker.gotoAndPlay("Cast1");
         attack_direction = 1 + random(9);
         remove_armour(game_defender,defender,attack_direction);
         attack_direction = 1 + random(9);
         remove_armour(game_defender,defender,attack_direction);
         attack_direction = 1 + random(9);
         remove_armour(game_defender,defender,attack_direction);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_whirlwind")
   {
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,37);
         attacker.gotoAndPlay("psyche_up3");
         attacker.struck = false;
         if(attacker.gladiator_dir == "right")
         {
            if(attacker._x > Math.round(defender._x - (game_attacker.weapon_range + 50)))
            {
               attack_direction = 30;
               checkattackroll();
            }
         }
         if(attacker.gladiator_dir == "left")
         {
            if(attacker._x < Math.round(defender._x + (game_attacker.weapon_range + 50)))
            {
               attack_direction = 30;
               checkattackroll();
            }
         }
         game_attacker.psyche_up = 1;
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_gale")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.shove != true)
      {
         cast_spell_icon(attacker,38);
         attacker.shove = true;
         attacker.gotoAndPlay("Cast1");
         if(attacker.gladiator_dir == "right")
         {
            force = 1000;
         }
         else
         {
            force = -1000;
         }
         defender.gotoAndPlay("knockback");
         knockback(defender,force);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         attacker.shove = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_command")
   {
      _global.crowd_action = 2;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.shove != true)
      {
         cast_spell_icon(attacker,39);
         defender.gotoAndPlay("knockback_mov");
         attacker.shove = true;
         attacker.gotoAndPlay("Cast2");
      }
      if(attacker.gladiator_dir == "right")
      {
         defender._x -= 40;
         if(defender._x <= attacker._x + game_defender.physical_size)
         {
            attacker.struck = null;
            attacker.shove = false;
            nextphase();
         }
      }
      else if(attacker.gladiator_dir == "left")
      {
         defender._x += 40;
         if(defender._x >= attacker._x - game_defender.physical_size)
         {
            attacker.struck = null;
            attacker.shove = false;
            nextphase();
         }
      }
   }
   if(phase_decision == "cast_ghost_strike")
   {
      _global.crowd_action = 5;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,36);
         attacker.blendMode = "add";
         attacker_old_x = attacker._x;
         if(attacker.gladiator_dir == "left")
         {
            attacker._x = defender._x + game_attacker.physical_size;
         }
         else
         {
            attacker._x = defender._x - game_attacker.physical_size;
         }
         attacker.struck = false;
         attack_direction = randomBetween(9,12);
         if(attack_direction == 9)
         {
            attacker.gotoAndPlay("Attack9");
         }
         if(attack_direction == 10)
         {
            attacker.gotoAndPlay("Attack10");
         }
         if(attack_direction == 11)
         {
            attacker.gotoAndPlay("Attack11");
         }
         if(attack_direction == 12)
         {
            attacker.gotoAndPlay("Attack12");
         }
         checkattackroll();
      }
      if(attacker.struck == true)
      {
         attacker._x = attacker_old_x;
         attacker.blendMode = "normal";
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_colossus")
   {
      attacker.spell_colossus = 16;
      _global.crowd_action = 15;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,42);
         attacker.struck = false;
         attacker.gotoAndPlay("Colossus");
         attacker.oldscale = attacker._yscale;
         attacker.newscale = 450;
         game_attacker.strength = game_attacker.backup_strength * 3;
         game_attacker.attack = game_attacker.backup_attack * 2;
      }
      attacker._yscale = Math.ceil((attacker.newscale - attacker._yscale) / 2);
      attacker._xscale = attacker._yscale;
      if(attacker.gladiator_dir == "left")
      {
         attacker._x -= 2;
      }
      else
      {
         attacker._x += 2;
      }
      if(attacker._yscale >= attacker.newscale)
      {
         attacker._yscale = attacker._xscale = attacker.newscale;
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_little_fat_kid")
   {
      defender.spell_little_fat_kid = 16;
      _global.crowd_action = 10;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(defender.struck == null)
      {
         attacker.gotoAndPlay("Cast2");
         cast_spell_icon(attacker,33);
         defender.struck = false;
         defender.gotoAndPlay("little_fat_kid");
         defender.oldscale = Number(defender._yscale);
         defender.newscale = 50;
         game_defender.strength = Math.round(game_defender.backup_strength / 2);
         game_defender.attack = Math.round(game_defender.backup_attack / 2);
      }
      defender._yscale = Math.ceil((defender.newscale - defender._yscale) / 2);
      defender._xscale = defender._yscale;
      if(defender._yscale <= defender.newscale)
      {
         defender._yscale = defender._xscale = defender.newscale;
         defender.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_lightning_bolt" || phase_decision == "cast_frightning_bolt")
   {
      _global.crowd_action = 5;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         if(phase_decision == "cast_lightning_bolt")
         {
            cast_spell_icon(attacker,34);
            lightning_damage = randomBetween(100,200);
            lightning_frame = 1;
         }
         if(phase_decision == "cast_frightning_bolt")
         {
            cast_spell_icon(attacker,35);
            lightning_damage = randomBetween(200,400);
            lightning_frame = 2;
         }
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
         bolt = _root.arena.gladiators.attachMovie("lightning_bolt_combat","lightning_bolt_combat",_root.arena.gladiators.getNextHighestDepth(),{_x:defender._x,_y:50});
         magic_damage_character(defender,attacker,game_defender,game_attacker,"lightning",8,lightning_damage);
         bolt.gotoAndStop(lightning_frame);
      }
      if(defender.struck == true)
      {
         bolt.removeMovieClip();
         attacker.struck = null;
         defender.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_death_from_above")
   {
      _global.crowd_action = 20;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,49);
         boulder_stones = randomBetween(10,20);
         lightning_frame = 1;
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
         i = 1;
         while(i <= boulder_stones)
         {
            boulder = _root.arena.gladiators.attachMovie("boulder_combat","boulder_combat" + i,_root.arena.gladiators.getNextHighestDepth(),{_x:defender._x,_y:-600});
            boulder._x += randomBetween(-300,300);
            boulder._y = randomBetween(-600,-800);
            boulder.yspeed = randomBetween(50,150);
            boulder._xscale = boulder._yscale = randomBetween(50,100);
            boulder.cacheAsBitmap = true;
            boulder.onEnterFrame = function()
            {
               if(this._y <= 150)
               {
                  this._y += this.yspeed;
               }
               if(this._y > 150 && this.bounced != true)
               {
                  this.bounced = true;
                  this.cacheAsBitmap = false;
                  this.gotoAndStop(4);
                  magic_damage_character(defender,attacker,game_defender,game_attacker,"burning",4,40);
               }
            };
            i++;
         }
      }
      if(defender.struck == true)
      {
         bolt.removeMovieClip();
         attacker.struck = null;
         defender.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_swiftsandals")
   {
      attacker.spell_swiftsandals = 20;
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,40);
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
         game_attacker.speed = 10 + game_attacker.backup_speed * 2;
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_bloodlust")
   {
      attacker.spell_bloodlust = 20;
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,41);
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
         game_attacker.strength = 10 + Math.round(game_attacker.backup_strength * 1.5);
         game_attacker.defence = Math.round(game_attacker.backup_defence * 0.5);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_regenerate")
   {
      attacker.spell_regenerate = 20;
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,46);
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_boundless_energy")
   {
      attacker.spell_boundless_energy = 20;
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,45);
         attacker.struck = false;
         attacker.gotoAndPlay("Cast2");
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_rejuvinate")
   {
      _global.crowd_action = 3;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         cast_spell_icon(attacker,43);
         attacker.struck = false;
         attacker.gotoAndPlay("Rejuvinate");
         game_attacker.hitpoints = game_attacker.hitpointsmax;
         game_attacker.staminaleft = game_attacker.staminamax;
         game_attacker.armourclass = game_attacker.armourclass_max;
         game_attacker.shoulderguard = whichcharacter.backup_shoulderguard;
         game_attacker.gauntlet = game_attacker.backup_gauntlet;
         game_attacker.breastplate = game_attacker.backup_breastplate;
         game_attacker.helmet = game_attacker.backup_helmet;
         game_attacker.greaves = game_attacker.backup_greaves;
         game_attacker.shinguard = game_attacker.backup_shinguard;
         game_attacker.boot = game_attacker.backup_boot;
         game_attacker.weapon = game_attacker.backup_weapon;
         game_attacker.shield = game_attacker.backup_shield;
         _root.updatecharacter(game_attacker,attacker);
      }
      if(attacker.struck == true)
      {
         attacker.struck = null;
         nextphase();
      }
   }
   if(phase_decision == "cast_fireball" || phase_decision == "cast_hell_fireball" || phase_decision == "cast_dire_fireball")
   {
      _global.crowd_action = 5;
      game_attacker.staminacost = Math.round(game_attacker.magicka);
      if(attacker.struck == null)
      {
         bullet_in_air = true;
         if(phase_decision == "cast_fireball")
         {
            cast_spell_icon(attacker,30);
            fireball_damage = randomBetween(80,160);
            fireball_frame = 1;
         }
         if(phase_decision == "cast_hell_fireball")
         {
            cast_spell_icon(attacker,31);
            fireball_damage = randomBetween(150,450);
            fireball_frame = 2;
         }
         if(phase_decision == "cast_dire_fireball")
         {
            cast_spell_icon(attacker,32);
            fireball_damage = randomBetween(300,600);
            fireball_frame = 3;
         }
         attacker.struck = false;
         attacker.fired = true;
         attacker.gotoAndPlay("Cast1");
      }
      if(bullet._x > defender._x && attacker.gladiator_dir == "right" || bullet._x < defender._x && attacker.gladiator_dir == "left")
      {
         if(bullet._currentframe != 4)
         {
            magic_damage_character(defender,attacker,game_defender,game_attacker,"burning",4,fireball_damage);
            bullet.gotoAndStop(4);
            bullet.flying = false;
            bullet_in_air = false;
         }
      }
      if(attacker.fired == true)
      {
         attacker.fired = false;
         bulletdepth = 45000;
         bullet = _root.arena.gladiators.attachMovie("fireball_combat","fireball_combat" + bulletdepth,bulletdepth);
         bullet.gotondStop(fireball_frame);
         if(attacker.gladiator_dir == "right")
         {
            bullet._x = attacker._x + 30;
         }
         else
         {
            bullet._x = attacker._x - 30;
            bullet._xscale = - bullet._xscale;
         }
         bullet._y = attacker._y - (attacker._yscale * 1.5 + 5);
         bullet.bulletlife = 1;
         bullet.bulletcounter = 1;
         bullet.gravity = 2;
         if(attacker.gladiator_dir == "right")
         {
            bullet.distance_to_enemy = Math.abs(attacker._x - defender._x);
         }
         else
         {
            bullet.distance_to_enemy = Math.abs(defender._x - attacker._x);
         }
         if(phase_decision == "cast_fireball")
         {
            bullet.Xvelocity = 50;
         }
         if(phase_decision == "cast_hell_fireball")
         {
            bullet.Xvelocity = 70;
         }
         if(phase_decision == "cast_dire_fireball")
         {
            bullet.Xvelocity = 90;
         }
         bullet.onEnterFrame = function()
         {
            if(bullet.flying != false)
            {
               if(attacker.gladiator_dir == "right")
               {
                  bullet._x += bullet.Xvelocity;
               }
               else
               {
                  bullet._x -= bullet.Xvelocity;
               }
            }
         };
      }
   }
};
```
