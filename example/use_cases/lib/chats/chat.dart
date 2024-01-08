import 'dart:math';

import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'package:unique_names_generator/unique_names_generator.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../models/signer.dart';

void log(Object? object) {
  // ignore: avoid_print
  print(object);
}

Future delay(int miliseconds) async {
  await Future.delayed(Duration(milliseconds: miliseconds));
}

// Dummy Wallet Addresses and signers
var random = Random.secure();

final randomWallet1 = web3.EthPrivateKey.createRandom(random);
final randomWallet2 = web3.EthPrivateKey.createRandom(random);
final randomWallet3 = web3.EthPrivateKey.createRandom(random);

final wallet1Signer = Web3Signer(randomWallet1);
final wallet2Signer = Web3Signer(randomWallet2);
final wallet3Signer = Web3Signer(randomWallet3);

/// *************** SAMPLE GROUP DATA ***************************
const groupImage =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAvklEQVR4AcXBsW2FMBiF0Y8r3GQb6jeBxRauYRpo4yGQkMd4A7kg7Z/GUfSKe8703fKDkTATZsJsrr0RlZSJ9r4RLayMvLmJjnQS1d6IhJkwE2bT13U/DBzp5BN73xgRZsJMmM1HOolqb/yWiWpvjJSUiRZWopIykTATZsJs5g+1N6KSMiO1N/5DmAkzYTa9Lh6MhJkwE2ZzSZlo7xvRwson3txERzqJhJkwE2bT6+JhoKTMJ2pvjAgzYSbMfgDlXixqjH6gRgAAAABJRU5ErkJggg==';

String groupName() {
  final generator = UniqueNamesGenerator(
    config: Config(dictionaries: [names, animals, colors]),
  );
  return generator.generate().replaceAll('_', ' ');
}

String groupDescription() {
  final generator = UniqueNamesGenerator(
    config: Config(dictionaries: [names, animals, colors]),
  );
  return generator.generate().replaceAll('_', ' ');
}

/// *************** SAMPLE GROUP DATA ***************************

Future runChatClassUseCases() async {
  final userAlice = await PushAPI.initialize(
    signer: wallet1Signer,
    options: PushAPIInitializeOptions(showHttpLog: true),
  );
  final userBob = await PushAPI.initialize(
    signer: wallet2Signer,
    options: PushAPIInitializeOptions(showHttpLog: true),
  );
  final userKate = await PushAPI.initialize(
    signer: wallet3Signer,
    options: PushAPIInitializeOptions(showHttpLog: true),
  );

  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.list');
  final aliceChats = await userAlice.chat.list(type: ChatListType.CHATS);
  log('PushAPI.chat.list: $aliceChats | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.latest');
  final aliceLatestChatWithBob =
      await userAlice.chat.latest(target: wallet2Signer.getAddress());
  log(aliceLatestChatWithBob);
  log('PushAPI.chat.latest | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.history');
  final aliceChatHistoryWithBob =
      await userAlice.chat.history(target: wallet2Signer.getAddress());

  log(aliceChatHistoryWithBob);
  log('PushAPI.chat.history | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.send');
  final aliceMessagesBob = await userAlice.chat.send(
      recipient: wallet2Signer.getAddress(),
      options: SendMessage(
        content: 'Hello Bob!',
        type: MessageType.TEXT,
      ));
  log(aliceMessagesBob);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.chat.send | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.accept');
  final bobAcceptsRequest =
      await userBob.chat.accept(target: wallet1Signer.getAddress());
  log(bobAcceptsRequest);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.chat.accept | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.reject');
  await userKate.chat.send(
    recipient: wallet1Signer.getAddress(),
    options: SendMessage(
      content: 'Sending malicious message',
      type: MessageType.TEXT,
    ),
  );
  final aliceRejectsRequest =
      await userAlice.chat.reject(target: wallet3Signer.getAddress());
  log(aliceRejectsRequest);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.chat.reject | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.block');
  final aliceBlocksBob =
      await userAlice.chat.block(users: [wallet2Signer.getAddress()]);

  log(aliceBlocksBob);
  log('PushAPI.chat.block | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.chat.unblock');
  final aliceUnblocksBob =
      await userAlice.chat.unblock(users: [wallet2Signer.getAddress()]);

  log(aliceUnblocksBob);
  log('PushAPI.chat.unblock | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.create');
  final createdGroup = await userAlice.chat.group.create(
      name: groupName(),
      options: GroupCreationOptions(
        description: groupDescription(),
        image: groupImage,
        members: [
          wallet2Signer.getAddress(),
          wallet3Signer.getAddress(),
        ],
        admins: [],
        private: false,
      ));
  final groupChatId = createdGroup?.chatId; // to be used in other examples

  log(createdGroup);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.create | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.permissions');
  final grouppermissions =
      await userAlice.chat.group.permissions(chatId: groupChatId!);

  log(grouppermissions);
  log('PushAPI.group.permissions | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.info');
  final groupInfo = await userAlice.chat.group.info(chatId: groupChatId);

  log(groupInfo);
  log('PushAPI.group.info | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.update');
  final updatedGroup = await userAlice.chat.group.update(
    chatId: groupChatId,
    options: GroupUpdateOptions(
      description: 'Updated Description',
    ),
  );
  log(updatedGroup);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.update | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.add');
  final addMember = await userAlice.chat.group.add(
    chatId: groupChatId,
    role: 'MEMBER',
    accounts: [wallet3Signer.getAddress()],
  );
  log(addMember);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.add | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.remove');
  final removeMember = await userAlice.chat.group.remove(
    chatId: groupChatId,
    role: 'MEMBER',
    accounts: [wallet3Signer.getAddress()],
  );
  log(removeMember);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.remove | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.join');
  final joinGrp = await userBob.chat.group.join(target: groupChatId);

  log(joinGrp);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.join | Response - 200 OK\n\n');
  //-------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.leave');
  final leaveGrp = await userBob.chat.group.leave(target: groupChatId);

  log(leaveGrp);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.leave | Response - 200 OK\n\n');
  // -------------------------------------------------------------------
  // -------------------------------------------------------------------
  log('PushAPI.group.reject');
  final sampleGrp = await userAlice.chat.group.create(
      name: 'Sample Grp',
      options: GroupCreationOptions(
        description: groupDescription(),
        image: groupImage,
        members: [wallet2Signer.getAddress()], // invite bob
        admins: [],
        private: true,
      ));
  await userBob.chat.group.reject(target: sampleGrp!.chatId);
  await delay(2000); // Delay added to log the events in order
  log('PushAPI.group.reject | Response - 200 OK\n\n');
}
