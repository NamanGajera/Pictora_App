part of 'post_bloc.dart';

class PostState extends Equatable {
  final ApiStatus createPostApiStatus;
  final ApiStatus getAllPostApiStatus;
  final List<PostData>? allPostData;
  final int? statusCode;
  final String? errorMessage;

  const PostState({
    this.createPostApiStatus = ApiStatus.initial,
    this.getAllPostApiStatus = ApiStatus.initial,
    this.allPostData,
    this.errorMessage,
    this.statusCode,
  });

  PostState copyWith({
    ApiStatus? createPostApiStatus,
    ApiStatus? getAllPostApiStatus,
    List<PostData>? allPostData,
    int? statusCode,
    String? errorMessage,
  }) {
    return PostState(
      createPostApiStatus: createPostApiStatus ?? this.createPostApiStatus,
      getAllPostApiStatus: getAllPostApiStatus ?? this.getAllPostApiStatus,
      allPostData: allPostData ?? this.allPostData,
      errorMessage: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [
        createPostApiStatus,
        getAllPostApiStatus,
        allPostData,
        errorMessage,
        statusCode,
      ];
}
