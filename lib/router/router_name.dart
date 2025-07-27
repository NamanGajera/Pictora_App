enum RouterName {
  splash('/', "splash"),
  login('/login', "login"),
  register('/register', "register"),
  home('/home', "home"),
  search('/search', "search"),
  addPost('/addPost', "addPost"),
  profile('/profile', "profile");

  final String path;
  final String name;

  const RouterName(this.path, this.name);
}
