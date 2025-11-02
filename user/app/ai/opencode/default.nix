{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;
  
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
  
  # Process a single agent file
  processAgentFile = agentName: relPath: overrideConfig:
    let
      sourcePath = cfg.agentsSource + "/" + relPath;
      hasOverrides = overrideConfig.model != null || overrideConfig.temperature != null;
    in
      if !overrideConfig.enabled then
        null
      else if !hasOverrides then
        sourcePath
      else
        pkgs.runCommand "agent-${agentName}.md" {
          buildInputs = [ pkgs.yq-go ];
        } ''
          cp ${sourcePath} $out
          
          ${lib.optionalString (overrideConfig.model != null) ''
            ${pkgs.yq-go}/bin/yq eval --front-matter=process \
              '.model = "${overrideConfig.model}"' \
              -i $out
          ''}
          
          ${lib.optionalString (overrideConfig.temperature != null) ''
            ${pkgs.yq-go}/bin/yq eval --front-matter=process \
              '.temperature = ${toString overrideConfig.temperature}' \
              -i $out
          ''}
        '';
  
  # Recursively collect all .md files with their relative paths
  collectAgentFiles = dir: prefix:
    let
      entries = builtins.readDir dir;
      
      processEntry = name: type:
        let
          path = dir + "/${name}";
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
  allAgentFiles = collectAgentFiles cfg.agentsSource "";
  
  # Process each agent file
  processedAgents = builtins.listToAttrs (
    lib.filter (x: x != null) (
      map ({ agentName, relPath }: 
        let
          override = cfg.agentOverrides.${agentName} or { enabled = true; };
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

in {
  options.programs.opencode = {
    enable = lib.mkEnableOption "OpenCode with custom agent configuration";
    
    agentsSource = lib.mkOption {
      type = lib.types.path;
      default = ./agents;  # ADD THIS DEFAULT
      description = "Path to directory containing agent .md files";
      example = lib.literalExpression "./agents";
    };
    
    agentOverrides = lib.mkOption {
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
      description = "Extra packages to include with opencode";
    };
  };
  
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.opencode ] ++ cfg.extraPackages;
    
    home.file."${config.xdg.configHome}/opencode/agent".source = agentsDir;
    
    # Validation warnings
    warnings = 
      let
        configuredButMissing = lib.filter 
          (name: !(builtins.any (a: a.agentName == name) allAgentFiles))
          (lib.attrNames cfg.agentOverrides);
      in
        lib.optional (configuredButMissing != [])
          "OpenCode: configured overrides for non-existent agents: ${lib.concatStringsSep ", " configuredButMissing}";
  };
}
