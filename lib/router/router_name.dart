enum RouterName {
  splash('/', "splash"),
  login('/login', "login"),
  register('/register', "register"),
  home('/home', "home"),
  search('/search', "search"),
  profile('/profile', "profile"),
  postAssetPicker('/postAssetPicker', "postAssetPicker"),
  addPost('/addPost', "addPost"),
  videoCoverSelector('/videoCoverSelector', "videoCoverSelector"),
  postComment('/postComment', "postComment"),
  likedByUsers('/likedByUsers', "likedByUsers"),
  otherUserProfile('/otherUserProfile', "otherUserProfile");

  final String path;
  final String name;

  const RouterName(this.path, this.name);
}
