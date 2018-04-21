class NoDataImplError extends Error {
  final Object message;

  NoDataImplError([this.message]);

  String toString() => "NoTagsDataImplError: $message";
}

class NoModelIdError extends Error {
  final Object message;

  NoModelIdError([this.message]);

  String toString() => "NoModelIdError: $message";
}
