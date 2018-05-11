pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--global varibales, update, draw, init, etc

-- size of the screen in pixels
screen_x = 128
screen_y = 128

-- timer
last = 0
now = 0
last_attack = 0
attack_cooldown = 0.5
start_run = 0
end_run = 0

-- 0 = menu
-- 1 = game
-- 2 = game over
-- 4 = warning
game_state = 0

-- in game variables
max_y = 112
x = 10  y = 112
gravity = 0.9
--in order to not spawn too many
z_number = 0
max_z_number = 0

-- animation
animation_speed = 3
frame = 0

-- arrays
actor = {}
zombie = {}
obstacle = {}
interaction = {}
bullet = {}

jump = false
bullet_shoot = false
house = false
haunted_house = false
first_time = true

-- map
last_map = 1
last_x = x

-- menu 
win = false

function _update()
	if game_state == 0 then
		update_menu()
	elseif game_state == 1 then
		update_game()
	elseif game_state == 2 then
		update_gameover()
	elseif game_state == 3 then
		update_win()
	elseif game_state == 4 then
		update_warning()
	end
end

function _draw()
	cls()
	if game_state == 0 then
		draw_menu()
	elseif game_state == 1 then
		draw_game()
	elseif game_state == 2 then
		draw_gameover()
	elseif game_state == 3 then
		draw_win()
	elseif game_state == 4 then
		draw_warning()
	end
end

function _init()
	menuinit()
	game_state=4
end

function gameinit()
	map()
	start_run = time()
	game_state = 1
	game_map = 1
	game_map_init()
	player = make_actor(x,y)
end

function game_map_init()
	clear_everything()	
	house = false
	haunted_house = false
	max_y = 112
	
	if game_map == 1 then
		make_interaction(50,108,6,18,118,3,0)
	end
end

function wall_house()
	-- wall left
	make_obstacle(0,80,6,8,16)
	make_obstacle(0,88,6,8,16)
	-- wall right
	make_obstacle(120,80,8,8,16)
	make_obstacle(120,88,8,8,16)
	make_obstacle(120,96,8,8,16)
	make_obstacle(120,104,8,8,16)
	make_obstacle(120,112,8,8,16)
	make_obstacle(120,120,8,8,16)
end

function update_game()	
	
	if game_map>6 then 
		game_map=1
	end
	
	if game_map<1 then
		game_map=6
	end
		
	if a.noise >= 0.5 then
		a.noise -=0.5
	else
		a.noise = 0
	end
	
	if a.noise < 0 then
		a.noise = 0
	end
	
	if a.noise > 100 then
		a.noise = 100
	end
	
	if a.y > screen_y-2 then
		a.hp=0
	end
	
	if a.hp == 0 then
		game_state = 2
		sfx(1)
		clear_everything()
		for z in all(zombie) do
			del(zombie,z)
		end
	end	
	
	if a.noise>99 and z_number < max_z_number then		
		repeat
			z_x = rnd(screen_x-10)+10	
		until not is_in_obstacle(z_x,6)
		make_zombie(z_x,112,rnd(75)*0.01+0.5,game_map)
		z_number+=1
		a.noise-=30
	end

	if a.x <= 0 then
		clear_everything()
	 	a.x = screen_x-5
	 	a.new_x = screen_x-5
			game_map-=1
		game_map_init()
	end
	
	if a.x+3 >= screen_x and not house then
		game_map+=1
		clear_everything()
		a.x = 3
		a.new_x = 3
		game_map_init()
	end
	
	control_player()
	bullet_moving()
	zombie_moving()
end


function is_in_obstacle(x,h)
	for o in all(obstacle) do
		if x+h >= o.x and x <= o.x+o.h then 
			return true
		end
	end
	return false
end

function clear_everything()
	for b in all(bullet) do
		del(bullet,b)
	end
	for o in all(obstacle) do
		del(obstacle,o)
	end
	for i in all(interaction) do
		del(interaction,i)
	end
end
-->8
-- draw --

function draw_player()
	if a.invincible > 20 then
		pal(15,8)
		if a.invincible > 25 then
			spr(112,a.x,a.y-13)
			sfx(0)
		end
	else
		pal()
	end
 
	if a.invincible%2==0 or a.invincible<0 then
  spr(a.state,a.x,a.y-6)
		spr(a.state+16,a.x,a.y)
	end
		
		--in case there is a weapon to show
		if a.state == 71 then
			spr(a.state+32,a.x-8,a.y-6)
			spr(a.weapon, a.x-8,a.y-6,1,1,true,false)
		end
		if a.state == 72 then
			spr(a.state+32,a.x+8,a.y-6)
			spr(a.weapon,a.x+8,a.y-6)
		end
		
		a.frame+=1
end

function draw_bullet()
	for b in all(bullet) do
		spr(b.spr,b.x,b.y)
	end
end

function draw_interaction()
	for i in all(interaction) do
		if i.type_interaction != 1 then
			if a.frame%10<4 then
				spr(126,i.x,i.y)
			else
				spr(127,i.x,i.y)
			end
			spr(i.spr,i.x,i.y)
		end
	end
end

function draw_zombies()
 for z in all(zombie) do
 	if z.on_map then	
 	 if z.spawning < 0 then
		 	if z.hurt then
		 		spr(79,z.x,z.y-6)
		 		spr(95,z.x,z.y)
		 		z.hurt = false
		 	else
		 		spr(78,z.x,z.y-6)
		 		spr(94,z.x,z.y)
		 	end
		 else
		  if (z.spawning > 40) then
		  	spr(77,z.x,z.y+5)
		  elseif (z.spawning > 20) and (z.spawning < 40) then
		  	spr(76,z.x,z.y+1)
		  	spr(92,z.x,z.y+7)
		  elseif (z.spawning > 0) and (z.spawning < 20) then
		  	spr(75,z.x,z.y-2)
		  	spr(91,z.x,z.y+4)
		  end
	  end
	 end
	end
end

function draw_obstacles()
	for o in all(obstacle) do	
		if o.hurt then
			spr(65,o.x,o.y)
		else	
			spr(o.spr,o.x,o.y)
		end
	end
end

function draw_hud()
	-- noise bar background
	rectfill(39,2,89,4,5)
	-- noise bar
	if flr(a.noise)==100 then
		rectfill(39,2,39+a.noise/2,4,8)
	else
		rectfill(39,2,39+a.noise/2,4,11)
	end
		
	-- ♥♥♥ hp bar
	-- interval between hearts
	cpt=0
	for i=1,a.hp do
		spr(114,30+cpt,11)
		cpt+=10
	end
	
	-- weapon
	spr(99,50,21)
	spr(100,70,21)
	spr(115,50,37)
	spr(116,70,37)
	spr(a.weapon,60,29)
end

function draw_gameover()
	print("game over ...",43,60,6)	
	print("press 🅾️ or ❎ to continue.",15,75,6)
	sfx(1)	
end

function draw_warning()
 now = time()
 print("░ survival zombies ░",22,33,frame%2+11)
	print("will you survive enough time",8,60,frame%2+11)
	print("to be the last one on earth ?",6,70,frame%2+11)
	print("tip : you can hide in houses ! ",4,80,frame%2+11)
	if (now - last)>1 then	
		print("press 🅾️ or ❎ to continue",12,100,time()%2+7)	
	end
	frame+=1
end

function draw_win()
	win = true
	-- https://www.lexaloffle.com/bbs/?tid=3726
	-- found it cool but maybe make some changes ?
	t=0 
	while not btn(4) or btn(5) do 
		t+=1 
		cls(1) 
		for x=0,63 do 
			for y=0,63 do
				pset(x*2+y%2,y*2,8+(t/16+((x-32)/(y-32)))%8)  
			end 
		end 
		print("you survived !", 64 - (14 * 2), 60, 0) 
		print("your time : ", 64 - (10*2),70,0)
		-- timer
		act = time()-end_run
		minutes = flr(act/60)
		seconds = flr(act%60)
		mil_seconds = flr((act%1)*10000)
		
		print(minutes,43,78,0)
		print(":",51,78,0)
		print(seconds,55,78,0)
		print(":",63,78,0)
		print(mil_seconds,68,78,0)
		flip() 
	end
	game_state = 4
end

function draw_menu()
	cls(col2)
 draw_options()
 if (octopus==true) then
 	draw_octopus()
 end
end

function draw_game()
	cls()
	if game_map == 1 then
	 map(0,0,0,64,16,8)
	elseif game_map == 2 then
		map(16,0,0,64,16,8)
	elseif game_map == 3 then
		map(32,0,0,64,16,8)
	elseif game_map == 4 then
		map(48,0,0,64,16,8)
	elseif game_map == 5 then
		map(64,0,0,64,16,8)
	elseif game_map == 6 then
		map(80,0,0,64,16,8)
end
		
		draw_player()
		draw_zombies()
		draw_obstacles()
		draw_bullet()
		draw_interaction()
		draw_hud()
		
		-- hitboxes

		-- player
  -- rectfill(a.x,a.y-a.h,a.x+a.w,a.y+a.h,14)
 	
 	-- interactions items
 	-- for i in all(interaction) do
  -- rectfill(i.x,i.y,i.x+i.w,i.y+i.h,14)
	 -- end
		
		-- obstacles
	 -- for o in all(obstacle) do
	 -- rectfill(o.x,o.y,o.x+o.w,o.y+o.h,14)
	 -- end
	 
	 -- zombies
		-- for z in all(zombie) do
		-- 	rectfill(z.x,z.y-6,z.x+z.w,z.y+z.h,14)
		-- end
end
-->8
-- player --

function make_actor(x, y)
 a={}
 a.x = x
 a.y = y
 a.new_x = x
 a.new_y = y
 a.h = 7
 a.w = 6
 a.spr = 3
 a.frame = 0
 a.noise = 0
 a.hp = 7
 a.weapon = 117
 a.invincible=0
 
 -- state of the player :
 -- 64- normal, the player stand without moving
 -- 65- running left
 --	66- running right
 -- 67- jumping horizontaly
 -- 68- jumping left
 -- 69- jumping right
 -- 70- falling
 -- 71- attacking left
 -- 72- attacking right
 -- 10- invincible
 
 a.state = 64
 
 add(actor,a)
return a
end

function control_player()
a.d_left = false
a.d_right = false

	if (a.y>=max_y) then 
		jump=false 
		a.state = 64
	end

	if (a.y<=max_y) then 
	 a.new_y=a.new_y+gravity
		if not player_obstacle_collision() then
			a.y=a.y+gravity
			a.state = 70
		else
			jump = false
			a.new_y=a.new_y-gravity
			a.state = 64 
		end
	end
	if (btn(0)) then
		a.new_x-=2.5
 	if not player_obstacle_collision() then
 		a.x-=2.5
 		if jump then
 			a.state = 68
 		else
 			a.state = 65
 		end
 		if a.noise < 100 then
 			a.noise+=1 
 		end
 	else
 		a.new_x+=2.5
		end
	end
	if (btn(1)) then
		a.new_x+=2.5
	 if not player_obstacle_collision() then
	  a.x+=2.5
	  if jump then
	 		a.state = 69
	 	else
	 		a.state = 66
	 	end
	  if a.noise < 100 then
	  	a.noise+=1
	  end
	 else
		 a.new_x-=2.5
	 end
	end

 if (btn(2)) then 
	 if (jump==false) then
		 --stop jumping when ecounter an obstacle
		 for i=1,15 do
	 		a.new_y-=1
		  if(not player_obstacle_collision(0,-1)) then
		  	a.y=a.y-1
		  else
		  	a.new_y+=1
		  end
		 end
	  jump=true
	  if a.noise<94 then
		  a.noise+=7
	  else 
	  	a.noise = 100
	  end
	 end
 end
 
	 --shoot
 if (btn(4)) then
 	now = time()
 	if now - last_attack > attack_cooldown then
			a.state = 71
			shoot_left()
			last_attack = time()
			
			if a.noise<92 then
	 	 a.noise+=9
	  else 
	 	 a.noise = 100
	 	end
		end
	end
	
 if(btn(5)) then
  now = time()
		if now-last_attack > attack_cooldown then
		 a.state = 72
 		shoot_right()
 		last_attack = time()
 		
			if a.noise<92 then
	 	 a.noise+=9
	 	else 
	 	 a.noise = 100
	 	end
		end
	end
	 
	 -- interact
 if btn(3) then
		if player_interaction_collision() then
			if actual_interaction.type_interaction == 1 then
				last_x = a.x
				last_map = game_map
				game_map = actual_interaction.type_map
 				a.x = 3
 				a.new_x = 3
 				sfx(2)
 				game_map_init()
			elseif actual_interaction.type_interaction == 2 then
				
 			elseif actual_interaction.type_interaction == 3 then
 				a.weapon = 118
 			elseif actual_interaction.type_interaction == 4 then
 			elseif actual_interaction.type_interaction == 5 then
 			end
		end
 end
	 
	a.invincible-=1 
	if a.invincible < 0 then
		if player_zombie_collision() then
			a.hp-=1
			a.invincible = 30
		end
	end 
end

function shoot_left()
 a.attacking_left = true
 a.attacking_right = false
 
 --weapon 117 = pistol
	if(a.weapon==117) then
		make_bullet(a.x-6,a.y-7,-1)
		sfx(5)
	end
	
end

function shoot_right()
 a.attacking_right = true
 a.attacking_left = false
 
	if(a.weapon==117) then
		make_bullet(a.x+6,a.y-7,1)
		sfx(5)
	end
end


function check_moving(moving)
	if(btn(0) or btn(1)) then
		moving = true
	else
	 moving = false
	end
	return moving
end

-->8
-- zombies --

function make_zombie(x,y,speed,gm)
	local z={}
	z.x = x
	z.y = y
	z.new_x = x
	z.new_y = y-8
	-- -8 because otherwise the top
	-- of the zombie isnt considered
	-- in the hitbox.
	z.h = 12
	z.w = 6
	z.spr = 75
	z.accel = 0
	z.speed = speed
	z.hp = 5
	z.hurt = false
	z.blocked = false
	-- frame until the zombie is
	-- out of the ground
	z.spawning = 50
	-- map where the zombie is located
	z.map_location = gm
	-- is on map
	z.on_map = true
	
	z.attacking_obstacle = 0
	
	add(zombie,z)
	
	return z
end

function accel_zombie()
	for z in all(zombie) do
		if(a.noise == 100) then 
			z.accel = 2
		elseif a.noise>=50 then
			z.accel = 1
		elseif a.noise==0 then
			z.accel = 0
		else
			z.accel = 0.5 
		end
	end
end

function zombie_moving()
	a.hurt = false
	-- maybe not very useful
	accel_zombie()
	
	for z in all(zombie) do
	
	z.accel = 1
	
		if z.map_location == game_map then
			z.on_map = true	
		else
			z.on_map = false
		end
	
		if z.spawning < 0 then
			if z.hurt and z.on_map then
				z.hp-=2
				sfx(6)
			end 
		
			if z.hp == 0 then
				del(zombie,z)
					z_number-=1
			end
			
			if z.on_map then
				if z.x < a.x-1 then
						z.new_x+=z.accel*z.speed
						if not zombie_obstacle_collision() then
							z.x+=z.accel*z.speed
						else
							z.new_x-=z.accel*z.speed
							end
						end
					elseif z.x > a.x+1 then
						z.new_x-=z.accel*z.speed
						if not zombie_obstacle_collision() then
							z.x-=z.accel*z.speed
						else
							z.new_x+=z.accel*z.speed
							end
						end
					end	
			
			if z.map_location < game_map then
				if z.x < screen_x-5 then
					z.x+=z.accel*z.speed
					z.new_x+=z.accel*z.speed
				else
					if game_map<7 then
						z.map_location+=1
						z.x = 3
						z.new_x = 3
					end	
				end
			end
			
			if z.map_location > game_map then
				if z.x > 5 then
					z.x-=z.accel*z.speed
					z.new_x-=z.accel*z.speed				
				else
					z.map_location-=1
					z.x = screen_x-3
					z.new_x = screen_x-3
				end
			end
	z.spawning-=1
	end
end

-->8
-- bullets, obstacles and interactions -- 

-- obstacles 

function make_obstacle(x,y,w,h,c_spr)
 local o={}
	o.x = x
	o.y = y
	o.new_x = x
	o.new_y = y
	o.w = w
	o.h = h
	o.spr = c_spr
	o.hp = 100
	
	add(obstacle,o)
	
	return o
end

-- interactions

function make_interaction(x,y,w,h,spr,ti,tm)
	local i={}
	i.x = x
	i.y = y
	i.new_x = x
	i.new_y = y
	i.w = w
	i.h = h
	i.spr = spr
	i.use = true
	-- doors = 1, weapon lvl1 = 2,  weapon lvl2 = 3,  weapon lvl3 = 4
	i.type_interaction = ti
	
	-- type_map : 
	-- 0 = not a door
	-- 98 = normal house
	i.type_map = tm
		
	add(interaction,i)
	
	return i
end

-- bullets

function make_bullet(x,y,dir)
	local b={}
	b.x = x
	b.y = y
	b.new_x = x
	b.new_y = y
	b.w = 5
	b.h = 2
	b.spr = 113
	b.speed = 4
	b.dir = dir

	add(bullet,b)
	
	return b
end


function bullet_moving()
	for b in all(bullet) do
	--if going right 
		if b.dir==1 then
			b.new_x+=b.speed
			if b.x < screen_x and not bullet_zombie_collision() and not bullet_obstacle_collision() then
				b.x+=b.speed
			else
				del(bullet,b)
			end
		end
		--if going left
		if b.dir==-1 then
			b.new_x-=b.speed
			if b.x > 0 and not bullet_zombie_collision() and not bullet_obstacle_collision() then
				b.x-=b.speed
			else
				del(bullet,b)
			end
		end		
	end
end
-->8
-- menu --

-- menu function
-- inspired by a code from : https://www.lexaloffle.com/bbs/?tid=27725
function lerp(startv,endv,per)
 return(startv+per*(endv-startv))
end

function change_palette()
 palnum+=1
 if (palnum>6)palnum=1
end

function update_cursor()
 if (btnp(2)) m.sel-=1 cx=m.x sfx(4)
 if (btnp(3)) m.sel+=1 cx=m.x sfx(4)
 if (btnp(4)) cx=m.x
 if (m.sel>m.amt) m.sel=1
 if (m.sel<=0) m.sel=m.amt
 cx=lerp(cx,m.x+5,0.5)
end

function draw_options()
 for i=1, m.amt do
  oset=i*8
  if i==m.sel then
   rectfill(cx,m.y+oset-1,cx+36,m.y+oset+5,col1)
   print(m.options[i],cx+1,m.y+oset,col2)
  else
   print(m.options[i],m.x,m.y+oset,col1)
  end
 end
end

function draw_octopus()
 if ox>m.x and ox<m.x+40 and
    oy>m.y and oy<m.y+32 then
   ox=rnd(112)+8
   oy=rnd(112)+8
 end
 pal(7,col1)
 spr(193,ox,oy) spr(194,ox+8,oy)
 spr(209,ox,oy+8) spr(210,ox+8,oy+8)
 pal()
end

function init_settings()
 m.sel=1
 m.options={"palette","moon","exit"}
 m.amt=0
 for i in all(m.options) do
  m.amt+=1
 end
 sub_mode=1
 menu_timer=0
end

function update_settings()
 if btnp(4) and
 menu_timer>1 then
  if m.options[m.sel]=="palette" then
   change_palette()
  elseif m.options[m.sel]=="moon" then
   octopus=not octopus
   ox=rnd(112)+8
   oy=rnd(112)+8
  elseif m.options[m.sel]=="exit" then
  	cls()
  	init_menu()
  end
 end
end

function update_menu()
	update_cursor()
 if sub_mode==0 then
  if btnp(4) and
  menu_timer>1 then
  	if m.options[m.sel]=="start" then
  		gameinit()
  	end
   if m.options[m.sel]=="settings" then
    init_settings()
   end
  end
 end
 
 if (sub_mode==1) update_settings()
 
 col1=pals[palnum][1]
 col2=pals[palnum][2]
 menu_timer+=1
end

function menuinit()
	octopus=false
 pals={{7,0},{15,1},{6,5},
			   {10,8},{7,3},{7,2}}
 palnum=5
 init_menu()
end

function init_menu()
	m={}
 m.x=8
 cx=m.x
 m.y=40
 m.options={"start","settings",
            "exit"}
 m.amt=0
 for i in all(m.options) do
  m.amt+=1
 end
 m.sel=1
 sub_mode=0
 menu_timer=0
end
-->8
-- game over, win and warning --

function warning_init() 
	last = time()
end

function update_warning()
	if (btn(4) or btn(5) or btn(10) or btn(11)) and (now-last)>1 then
		game_state = 0
	end
end

function win_init() 
	last = time()
end

function update_win()
	if (btn(4) or btn(5) or btn(10) or btn(11)) and (now-last)>1 then
		win = false
	end
end

function gameoverinit()
	game_state = 2
end

function update_gameover()
	if btn(4) or btn(5) then
		game_state = 0
	end
end
-->8
-- collisions --

-- test if a point is solid
function solid(box1,box2)
	if ((box2.new_x >= box1.new_x + box1.w) 
			or (box2.new_x + box2.w <= box1.new_x) 
			or (box2.new_y >= box1.new_y + box1.h) 
			or (box2.new_y + box2.h <= box1.new_y)) then		
		return false
	end
	
	return true
end

function player_obstacle_collision()
	for o in all(obstacle) do
		if solid(a,o) then
			return true
		end
	end
	return false
end

function player_interaction_collision()
	for i in all(interaction) do
		if solid(a,i) then
			actual_interaction = i
			return true
		end
	end
	return false
end

function player_zombie_collision()
	for z in all(zombie) do
		if solid(a,z) and z.spawning < 0 and z.on_map then
			return true
		end
	end
	return false
end

function bullet_zombie_collision()
	for b in all(bullet) do
		for z in all(zombie) do
			if solid(b,z) and z.on_map then
				z.hurt = true
				return true
			end
		end
	end
	return false
end

function bullet_obstacle_collision()
for b in all(bullet) do
		for o in all(obstacle) do
			if solid(b,o) then
				return true
			end
		end
	end
	return false
end

function zombie_obstacle_collision()
for z in all(zombie) do
		z.blocked = true
		for o in all(obstacle) do
			if solid(z,o) then
				z.blocked = true
				-- o.hurt = true
				return true
			end
		end
	end
	return false
end
__gfx__
00000000000000006666666666666666555555550000000066600000000000000000066600000000000000000000000000000000000000000000000000000000
00000000000000005555555566633666777777770000000006555555555555555555556000000000000000000000000000000000000000000000000000000000
00700700000000005555555566633666666666660000000006050505050505050505056000000000000000000000000000000000000000000000000000000000
00077000000000005555555563333336666666660000000006505050505050505050506000000000000000000000000000000000000000000000000000000000
00077000000000005555555563333336666666660000000006050505050505050505056000000000000000000000000000000000000000000000000000000000
00700700000000005555555566633666666666660000000006505050505050505050506000000000000000000000000000000000000000000000000000000000
00000000000000005555555566633666777777770000000006050505050505050505056000000000000000000000000000000000000000000000000000000000
00000000000000005555555566666666555555550000000006505050505050505050506000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55777777777777777777775556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55766767667677676676775556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55767767667667677676775556666666666666666666666500000000553555335555000000000000000000000000000000000000000000000000000000000000
55777777777777777777775556666666666666666666666500000005636365536666500000000000000000000000000000000000000000000000000000000000
55555555555555555555555556666666666666666666666500000056636633366666650000000000000000000000000000000000000000000000000000000000
55555555555555555555555556666666666666666666666500000566366663366666650000000000000000000000000000000000000000000000000000000000
55555555111111115555555556666666666666666666666500005553555535533555550000000000000000000000000000000000000000000000000000000000
57777775166666615777777556666666666666666666666500077777377737777377777000000000000000000000000000000000000000000000000000000000
56666665166666615766667556666666666666666666666500777777377773773737777000000000000000000000000000000000000000000000000000000000
56666665166666615766667556666666666666666666666500777773777773773737777000000000000000000000000000000000000000000000000000000000
56666665166666615766667556666666666666666666666500777735377737737553770000000000000000000000000000000000000000000000000000000000
56666665166666615766667556666666666666666666666500077536537377773663700000000000000000000000000000000000000000000000000000000000
57777775166666615766667556666666666666666666666500000536530300035665300000000000000000000000000000000000000000000000000000000000
55555555166661615777777556666666666666666666666500000355300030030550030000000000000000000000000000000000000000000000000000000000
55555555166661615777757556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777556666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555166666615777777555555555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000440000004400000044000000440000004400000044000000440000004400000000000000000000000000000000000000000000003300080088008
004ff400004ff400004ff400f04ff40f004ff400004ff400004ff400004ff400004ff40000000000000000000003300000033000000000000003300080088008
004ff400004ff400004ff400f044440f0044f400004f4400f044440f004ff400004ff40000000000000000000053350000533500005335000055550080555508
004444000044440000444400f044440f0044440000444400f044440f004444000044440000000000000000000555555005555550055335503533333385885558
0f4444f00f3443f00f3443f00f3443f00f344bf00f3443f0ff3443ffff4444f00f4444ff00000000000000000355533033555333335553333055535300555850
0fb333f000b33bf00fb3b30000333b000f33330ff0b3b3f0003b3b0000b3fff00fff3b0000000000000000000353333030535503305355033053550300585500
0f33b3f00f333ff00ff33bf000b33300ffb33b0ff0333bff00b3330000333b000033b30000000000000000003335550030355503303555033035550300855500
0f3333f0003b3b00003b33000033b3000033b30ff03b3300003b33000033b30000b33b0000000000000000003053530030535303305353030053530000585800
00b33b00003333000033b30000333b0000b3330000333b0000333b0000b333000033b30000000000000000000055550000555500000000000055550000555500
0033b3000033b30000b33b0000b3330000333b0000b333000033b30000333b0000b33b0000000000000000000033530000535300000000000053530000585800
00444400004444000044440000444400004444000044440000444400004444000044440000000000000000000553550003333330000000000035550000855500
00fddd0000fddd0000fddd0000fddd0000fddd0000fddd0000fddd0000fddd0000fddd0000000000000000000350050003000030000000000050050000500500
00d00f0000d00f0000d00f000d000f000d000f0000d000f00f0000f000d00f0000d00f0000000000000000000300030000000000000000000030030000800800
00d00d0000d00f1001f00d000f000d000f100d0000d001f00d001fd000d00d0000d00d0000000000000000000300033000000000000000000030050000800500
00f00f0000f0001001000f0000100f0000100f1001f001000ff1100000f00f1001f00f0000000000000000000000000000000000000000000030050000800500
01100110011000000000011000001000000000100100000000010000011000100100011000000000000000000000000000000000000000000030030000800800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000007777777777770000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000800000000000000ee0007000000000000007000000000000000000000000000000000000000000000000000000000000000000000000aa0000aa00000000
000800000000000000e88e007000000000000007000000000000000000000000000000000000000000000000000000000000000000000000a000000a0aa00aa0
00898000000000000e8888e07000000000000007000000000000000000000004000000000000000000000000000000000000000000000000000000000a0000a0
808a980800000000e888888e07000000000000700077770000777777007777770000000000000000000000000000000000000000000000000000000000000000
089aa98000009000e888888e00777777777777000040000004404000044000400000000000000000000000000000000000000000000000000000000000000000
00898000000000000e8888e00000000000000000004000000400400004000040000000000000000000000000000000000000000000000000000000000a0000a0
000808000000000000e88e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000a0aa00aa0
0000000000000000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0000aa00000000
__map__
0000000030303030000000000000000000000030303000000000000000000000000030303030300000000000000000000000000000000000000000000000000000000030303030300000000000000000000000000000000000000000000000000000000000000030303030303000000000000000000000000000000000000000
0000000030202030000000000000000000003020242030000000000000000000000030203020300000000000000000000000000000000000000000000000000000003030300430303000000000000000000000000000000000000000000000000000000000003030040404043030000000000000000000000000000000000000
0000000030303030000000000000000000003020242030000000000000000505000030303030300000000000000000000000000000000000000000000000000000003030040404303000000000000000000000000000000000000000000000000000000000003004040404040430000000000000000000303030300000000000
0000000030202030000000000000000000003020242030000000000000000505000030203020300000000000000000000000000000000000000000000000000000003030040404303000303030303000003030303030303030303030000000000000000000003030300404303030000000303030303030300404303030303030
0010111230303030131414153030303000003030303030000030303030300505000030303030300000000000000000000000001310111111121414150000000000003030040404303030141414141430003010111112301111111230303030303000001011123013141513141530000000300310120330303030303030303030
0030213030222230232422253030303000003013211530000030042203300505000030302130300000001617180505050000002324242424242421250707080000003030232125303023032203220325003024212124302421212430300422043000003021303023242222242530000000303022223030202204043030303030
0030313030323230333432353030303000003023312530000030303230300505000607070707070806072627280708050000002324242424242431250707080000003030233125303023243224322425003024313124302431312430303032303000003031303023243232242530000000303032323030060707083030303030
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202023030303030303030300202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
