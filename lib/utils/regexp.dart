final RegExp base64ImageReg = RegExp(r'^data:image/(jpeg|png|jpg);base64,(.+)$');
final RegExp uriStartReg = RegExp(r'https?://[-a-zA-Z\d]{1,256}');
final RegExp uriReg = RegExp(r'[-a-zA-Z\d]{1,256}\.[a-zA-Z]{1,6}');
const String htmlTagParamReg = '{param}=["|\']([^\'"]+)[\'|"]';
final RegExp htmlTagActionReg = RegExp(htmlTagParamReg.replaceFirst('{param}', 'action'));
final RegExp htmlTagNameReg = RegExp(htmlTagParamReg.replaceFirst('{param}', 'name'));
final RegExp htmlTagValueReg = RegExp(htmlTagParamReg.replaceFirst('{param}', 'value'));