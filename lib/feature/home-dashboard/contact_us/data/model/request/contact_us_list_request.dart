class ContactUsListRequest {
  final int page;
  final int rowsPerPage;

  ContactUsListRequest({required this.page, required this.rowsPerPage});

  Map<String, dynamic> toJson() => {
        'page': page,
        'rowsPerPage': rowsPerPage,
      };
}
