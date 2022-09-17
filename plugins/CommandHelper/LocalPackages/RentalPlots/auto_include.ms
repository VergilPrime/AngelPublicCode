proc _remove_shopsign(@world,@region){
	@signlist = import('AR.AngelSpawnShops.SignList');
	@rentallist = import('AR.AngelSpawnShops.RentalList');
	
	array_remove(@signlist[@world],@region);
	array_remove(@rentallist[@world],@region);
	
	_save('AR.AngelSpawnShops.SignList');
	_save('AR.AngelSpawnShops.RentalList');
}

proc _spawnshop_signs_update(){
	@signlist = import('AR.AngelSpawnShops.SignList');
	foreach(@world:@regions in @signlist){
		foreach(@region:@location in @regions){
			if(reg_count('SIGN',get_block(@location)) === 0){
				_remove_shopsign(@world,@region);
				continue();
				
			}else{
			
				@rentallist = import('AR.AngelSpawnShops.RentalList');
				if(array_index_exists(@rentallist,@world)){
					if(array_index_exists(@rentallist[@world],@region)){
						@expirationdate = @rentallist[@world][@region]['expirationdate'];
						if(@expirationdate < time()){
							@simple_date = color(4).'[EXPIRED]';
						}else if(@expirationdate < time() + (1000 * 60 * 60 * 24)){
							@simple_date = simple_date('hh:mm aa',@expirationdate);
							# set_timeout(@expirationdate + 1000 - time(), closure(
								# _spawnshop_signs_update();
							# ));
						}else{
							@simple_date = simple_date('MM/dd/yyyy',@expirationdate);
						}
						
						@renter = _uuidreg_get_name(@rentallist[@world][@region]['renter']);
						set_sign_text(@location,array(
							@renter,
							'Leased Until:',
							@simple_date,
							@region
						))
						
					}else{
						
						@flags = sk_region_info(@region,@world,3);
						@price = 2000;
						foreach(@flag in @flags){
							if(@flag[0] === 'price'){
								@price = @flag[1];
							}
						}
						
						set_sign_text(@location,array(
							'For Rent',
							@price.' Silver',
							'30 Days',
							@region
						));
							
					}
				}else{
					@flags = sk_region_info(@region,@world,3);
					@price = 2000;
					
					foreach(@flag in @flags){
						if(@flag[0] === 'price'){
							@price = @flag[1];
						}
					}
					
					set_sign_text(@location,array(
						'For Rent',
						@price.' Silver',
						'30 Days',
						@region
					));
				}
			}
		}
	}
}