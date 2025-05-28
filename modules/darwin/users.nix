_:

{
  config = {
    users.users."dom.egginton" = {
      name = "dom.egginton";
      home = "/Users/dom.egginton";
    };
    home-manager.users."dom.egginton" = _: {
      imports = [ ../../home/dom ];
    };
  };
}
