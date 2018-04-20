pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- size of the screen in pixels
screen_x = 128
screen_y = 128

-- 0 = menu
-- 1 = game
-- 2 = game over
game_state = 0

-- in game variables
max_y = 112
x = 10  y = 112
gravity = 0.9

animation_speed = 3
shooting_speed = 7

actor = {}
zombie = {}
obstacle = {}
interaction = {}
bullet = {}

jump = false
bullet_shoot = false

function make_actor(x, y)
 a={}
 a.x = x
 a.y = y
 a.h = 8
 a.w = 8
 a.spr = 3
 a.frame = 0
 a.noise = 0
 a.hp = 5
 a.weapon = 1
 a.d_left = false
 a.d_right = false
 a.attacking_right = false
 a.attacking_left = false
 a.moving = false
 a.hurt = false
 
 add(actor,a)
 
return a
end

function make_zombie(x,y)
	local z={}
	z.x = x
	z.y = y
	z.h = 8
	z.w = 8
	z.spr = 33
	z.accel = 0
	z.hp = 10
	z.hurt = false
	
	add(zombie,z)
	
	return z
end

function make_obstacle(x,y)
 o={}
	o.x = x
	o.y = y
	o.w = 10
	o.h = 10
	o.spr = 64
	
	add(obstacle,o)
	
	return o
end

function make_interaction(x,y,w,h)
	local i={}
	i.x = x
	i.y = y
	i.w = w
	i.h = h
	
	add(interaction,i)
	
	return i
end

function make_bullet(x,y,dir)
	local b={}
	b.x = x
	b.y = y
	b.w = 5
	b.h = 2
	b.spr = 159
	b.speed = 4
	b.dir = dir

	add(bullet,b)
	
	return b
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

function move_zombie()
	if(a.x<z.x) then
	--if the player is to
 --the right of the zombie
		z.x += z.accel
	elseif a.x>z.x then
	--if to the left
	 z.x -= z.accel
	else
		--dead ?
	end
end

function control_player()
a.d_left = false
a.d_right = false

if (a.y>=max_y) then jump=false end
  if (a.y<=max_y) then 
  	if not player_obstacle_collision(0,1) then
  	a.y=a.y+gravity
  	else
  	jump = false 
  	end
  end
	 if (btn(0)) then
   if not player_obstacle_collision(-2.5,0) then
	  	a.x=a.x-2.5
	  	a.d_left = true
	  	a.noise+=5 
	  end
	 end
	 if (btn(1)) then 
	  if not player_obstacle_collision(2.5,0) then
	   a.x=a.x+2.5
	   a.d_right = true
	   a.noise+=5 
	  end
	 end
	 if (btn(2)) then 
	 	if (jump==false) then
	 			--stop jumping when ecounter an obstacle
	 	 	for i=1,15 do
	 	 	 if(not player_obstacle_collision(0,-1)) then
	 	 	 	a.y=a.y-1
	 	 	 end
	 	 	end
	 	  jump=true
	 	  a.noise+=15
	 	end
	 end
	 
	 --shoot
	 if (btn(4)) then
		if(a.frame%shooting_speed==0) then
	 	shoot_left()
		end
	 end
	 if(btn(5)) then
		if(a.frame%shooting_speed==0) then
	 	shoot_right()
		end
	 end
	 
	 --interact
	 if btn(4) then
	 	-- to do
	 end
end

function shoot_left()
 a.attacking_left = true
 a.attacking_right = false
 
 --weapon 1 = pistol
	if(a.weapon==1) then
		make_bullet(a.x-6,a.y-3,-1)
	end
end

function shoot_right()
 a.attacking_right = true
 a.attacking_left = false
 
 --weapon 1 = pistol
	if(a.weapon==1) then
		make_bullet(a.x+6,a.y-3,1)
	end
end

function bullet_moving()
	for b in all(bullet) do
	--if going right 
		if b.dir==1 then
			if b.x < screen_x and not bullet_zombie_collision(0,0) and not bullet_obstacle_collision(0,0) then
				b.x+=b.speed
			else
				del(bullet,b)
			end
		end
		--if going left
		if b.dir==-1 then
			if b.x > 0 and not bullet_zombie_collision(0,0) and not bullet_obstacle_collision(0,0) then
				b.x-=b.speed
			else
				del(bullet,b)
			end
		end
	end
end

function zombie_moving()
	a.hurt = false
	accel_zombie()
	for z in all(zombie) do
		z.hurt = bullet_zombie_collision(0,0)
		if z.hurt then
			z.hp-=1
		end 
		
		if z.hp == 0 then
			del(zombie,z)
		end
				
		if not zombie_obstacle_collision() then
			if z.x < a.x then
				z.x+=z.accel
			elseif z.x > a.x then
				z.x-=z.accel
			elseif player_zombie_collision() then
				a.hurt = true
				a.hp-=1
			end		
		end
	end
end

-- test if a point is solid
function solid (x,y,w,h,x_cible,y_cible,w_cible,h_cible)

	if (x >= x_cible and x <= x_cible+w_cible and y >= y_cible and y <= y_cible+h_cible) then
		return true
	end 
	
	-- revoir les flags
	-- val = mget(flr(x/8),flr(y/8))
	-- return fget(val, 3)
	return false
end

function player_obstacle_collision(dist_x,dist_y)
	for a_x=a.x,a.x+a.w do
		for a_y=a.y-a.h,a.y+a.h do
			if solid(a_x+dist_x,a_y+dist_y,a.w,a.h,o.x,o.y,o.w,o.h) then
				return true
			end
		end
	end
	return false
end

function player_zombie_collision()
	for z in all(zombie) do
		for a_x=a.x,a.x+a.w do
			for a_y=a.y-a.h,a.y+a.h do
				if solid(a_x,a_y,a.w,a.h,z.x,z.y,z.w-z.h,2*z.h) then
					return true
				end
			end
		end
	end
	return false
end

function zombie_obstacle_collision(dist_x,dist_y)
	for z in all(zombie) do
		for o in all(obstacle) do
			for z_x=z.x,z.x+z.w do
				for z_y=z.y-z.h,z.y+z.h do
					if solid(z_x+dist_x,z_y+dist_y,z.w,z.h,o.x,o.y,o.w,o.h) then
						return true
					end
				end
			end
		end
	end
	
	return false
end

function bullet_obstacle_collision(dist_x,dist_y)
	for b in all(bullet) do
		for o in all(obstacle) do
			for b_x=b.x,b.x+b.w do
				for b_y=b.y,b.y+b.h do
					if solid(b_x+dist_x,b_y+dist_y,b.w,b.h,o.x,o.y,o.w,o.h) then
						return true
					end
				end
			end
		end
	end
	return false
end

function bullet_zombie_collision()
	for b in all(bullet) do
		for z in all(zombie) do
			for b_x=b.x,b.x+b.w do
				for b_y=b.y,b.y+b.h do
					if solid(b_x,b_y,b.w,b.h,z.x,z.y-z.h,z.w,2*z.h) then
						return true
					end
				end
			end
		end
	end
	
	return false
end

function check_moving(moving)
	if(btn(0) or btn(1)) then
		moving = true
	else
	 moving = false
	end
	return moving
end

function animation_moving()
	if(a.spr == 7) then
		a.spr = 3			 	
	else
		a.spr += 2
	end
end

function draw_player() 
  --and not jumping
  if(jump==false) then
			 if not a.moving and not (a.attacking_right or a.attacking_left) then
			  spr(1,a.x,a.y) 
			  spr(2,a.x,a.y-6) 
			 end
			 
			 if mov and not (a.attacking_left or a.attacking_right) then
			  if(a.frame%animation_speed==0) then
			 	 animation_moving()
			 	end
			 	spr(a.spr,a.x,a.y)
			 	spr(a.spr+1,a.x,a.y-6)
			 end
			
		--if jumping
	 else
	 
	  --to the right
	  if((a.d_right and a.d_left) or (not a.d_right and not a.d_left) and not a.attacking_left and not a.attacking_right) then 
	   spr(17,a.x,a.y) 
	   spr(18,a.x,a.y-6)
	  end
	  --to the left
	 	if(a.d_right and not a.d_left and not a.attacking_left and not a.attacking_right) then
	 	 spr(19,a.x,a.y)
	 	 spr(20,a.x,a.y-6)
	 	end
	 	if(a.d_left and not a.d_right and not a.attacking_left and not a.attacking_right) then
	 	 spr(21,a.x,a.y)
	 	 spr(22,a.x,a.y-6)
	 	end
	 end
	 
	 	 --if attacking
  if(a.attacking_right) then
 	 spr(10,a.x,a.y)
 	 spr(11,a.x,a.y-6)
 	 spr(12,a.x+6,a.y-6)
 	 a.attacking_right = false
	 end
	 if(a.attacking_left) then
	  	spr(13,a.x,a.y)
	  	spr(14,a.x,a.y-6)
	  	spr(15,a.x-6,a.y-6)
    a.attacking_left = false
	 end
	
		if(a.hurt) then
			spr(23,a.x,a.y)
			spr(24,a.x,a.y-6)	
		end
		
	 a.frame+=1
end

function draw_bullet()
	for b in all(bullet) do
		spr(b.spr,b.x,b.y)
	end
end

function draw_zombies()
 for z in all(zombie) do
		if z.hurt then
			spr(35,z.x,z.y)
			spr(36,z.x,z.y-6)
		else
			spr(33,z.x,z.y)
			spr(34,z.x,z.y-6)
		end
	end
end

function draw_obstacles()
	spr(64,o.x,o.y)
end

function draw_game()
	cls()
	if game_map == 1 then
	 map(0,0,0,64,16,8)
		-- sky so always the same except
		-- if we want to draw over 64px
	 map(17,0,0,0,16,8)
	elseif game_map == 2 then
		map(34,0,0,64,16,8)
 	map(17,0,0,0,16,8)
	elseif game_map == 3 then
	elseif game_map == 4 then
	elseif game_map == 5 then
	elseif game_map == 6 then
end
		
		draw_player()
		draw_zombies()
		draw_obstacles()
		draw_bullet()
end

function draw_menu()
	cls(col2)
 draw_options()
 if (octopus==true) then
 	draw_octopus()
 end
end

function draw_gameover()

end

function _draw()
	cls()
	if game_state == 0 then
		draw_menu()
	elseif game_state == 1 then
		draw_game()
	elseif game_state == 2 then
		draw_gameover()
	end
	
		-- hitboxes

		-- player
  -- rectfill(a.x,a.y-a.h,a.x+a.w,a.y+a.h,14)
 	
 	-- interactions items
 	-- for i in all(interaction) do
 	--	rectfill(i.x,i.y,i.x+i.w,i.y+i.h,14)
		-- end
		
		-- obstacles
		-- for o in all(obstacle) do
		-- rectfill(o.x,o.y,o.x+o.w,o.y+o.h,14)
		-- end
end

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
 if (btnp(2)) m.sel-=1 cx=m.x sfx(0)
 if (btnp(3)) m.sel+=1 cx=m.x sfx(0)
 if (btnp(4)) cx=m.x sfx(1)
 if (btnp(5)) sfx(2)
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
 spr(1,ox,oy) spr(2,ox+8,oy)
 spr(17,ox,oy+8) spr(18,ox+8,oy+8)
 pal()
end

function init_settings()
 m.sel=1
 m.options={"palette","controls","octopus","exit"}
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
  elseif m.options[m.sel]=="octopus" then
   octopus=not octopus
   ox=rnd(112)+8
   oy=rnd(112)+8
  elseif m.options[m.sel]=="exit" then
  	cls()
  	init_menu()
  end
 end
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

function menuinit()
	octopus=false
 pals={{7,0},{15,1},{6,5},
			   {10,8},{7,3},{7,2}}
 palnum=5
 init_menu()
end

function gameinit()
	map()
	player = make_actor(x,y)
	make_zombie(x,y)
	obstacle = make_obstacle(70,112)
	interaction = make_interaction(89,105,6,14)
	game_state = 1
end

function gameoverinit()
	game_state = 2
end

function _init()
	menuinit()
	game_state=0
	game_map=1
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

function update_game()
	control_player()
	bullet_moving()
	zombie_moving()
end

function update_gameover()

end

function _update()
	if game_state == 0 then
		update_menu()
	elseif game_state == 1 then
		update_game()
	elseif game_state == 2 then
		update_gameover()
	end
end

__gfx__
00000000005575000004400000557500000440000055750000044000005575000004400000000000005575000004400000000000005575000004400000000000
0000000000557500004ff40000557500004ff40000557500004ff40000557500004ff4000000000000557500004ff4000000000000557500004ff40000000000
0070070000444400004ff40000444400004ff40000444400004ff40000444400004ff4000000000000444400004ff4000000000000444400004ff40000000000
0007700000dddd00000ff00000dddd00000ff00000dddd00000ff00000dddd00000ff0000000000000dddd00000ff0000777700000dddd00000ff00000077770
0007700000d00d000f5575f000d00d000f5575f000d00d000f5575f000d00d000f5575f00000000000d00d000f5575fff500000000d00d00ff5575f00000005f
0070070000d00d000f5575f000d00d00f05575f000d00d000f5575f001d00d000f5575000000000000d00d000fff75000500000000d00d000055fff000000050
0000000000f00f000f5575f001f00f00f05575ff00f00f000f5575f001000f000ff575f00000000001f00f00005575000000000000f00f100055750000000000
00000000011001100f5575f001000110f05575000010100000f5750f000001100055750000000000010001100055750000000000011000100055750000000000
00000000005575000004400000557500000440000057550000044000005575008004400800000000000000000000000000000000000000000000000000000000
0000000000557500f04ff40f00557500004ff40000575500004ff400005575008048840800000000000000000000000000000000000000000000000000000000
0000000000444400f04ff40f00444400004ff40000444400004ff400004444008048840800000000000000000000000000000000000000000000000000000000
0000000000dddd00f00ff00f00dddd00000ff00000dddd00000ff00000dddd008008800800000000000000000000000000000000000000000000000000000000
000000000d000d000f5575f000d000d00f5575f00d000d000f5755f000d00d000855758000000000000000000000000000000000000000000000000000000000
000000000f000d000055750000d001f0f05575f00f100d000f57550f00d00d000055750000000000000000000000000000000000000000000000000000000000
0000000000100f000055750001f00100f05575ff00100f10ff57550f008008000055750000000000000000000000000000000000000000000000000000000000
00000000000010000055750001000000f0557500000000100057550f011001100055750000000000000000000000000000000000000000000000000000000000
00000000003363000003300000886800000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006633000003300000668800000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003666000036630000866600008668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006666000333363000666600088886800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006006000363663000600600086866800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006003003366363000600800886688800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003003003063363000800800806868000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003003000036663000800800008666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444440999999998888888800000000434b444b5555555555555555004444444444444444444400000000000000000000000000000000000000000000000000
400440049555aaa98222222800030300444434445ffffff55ffffff5046666666655555555555540000000000000000000000000000000000000000000000000
44444444955555a982000028000b0b30434444345ffffff55ffffff5444444444444444444444444000000000000000000000000000000000000000000000000
4004400495555559800dd008300333b0344b43445ffffff55ffffff5466666666555555555555554000000000000000000000000000000000000000000000000
4444444495555559800dd008b30bbb30444444445ffffff55ffffff5444444444444444444444444000000000000000000000000000000000000000000000000
400440049a555559820000283b333bb3444444445ffffff55ffffff5466666665555555555555554000000000000000000000000000000000000000000000000
444444449aaa555982222228b3bbb3bb444444445ffffdf55fdffff5444444444444444444444444000000000000000000000000000000000000000000000000
400440049999999988888888bb333b33444444445ffffdf55fdffff5466666655555555555555554000000000000000000000000000000000000000000000000
000000000000000000000000030000004b4344435ffffdf55fdffff5444444445555555544444444000000000000000000000000000000000000000000000000
0000000000000000000000000b0303004444b4445ffffff55ffffff5466666555ffffff555555554000000000000000000000000000000000000000000000000
000000000000000000000000033b0330434444345ffffff55ffffff5444444445ffffff544444444000000000000000000000000000000000000000000000000
00000000000000000000000033b303b0b4434b445ffffff55ffffff5466665555ffffff555555554000000000000000000000000000000000000000000000000
000000000000000000000000b3bb3b30444444445ffffff55ffffff5444444445ffffff544444444000000000000000000000000000000000000000000000000
0000000000000000000000003b33bbb0444444445ffffff55ffffff5466655555ffffff555555554000000000000000000000000000000000000000000000000
000000000000000000000000b3bbb3b3444444445ffffff55ffffff5444444445ffffdf544444444000000000000000000000000000000000000000000000000
000000000000000000000000bb333b33444444445555555555555555466555555ffffdf555555554000000000000000000000000000000000000000000000000
000000000000000000000000000000004be34e430000000000000000444444445ffffdf544444444000000000000000000000000000000000000000000000000
000000000000000000000000000000004444b4440000000000000000465555555ffffff555555554000000000000000000000000000000000000000000000000
00000000000000000000000000000000e3e4e4340000000000000000444444445ffffff544444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000b4434b4e0000000000000000455555555ffffff555555554000000000000000000000000000000000000000000000000
00000000000000000000000000000000444444440000000000000000444444445ffffff544444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000444444440000000000000000455555555ffffff555555554000000000000000000000000000000000000000000000000
00000000000000000000000000000000444444440000000000000000444444445ffffff544444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000444444440000000000000000455555555555555555555554000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000666600000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000667777550000000000000a0000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000067777755550000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000067777755555500000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006777755555550000a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000677777555555550000a0000000000a00000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000067777555555555000000000000000000a000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000006777755555555500000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000067777755555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006777755555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006777775555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000006777775555000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee00000000000
000000000000667777550000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee00000000000
000000000000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000ee00000000000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee00000000000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee00000000000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee00000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee00000000000
__gff__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000090909090909090909000000ed00c400c5c60000000000000000c60000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a6600000000660000000009edc400c500c300c6c6c600c5c4c5000000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76007879000000000000767700000009ed78c1c20000c7c7c4c7c6c6c30000c7c6ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090000005a000000005a000000000000edc6d1d2c4c4c7c7c7c3c700c400c60000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
660000006a660000006a474849000000ed00006ac5c7c7c7c5c7c4c400c500c300ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000078797a760000797a575859000000edc500c400c3c5c4c7c6c400c300000000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000437e00004353676869004300edc5c6000000c700c3c5c70000c6000000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44546454446444644464446464445454ed00000000000000000000000000000000ed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddddddddddddddddddfdddddddddddddddddddddddddddddddddfd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000007b7c7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007900000000000000777879004a4b4c4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6600000000000000006a000000006a000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
760000797a0000000000000000797a760000007a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005a0000000000000000005a000000005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000660000006a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
767700790000000000000000000000760000007a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004d4e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005a005c5d5e000000000000000000000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004d00000079000000007900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000005d5e000000494a4b4c4d4e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006600000000666768006a6b00000067006900006c6d00000000595a5b5c5d5e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000750077780075767778797a000075767700007a0000007e006768696a6b6c6d6e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000575859005b5c5d5e00757576000000007b007d7e7c7d7e75767778797a7b7c7d7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000067686900006c6d6e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0075007778797a7b7c7d7e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000