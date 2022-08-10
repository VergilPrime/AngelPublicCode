proc _fix_stupid_faces(@path){
    msg("Fixing stupid faces in path : ".color("a").@path);
    @filenames = list_files(@path);
    @count = 0;
    foreach(@filename in @filenames){
        @array = split('.',@filename);
        @last = @array[array_size(@array) - 1];
        if(@last === "json"){
            msg("  File: ".color("6").@filename);
            @changed = false;
            @contents = json_decode(read(@path.@filename));
            msg("    Has ".array_size(@contents["elements"])." elements.");
            foreach(@eindex:@element in @contents["elements"]){
                foreach(@facename:@face in @element["faces"]){
                    if(@face["uv"] === array(0,0,0,0)){
                        array_remove(@contents["elements"][@eindex]["faces"],@facename);
                        @changed = true;
                        @count++;
                        continue();
                    }
                }
            }
            if(@changed){
                write_file(@path.@filename,json_encode(@contents),"OVERWRITE");
            }
        }else{
            if(is_dir(@path.@filename)){
                @count += _fix_stupid_faces(@path.@filename.'/');
            }
        }
    }
    return(@count);
}

register_command("resourcepack",associative_array(
    "description":"Combine ModelEngine and Oraxen resource packs.",
    "usage":"/falseblock <create|delete> blocktype",
    "permission":"admintools.resourcepack",
    "executor":closure(@alias,@sender,@args){
        @plugins = "/home/amp/.ampdata/instances/AngelsReach/Minecraft/plugins";
        
        run("/meg reload");
        set_timeout(1000,closure(){
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
