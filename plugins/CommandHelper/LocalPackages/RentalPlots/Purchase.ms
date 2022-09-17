_load('AR.AngelSpawnShops.RentalList')
_load('AR.AngelSpawnShops.SignList')

@rentallist = import('AR.AngelSpawnShops.RentalList')

bind('player_interact',null,null,@e){
	
	if(@e['action'] === 'right_click_block'){
		
		if(reg_count('SIGN',@e['block'])){
			
			@signlist = import('AR.AngelSpawnShops.SignList');
			
			@world = pworld(@e['player']);
			
			@location = array(integer(@e['location'][0]),integer(@e['location'][1]),integer(@e['location'][2]),@e['location'][3]);
			
			if(array_index_exists(@signlist,@world)){
				
				foreach(@region:@signloc in @signlist[@world]){
					
					if(@signloc === @location){
						
						run('/rent '.@region);
						die();
						
					}
					
				}
				
			}
			
		}
		
	}
					
}

register_command('SpawnShopSign',associative_array(
	'description':'Register a sign to a spawn shop.',
	'usage':'/SpawnShopSign <regionName>',
	'permission':'AngelSpawnShop.Admin',
	'tabcompleter':closure(@alias,@player,@args){
		
		if(array_size(@args) === 0){
			return(false);
		}
		
		@uuid = puuid(@player,true)
		
		@regions = array()
		
		@world = pworld(@player)
		
		foreach(@region in sk_all_regions(@world)){
			
			@buyable = false
			
			@flags = sk_region_info(@region,@world,3)
			
			foreach(@flag in @flags){
				
				if(@flag[0] === 'buyable'){
					
					if(@flag[1] === 'true'){
						
						@buyable = true
						
					}
					
				}
				
			}
			
			if(@buyable){
				
				array_push(@regions,@region)
				
			}
			
		}
		
		return(@regions)
		
	},
	'executor':closure(@alias,@player,@args){
		
		@world = pworld(@player)
		
		@regions = sk_all_regions(@world)
		
		@region = to_lower(@args[0])
		
		if(!array_contains(@regions,@region)){
			
			_are('That region does not exist in this world.')
			die()
			
		}
		
		@buyable = false
		
		@flags = sk_region_info(@region,@world,3)
		
		foreach(@flag in @flags){
			
			if(@flag[0] === 'buyable'){
				
				if(@flag[1] === 'true'){
					
					@buyable = true
					
				}
				
			}
			
		}
		
		if(!@buyable){
			
			_are('That region is not rentable.')
			die()
			
		}
		
		_arm('Right click a sign to link it to '.@region)
		
		bind('player_interact',array('priority': 'HIGH'),array('player':@player),@e,@region){
			
			if(@e['action'] === 'right_click_block'){
				
				if(reg_count('SIGN',@e['block'])){
					
					@world = pworld(@e['player'])
					
					@location = array(integer(@e['location'][0]),integer(@e['location'][1]),integer(@e['location'][2]),@e['location'][3])
					
					@signlist = import('AR.AngelSpawnShops.SignList')
					
					@signlist[@world][@region] = @location
					
					_save('AR.AngelSpawnShops.SignList')
					
					_spawnshop_signs_update()
					
					_arm('Sign Linked')
					
					consume()
					
					cancel()
				
					unbind()
					
				}
				
			}
			
		}
		
	}
))



register_command('Rent',associative_array(
	'description':'Rent any buyable plot.',
	'permission':'AngelSpawnShop.Rent',
	'tabcompleter':closure(@alias,@player,@args){
		
		@regions = array()
		
		@world = pworld(@player)
		
		foreach(@region in sk_all_regions(@world)){
			
			@buyable = false
			
			@flags = sk_region_info(@region,@world,3)
			
			foreach(@flag in @flags){
				
				if(@flag[0] === 'buyable'){
					
					if(@flag[1] === 'true'){
						
						@buyable = true
						
					}
					
				}
				
			}
			
			if(@buyable){
				
				array_push(@regions,@region)
				
			}
			
		}
		
		return(@regions)
		
	},
	
	'executor':closure(@alias,@player,@args){
		
		if(@args === array()){
			
			_are('You must specify a plot to buy.')
			die()
			
		}
		
		@uuid = puuid(@player,true)
		
		@world = pworld(@player)
		
		@regions = sk_all_regions(@world)
		
		@region = to_lower(@args[0])
		
		if(!array_contains(@regions,@region)){
			
			_are('That region does not exist in this world.')
			die()
			
		}
		
		@buyable = false
		
		@flags = sk_region_info(@region,@world,3)
		
		foreach(@flag in @flags){
			
			if(@flag[0] === 'buyable'){
				
				if(@flag[1] === 'true'){
					
					@buyable = true
					
				}
				
			}
			
		}
		
		if(!@buyable){
			
			_are('That region is not rentable.')
			die()
			
		}
		
		@rentallist = import('AR.AngelSpawnShops.RentalList')
		
		@playerbal = acc_balance(@player)
		
		@price = 2000
		
		foreach(@flag in @flags){
			
			if(@flag[0] === 'price'){
				
				@price = @flag[1]
				
			}
			
		}
		
		if(!array_index_exists(@rentallist,@world)){
			
			@rentallist[@world] = associative_array()
			
		}
		
		if(array_index_exists(@rentallist[@world],@region)){
			
			@renter = @rentallist[@world][@region]['renter']
				
			if(@renter === @uuid){
			
				if(@playerbal >= @price){
					
					try(
						
						acc_subtract(@player,@price)
					
					,
						
						sys_out(color(5).'ERROR '.@playerbal.' vs '.@price)
						_are(@player,'Something went horridly wrong. Tell Vergil.')
						die()
						
					)
					
					@oldexpirationdate = @rentallist[@world][@region]['expirationdate']
					
					@newexpirationdate = @oldexpirationdate + (1000 * 60 * 60 * 24 * 30)
					
					@rentallist[@world][@region]['expirationdate'] = @newexpirationdate
					@rentallist[@world][@region]['renter'] = @uuid
					
					_save('AR.AngelSpawnShops.RentalList')
					
					_spawnshop_signs_update()
					
					_arm('30 days added to rental.')
					die()
					
				}else{
					
					_arm('You can\'t afford to extend your lease.')
					die()
					
				}
			
			}else{
				if(time() > @rentallist[@world][@region]['expirationdate']){
					
					if(@playerbal >= @price){
						
						@newexpirationdate = time() + (1000 * 60 * 60 * 24 * 30)
						
						@rentallist[@world][@region]['expirationdate'] = @newexpirationdate
						@rentallist[@world][@region]['renter'] = @uuid
						
						try(
							
							acc_subtract(@player,@price)
						
						,
							
							sys_out(color(5).'ERROR '.@playerbal.' vs '.@price)
							_are(@player,'Something went horridly wrong. Tell Vergil.')
							die()
							
						)
						
						@command1 = string('/rg addowner -w '.@world @region @player)
						
						runas('~console',@command1)
						
						_save('AR.AngelSpawnShops.RentalList')
						
						_spawnshop_signs_update()
						
						_arm('Shop rented for 30 days.')
						
					}else{
						
						_are('You don\'t have the money to rent a shop.')
						
					}
					
				}else{
					
					_are('That plot is currently rented out to '._uuidreg_get_name(@renter).'.')
					die()
					
				}
				
			}
			
		}else{
			
			if(@playerbal >= @price){
				
				@newexpirationdate = time() + (1000 * 60 * 60 * 24 * 30)
				
				@rentallist[@world][@region]['expirationdate'] = @newexpirationdate
				@rentallist[@world][@region]['renter'] = @uuid
				
				try(
					
					acc_subtract(@player,@price)
				
				,
					
					sys_out(color(5).'ERROR '.@playerbal.' vs '.@price)
					_are(@player,'Something went horridly wrong. Tell Vergil.')
					die()
					
				)
				
				@command1 = string('/rg addowner -w '.@world @region @player)
				
				runas('~console',@command1)
				
				_save('AR.AngelSpawnShops.RentalList')
				
				_spawnshop_signs_update()
				
				_arm('Shop rented for five days.')
				
			}else{
				
				_are('You don\'t have the money to rent a shop.')
				
			}
			
		}
		
	}
	
))

set_cron('0 0 * * *',closure(

	_spawnshop_signs_update()
	
))