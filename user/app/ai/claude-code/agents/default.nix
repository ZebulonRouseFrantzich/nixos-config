let
  fullstack-developer = import ./fullstack-developer.nix;
  flutter-expert = import ./flutter-expert.nix;
in
{
  fullstack-developer = fullstack-developer.agentInfo;
  flutter-expert = flutter-expert.agentInfo;
}
