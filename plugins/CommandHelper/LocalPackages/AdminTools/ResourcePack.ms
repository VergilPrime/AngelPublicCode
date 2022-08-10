// Procedure to recursively fix stupid faces in a directory.
// Stupid faces are ones with "0,0,0,0" as UV coordinates, in other words nothing.
// Since BlockBench exports these into it's bbmodel files and ModelEngine reads them
// and replaces the null texture with something else, this creates stretched 0 pixels
// that resemble z-fighting.
proc _fix_stupid_faces(@path){
    // msg("Fixing stupid faces in path : ".color("a").@path);
    // Get all faces in @path
    @filenames = list_files(@path);
    
    // Keep track of the amount of faces we're fixing for cheekyness.
    @count = 0;
    
    // For every file in @path
    foreach(@filename in @filenames){
        // Split the file into an array at ever instance of "."
        @array = split('.',@filename);
        
        // Find the last index in the array. This should point to the file extension.
        @last = @array[array_size(@array) - 1];
        
        // If the file extension is json
        if(@last === "json"){
            // msg("  File: ".color("6").@filename);
            
            // Track if the data is changed or not so we know whether or not to save later.
            @changed = false;
            
            // Decode the file into data we can easily check and manipulate.
            @contents = json_decode(read(@path.@filename));
            // msg("    Has ".array_size(@contents["elements"])." elements.");
            
            // For every element in the file
            foreach(@eindex:@element in @contents["elements"]){
                // For every face in the eleement's "faces" map
                foreach(@facename:@face in @element["faces"]){
                    // If the UV is 0,0,0,0 (this is what happens when you click "Remove Face" in BlockBench, which is dumb but whatever.)
                    if(@face["uv"] === array(0,0,0,0)){
                        // Remove that face from the faces on the element
                        array_remove(@contents["elements"][@eindex]["faces"],@facename);
                        
                        // So we know we need to overwrite the file
                        @changed = true;
                        
                        // For cheekyness
                        @count++;
                    }
                }
            }
            // If there are any changes
            if(@changed){
                // Write out the file.
                write_file(@path.@filename,json_encode(@contents),"OVERWRITE");
            }
        }else{
            // If the "file" is a directory
            if(is_dir(@path.@filename)){
                // Recursively call this procedure!
                @count += _fix_stupid_faces(@path.@filename.'/');
            }
        }
    }
    return(@count);
}

// Register a command to generate new pack using ModelEngine, copy that pack to 
// Oraxen's pack directory, fix stupid faces in each of those json files, then
// reload Oraxen's pack.
register_command("resourcepack",associative_array(
    "description":"Combine ModelEngine and Oraxen resource packs.",
    "usage":"/falseblock <create|delete> blocktype",
    // Give your staff this permission to let them update the pack using this command.
    "permission":"admintools.resourcepack",
    "executor":closure(@alias,@sender,@args){
        
        @plugins = "Your_Server_Directory/plugins";
        
        // ModelEngine reload command, generates fresh pack assets.
        run("/meg reload");
        
        // We wait a second before we do anything else since CommandHelper doesn't know when ModelEngine is finished.
        set_timeout(1000,closure(){
            // I used a shell command (Linux) to copy the directory but in hindsight I should probably use copy_file()
            shell_adv("cp -R \"@{plugins}/ModelEngine_Beta/resource pack/assets\" \"@{plugins}/Oraxen/pack/\"",associative_array(
                "subshell":true,
                "workingDir":"@{plugins}/ModelEngine_Beta/",
                "stdout":closure(@output){
                    msg(@sender,@output)
                },
                "stderr":closure(@output){
                    msg(@sender,@output)
                },
                "exit":closure(@exitcode){
                    if(!@exitcode){
                        msg("Copied files into Oraxen pack.");
                        msg("Correcting stupid faces.");

                        @path = "../../../Oraxen/pack/assets/modelengine/models/";
                        @count = _fix_stupid_faces(@path);
                        msg("Fixed @count stupid faces.");
                        msg("Reloading Oraxen pack.");
                        run("/o reload pack");
                    }else{
                        _are("Copying ModelEngine pack to Oraxen failed with error code @exitcode.")
                    }
                }
            ));
        })
    }
))
