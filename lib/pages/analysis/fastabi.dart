/*Future<void> analyze() async {
  if (selectedFile == null) return;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://127.0.0.1:8000/predict'),
  );

  request.files.add(
    await http.MultipartFile.fromPath('file', selectedFile!.path),
  );

  var response = await request.send();

  if (response.statusCode == 200) {
    print('Success');
  } else {
    print('Error');
  }
}*/