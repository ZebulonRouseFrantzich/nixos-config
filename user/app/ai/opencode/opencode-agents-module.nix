{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;
  agentsCfg = cfg.agentManagement;
  
  # Submodule for per-agent overrides
  agentOverrideModule = lib.types.submodule ({ name, ... }: {
    options = {
      model = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Override the model field in agent frontmatter";
        example = "anthropic/claude-sonnet-4-20250514";
      };
      
      temperature = lib.mkOption {
        type = lib.types.nullOr (lib.types.numbers.between 0.0 1.0);
        default = null;
        description = "Override temperature setting";
      };
      
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to include this agent in the output";
      };
    };
  });

in {
  options.programs.opencode.agentManagement = {
    source = lib.mkOption {
      type = lib.types.path;
      default = ./agents;
      description = "Path to directory containing agent .md files";
      example = lib.literalExpression "./agents";
    };
    
    overrides = lib.mkOption {
      type = lib.types.attrsOf agentOverrideModule;
      default = {};
      description = "Per-agent configuration overrides";
      example = lib.literalExpression ''
        {
          deep-plan = {
            model = "anthropic/claude-sonnet-4-20250514";
            temperature = 0.7;
          };
        }
      '';
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to include with opencode for agent functionality";
      example = lib.literalExpression "[ pkgs.yq-go ]";
    };

    installPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/opencode/agent";
      description = "Installation path for processed agent files";
      readOnly = true;
    };
  };
  
  config = let
    # Process a single agent file
    processAgentFile = agentName: relPath: overrideConfig:
      let
        sourcePath = "${agentsCfg.source}/${relPath}";
        hasOverrides = overrideConfig.model != null || overrideConfig.temperature != null;
      in
        if !overrideConfig.enabled then
          null
        else if !hasOverrides then
          sourcePath
        else
          pkgs.runCommand "agent-${agentName}.md" {
            buildInputs = [ pkgs.yq-go pkgs.coreutils ];
          } ''
            # Work with a temporary file instead of modifying $out directly
            cp ${sourcePath} working.md
            
            update_frontmatter() {
              local field=$1
              local value=$2
              
              if ${pkgs.yq-go}/bin/yq eval --front-matter=extract '.' working.md > /dev/null 2>&1; then
                ${pkgs.yq-go}/bin/yq eval --front-matter=process \
                  ".$field = $value" \
                  -i working.md
              else
                {
                  echo '---'
                  echo "$field: $value"
                  echo '---'
                  echo
                  cat working.md
                } > temp.md
                mv temp.md working.md
              fi
            }
            
            ${lib.optionalString (overrideConfig.model != null) ''
              update_frontmatter "model" '"${overrideConfig.model}"'
            ''}
            
            ${lib.optionalString (overrideConfig.temperature != null) ''
              update_frontmatter "temperature" '${toString overrideConfig.temperature}'
            ''}
            
            # Copy the final result to $out
            cp working.md $out
          '';
    
    # Recursively collect all .md files with their relative paths
    collectAgentFiles = dir: prefix:
      let
        entries = builtins.readDir dir;
        
        processEntry = name: type:
          let
            path = "${dir}/${name}";
            relPath = if prefix == "" then name else "${prefix}/${name}";
          in
            if type == "directory" then
              collectAgentFiles path relPath
            else if type == "regular" && lib.hasSuffix ".md" name then
              let agentName = lib.removeSuffix ".md" name;
              in [{ inherit agentName relPath; }]
            else [];
      in
        lib.flatten (lib.mapAttrsToList processEntry entries);
    
    # Get all agent files from source directory
    allAgentFiles = collectAgentFiles agentsCfg.source "";
    
    # Process each agent file
    processedAgents = builtins.listToAttrs (
      lib.filter (x: x != null) (
        map ({ agentName, relPath }: 
          let
            override = agentsCfg.overrides.${agentName} or { 
              enabled = true; 
              model = null;
              temperature = null;
            };
          in
            if override.enabled then {
              name = relPath;
              value = processAgentFile agentName relPath override;
            } else null
        ) allAgentFiles
      )
    );
    
    # Build the final agents directory
    agentsDir = pkgs.runCommand "opencode-agents" {} ''
      mkdir -p $out
      
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (relPath: file: ''
          mkdir -p $out/$(dirname "${relPath}")
          cp ${file} $out/${relPath}
        '') processedAgents
      )}
    '';
    
  in lib.mkIf cfg.enable {
    # Use the upstream module's package option
    home.packages = [ cfg.package ] ++ agentsCfg.extraPackages;
    
    home.file."${agentsCfg.installPath}".source = agentsDir;
    
    # Validation warnings for misconfigured agents
    warnings = 
      let
        configuredButMissing = lib.filter 
          (name: !(builtins.any (a: a.agentName == name) allAgentFiles))
          (lib.attrNames agentsCfg.overrides);
      in
        lib.optional (configuredButMissing != [])
          "OpenCode agents: configured overrides for non-existent agents: ${lib.concatStringsSep ", " configuredButMissing}";
    
    assertions = [
      {
        assertion = builtins.pathExists agentsCfg.source;
        message = "OpenCode agents source directory '${toString agentsCfg.source}' does not exist";
      }
    ];
  };
}
