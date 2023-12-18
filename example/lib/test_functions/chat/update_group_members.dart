import 'package:push_restapi_dart/push_restapi_dart.dart';

void testUpdateGroupMembers() async {
  final result = await updateGroupMembers(
      chatId:
          'a279ff975a104e8b04806bee18edc2c489b619663d6b192cbb07b4bbfd616e45',
      upsert:
          UpsertDTO(admins: ['0x29b8276AA5bc432e03745eF275ded9074faB5970']));

  print(result);
}
