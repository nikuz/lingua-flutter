final RegExp base64ImageReg = RegExp(r'^data:image/(jpeg|png|jpg);base64,(.+)$');
final RegExp uriStartReg = RegExp(r'https?://[-a-zA-Z\d]{1,256}');
final RegExp uriReg = RegExp(r'[-a-zA-Z\d]{1,256}\.[a-zA-Z]{1,6}');