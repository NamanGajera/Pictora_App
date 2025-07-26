enum RouterName {
  splash('/', "splash"),
  login('/login', "login");

  final String path;
  final String name;

  const RouterName(this.path, this.name);
}
