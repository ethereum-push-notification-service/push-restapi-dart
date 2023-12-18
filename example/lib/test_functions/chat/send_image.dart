import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ethers;

Future<void> testSendImage() async {
  final ethersWallet = ethers.Wallet.fromMnemonic(
      'label mobile gas salt service gravity nose bomb marine online say twice');

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  final user = await getUser(address: ethersWallet.address!);

  if (user == null) {
    print('Cannot get user');
    return;
  }

  String? pgpPrivateKey = null;
  if (user.encryptedPrivateKey != null) {
    pgpPrivateKey = await decryptPGPKey(
      encryptedPGPPrivateKey: user.encryptedPrivateKey!,
      wallet: getWallet(signer: signer),
    );
  }

  final options = ChatSendOptions(
    account: ethersWallet.address,
    pgpPrivateKey: pgpPrivateKey,
    message: ImageMessage(
      name: "something.png",
      content:
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARMAAAC3CAMAAAAGjUrGAAAAjVBMVEX///+8AC27ACq6ACC6ACK7ACe6AB65ABu+AC+8ACi7ACX88/W3AAC4ABP77/K5ABf23eTy0NfwytLrwcjimqnXdInLVmjFQFTBI0G/CTTtvcjclKC4AA756OzPU23XeYvEMUvKSWHTaX6/FDjosLvZgZHFNE/z1dzlqLTQYHXKQV7orLrWfIrPVm/nvMFRtU1mAAADLklEQVR42u3d2XKjMBCFYbcQBuQFEydesGNDvGT3+z/eXEzNzaCpyQJKNf6/RziFpHZby2AAAAAAAAAAAAAAAAAAAAAGg8FoVtzM55fLZT6/KWaja09jWtzeLZardZrZJE9slq5Xy8XdbTG90mRG5Wax3iaRy4wx8psxJnNRsl0vNuXVxXJ/2eXDofuTxd+MGw7z3eX+ihIp9tXQyf+4YbUvriSRst5GRj7CRNu6vIZZpLJOPs7Zqu8zS1knsXxOnPT6W5k9jJ18nhs/zPo6bDaHSL4mOmx6OYDudxMjX2Umux4uzEdr5TusPfZt3Jyske8x9tSr8TOqE/m+pO5RKLMqkjZEVW/Wn+JspR323JNi/9E5aYtzj734StaZtCdbF32YS5y0yemfU6YrK+2yq6nySHaRtC3a6Q5ln0j7kr3mSJ66iEQkeVI8v4rpJBMjaufZUW2lG1ZtlX/KpSv5SenIiU1nmZhY5+h5ttId+6yyiTSRLk0Utpim57jTTOKzvsrtaSjdGuorUlLTcSYmZTZRP6OMlnHnmcRLXYXbPJfu5XNqE901yuxgAmRiDpqK2c4XYoXL8YsLkol7UVTDjiWMsZ5a9jUPlEn+qiaTtyhQJtGbmqFTx4EyiWstg2eWmkCZmFTLalxOJJSJlu1/pyhYJpGWvuy7C5aJe1eSSWWCZWIqJX2CQ8BMDjr6BUUaMJNUx3aUMpNwMh0LT+kCZuJ0ZHK0ATNRspP4GAXMJNKRSaCGkqq2UkcbcVRvz+E7YT5h3aE+oY7l9w6/i+mf0GejH6uyH0vfnv93PoL/AT34v7iJfQWewcP+kyb2Kf1YW0nVfjb2PXqwP7aJfdSefgH77T1NWc5lNHF+5weWY4XnvDgPGH5Gmai8mozzxZ5ilnPonr4s9xU0CzfutfCMHu4/8RQp3JPTxH1KnsqNe7c8oXA/m2ee5R6/Ju579OBeUN+Xwv2xvjmFe4Y9VT73UTdD4d5yX4uJ++2beAfBN354L8O3/vCuigfv7/gGEO80+b8V3vPyFPu8++ZbmHkf0D+z8I6kLxbeG/1XMrxLCwAAAAAAAAAAAAAAAABA0y/RclUO6yXgjgAAAABJRU5ErkJggg==",
    ),
    to: '83e6aaf9fb44c5929ea965d2b0c4e98fd8b6094b72f51989123f81e6cf69f298',
  );

  final result = await send(options);

  print('testSend result = $result');
}
