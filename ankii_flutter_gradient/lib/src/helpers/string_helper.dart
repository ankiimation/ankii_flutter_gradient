extension StringHelper on String {
  String withOutHtmlTag() {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return this.replaceAll(exp, '');
  }
}

