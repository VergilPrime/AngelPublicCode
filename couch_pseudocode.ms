proc _connect_couch(@entity,@recursions){
    // Default to 1 recursion if it's not specified.
    if(@recursions === ""){@recursions = 1}

    // Gets an array of cardinal directions starting with "forwards" and progressing clockwise ending with "left".
    // We're making an assumption that with floor item frames, north is "NONE" rotation, but this might need to be adjusted later.
    // array("NORTH","EAST","SOUTH","WEST");
    @facing = _get_facing_array(@entity);

    if(is_null(@facing)){
        // Frame was probably not at a 90 degree angle, we can't connect this.
        die();
    }

    // Get all entities within 1 block of the one we're handling.
    @nearby = entities_in_radius(entity_loc(@entity),1);

    // filter out anything that isn't a frame.
    @frames = array_filter(@nearby,closure(@index,@n_entity){
        //TODO: Add check if item in frame matches the item in @entity.
        // If the return here is true, the item is kept in the resulting array.
        return(entity_type(@n_entity) === "ITEM_FRAME" || entity_type(@n_entity) === "GLOW_ITEM_FRAME");
    })

    // These will be replaced with entity uuids of the surrounding frames.
    @front_frame = null;
    @right_frame = null;
    @back_frame = null;
    @left_frame = null;

    // For every frame in the array
    foreach(@index:@n_frame in @frames){
                // If the new frame's location is exactly 1 block to the front of the current frame's location
                if(entity_loc(@n_frame) === location_shift(entity_loc(@entity),@rotation[0])){
                    // Front frame is this frame.
                    @front_frame = @n_frame;
                // Same but looking to the right.
        }else   if(entity_loc(@n_frame) === location_shift(entity_loc(@entity),@rotation[1])){
                    @right_frame = @n_frame;
        }else   if(entity_loc(@n_frame) === location_shift(entity_loc(@entity),@rotation[2])){
                    @back_frame = @n_frame;
        }else   if(entity_loc(@n_frame) === location_shift(entity_loc(@entity),@rotation[3])){
                    @left_frame = @n_frame;
    }

    @can_connect_left = false;
    @can_connect_right = false;
    @can_connect_front = false;
    @can_connect_back = false;

    // If left frame was found and set in the previous foreach loop
    if(!is_null(@left_frame)){
        // Get the facing array for the left frame
        @left_facing = _get_facing_array(@left_frame);
        // If the left frame is facing a cardinal direction
        if(!is_null(@left_facing)){
            // If the left frame is facing the same direction as this frame, or left or right
            if(
                @left_facing[0] === @facing[0] ||
                @left_facing[1] === @facing[0] ||
                @left_facing[3] === @facing[0]
            ){
                // These two frames can connect!
                @can_connect_left = true;
            }
        }
    }

    // Same story but on the right.
    if(!is_null(@right_frame)){
        @right_facing = _get_facing_array(@right_frame);
        if(!is_null(@right_facing)){
            if(
                @right_facing[0] === @facing[0] ||
                @right_facing[1] === @facing[0] ||
                @right_facing[3] === @facing[0]
            ){
                @can_connect_right = true;
            }
        }
    }

    if(!is_null(@back_frame)){
        @back_facing = _get_facing_array(@back_frame);
        if(!is_null(@back_facing)){
            if(
                //Forward and back couches can only connect at a 90 degree angle, so we're only concerned with left and right facing couches.
                @back_facing[1] === @facing[0] ||
                @back_facing[3] === @facing[0]
            ){
                @can_connect_back = true;
            }
        }
    }    

    if(!is_null(@front_frame)){
        @front_facing = _get_facing_array(@front_frame);
        if(!is_null(@front_facing)){
            if(
                @front_facing[1] === @facing[0] ||
                @front_facing[3] === @facing[0]
            ){
                @can_connect_front = true;
            }
        }
    }

    @type = null
    @newfacing = null;


            if(@can_connect_left && @can_connect_right){
        @type = "middle";
        // If recursion hasn't hit 0 yet, we can run this code on the couches nearby to update their angle.
        if(@recursions){
            _connect_couch(@left_frame,@recursions - 1);
            _connect_couch(@right_frame,@recursions - 1);
        }
            // This only works if back couch is facing the opposite direction of side couch, in this case right
    }else   if(@can_connect_left && @can_connect_back && @back_facing[0] === @facing[1]){
        @type = "corner_facing_out";
        @newfacing = @facing[1];
        if(@recursions){
            _connect_couch(@left_frame,@recursions - 1);
            _connect_couch(@back_frame,@recursions - 1);
        }
            // Same as before but inner corner has to face the same direction as side couch.
    }else   if(@can_connect_left && @can_connect_front && @back_facing[0] === @facing[3]){
        @type = "corner_facing_in";
        if(@recursions){
            _connect_couch(@left_frame,@recursions - 1);
            _connect_couch(@front_frame,@recursions - 1);
        }
    }else   if(@can_connect_right && @can_connect_back && @back_facing[0] === @facing[3]){
        @type = "corner_facing_out";
        if(@recursions){
            _connect_couch(@back_frame,@recursions - 1);
            _connect_couch(@right_frame,@recursions - 1);
        }
    }else   if(@can_connect_right && @can_connect_front && @back_facing[0] === @facing[1]){
        @type = "corner_facing_in";
        @newfacing = @facing[1];
        if(@recursions){
            _connect_couch(@front_frame,@recursions - 1);
            _connect_couch(@right_frame,@recursions - 1);
        }
    }else   if(@can_connect_left){
        @type = "right_end";
        if(@recursions){
            _connect_couch(@left_frame,@recursions - 1);
        }
    }else   if(@can_connect_right){
        @type = "left_end";
        if(@recursions){
            _connect_couch(@right_frame,@recursions - 1);
        }
    }else{
        die();
    }

    if(!is_null(@newfacing)){
        switch(@facing[0]){
            case "NORTH":
                set_entity_spec(@entity,associative_array(
                    "rotation":"CLOCKWISE"
                ));
            case "EAST":
                set_entity_spec(@entity,associative_array(
                    "rotation":"FLIPPED"
                ));
            case "SOUTH":
                set_entity_spec(@entity,associative_array(
                    "rotation":"COUNTER_CLOCKWISE"
                ));
            case "WEST":
                set_entity_spec(@entity,associative_array(
                    "rotation":"NONE"
                ));
        }
    }

    @item = get_entity_spec(@entity)["item"];
    //TODO: Replace "single" type with @type. Probably replaces the entire item.
    set_entity_spec(@entity,associative_array("item":@item));

}

proc _get_facing_array(@entity){

    // Rotation can be one of the following as well as values for subcardinal directions, or 45/135 degree rotations. 
    @rotation = get_entity_spec(@entity)["rotation"];

    switch(@rotation){
        
        // We're making an assumption that with floor item frames, north is "NONE" rotation, but this might need to be adjusted later.
        case "NONE":
            return(array("NORTH","EAST","SOUTH","WEST"));
        case "CLOCKWISE":
            return(array("EAST","SOUTH","WEST","NORTH"));
        case "FLIPPED":
            return(array("SOUTH","WEST","NORTH","EAST"));
        case "COUNTER_CLOCKWISE":
            return(array("WEST","NORTH","EAST","SOUTH"));
        default:
            // If the rotation is not at a 90 degree angle, connection isn't supported so we return null.
            return(null);
    }
}