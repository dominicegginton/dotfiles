{ pkgs
, ...
}:

{
  config = {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host i-* mi-*
          User ec2-user
          ProxyCommand sh -c "${pkgs.awscli}/bin/aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
      '';
    };
  };
}
