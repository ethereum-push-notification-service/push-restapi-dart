import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'dart:convert'; // For jsonEncode
// For SHA256 hash
import 'package:uuid/uuid.dart'; // For UUID

String getUUID() {
  var uuid = Uuid();
  return uuid.v4();
}

NotificationPayload? getPayloadForAPIInput(
    SendNotificationInputOptions inputOptions, dynamic recipients) {
  if (inputOptions.notification != null && inputOptions.payload != null) {
    return NotificationPayload(
        notification: NotificationOptions(
          title: inputOptions.notification?.title ?? '',
          body: inputOptions.notification?.body ?? '',
        ),
        data: PayloadData(
            acta: inputOptions.payload?.cta ?? '',
            aimg: inputOptions.payload?.img ?? '',
            amsg: inputOptions.payload?.body ?? '',
            asub: inputOptions.payload?.title ?? '',
            type: inputOptions.type.toString(),
            etime: inputOptions.payload?.etime,
            hidden: inputOptions.payload?.hidden,
            silent: inputOptions.payload?.silent,
            sectype: inputOptions.payload?.sectype ?? '',
            additionalMeta: inputOptions.payload?.additionalMeta),
        recipients: recipients);
  }
  return null;
}

Future<Map<String, dynamic>> getRecipients({
  required NOTIFICATION_TYPE notificationType,
  required String channel,
  required dynamic recipients,
  String? secretType,
}) async {
  String addressInCAIP = '';

  if (secretType != null) {
    String secret = '';
    // return {};
    /**
     * Currently SECRET FLOW is yet to be finalized on the backend, so will revisit this later.
     * But in secret flow, we basically generate a secret for the address
     * and send it in { 0xtarget: secret_generated_for_0xtarget } format for all
     */
    if (notificationType == NOTIFICATION_TYPE.TARGETTED) {
      if (recipients is String) {
        addressInCAIP = await getCAIPAddress(address: recipients);
        secret = ''; // do secret stuff

        return {
          addressInCAIP: secret,
        };
      }
    } else if (notificationType == NOTIFICATION_TYPE.SUBSET) {
      if (recipients is List<String>) {
        final recipientObject = <String, dynamic>{};
        for (String recipient in recipients) {
          addressInCAIP = await getCAIPAddress(address: recipient);
          secret = ''; // do secret stuff
          recipientObject[addressInCAIP] =
              secret; // Use square brackets to access the map keys
        }
        return recipientObject;
      }
    }
  } else {
    /**
     * NON-SECRET FLOW
     */

    if (notificationType == NOTIFICATION_TYPE.BROADCAST) {
      return {
        await getCAIPAddress(address: channel): null,
      };
    } else if (notificationType == NOTIFICATION_TYPE.TARGETTED) {
      if (recipients is String) {
        return {
          await getCAIPAddress(address: recipients): null,
        };
      }
    } else if (notificationType == NOTIFICATION_TYPE.SUBSET) {
      if (recipients is List<String>) {
        final recipientObject = <String, dynamic>{};
        for (String recipient in recipients) {
          addressInCAIP = await getCAIPAddress(address: recipient);
          recipientObject[addressInCAIP] =
              null; // Use square brackets to access the map keys
        }
        return recipientObject;
      }
    }
  }
  return recipients;
}

Future<String> getRecipientFieldForAPIPayload({
  required NOTIFICATION_TYPE notificationType,
  required dynamic recipients,
  required String channel,
}) async {
  if (notificationType == NOTIFICATION_TYPE.TARGETTED && recipients is String) {
    return await getCAIPAddress(address: recipients);
  }
  return await getCAIPAddress(address: channel);
}

Future<String> getVerificationProof({
  required int senderType,
  required dynamic signer,
  required int chainId,
  required NOTIFICATION_TYPE notificationType,
  required IDENTITY_TYPE identityType,
  required String verifyingContract,
  required NotificationPayload? payload,
  String? ipfsHash,
  Map<String, dynamic> graph = const {},
  required String uuid,
  String? chatId,
  dynamic wallet,
  String? pgpPrivateKey,
  String? pgpPublicKey,
}) async {
  Map<String, String>? message;
  String? verificationProof;

  switch (identityType) {
    case IDENTITY_TYPE.MINIMAL:
      {
        message = {
          'data':
              '$identityType+$notificationType+${payload?.notification.title}+${payload?.notification.body}'
        };
        break;
      }
    case IDENTITY_TYPE.IPFS:
      {
        message = {'data': '1+$ipfsHash'};
        break;
      }
    case IDENTITY_TYPE.DIRECT_PAYLOAD:
      {
        final payloadJSON = jsonEncode(payload?.toJson());
        message = {'data': '2+$payloadJSON'};
        break;
      }
    case IDENTITY_TYPE.SUBGRAPH:
      {
        message = {'data': '3+graph:${graph['id']}+${graph['counter']}'};
        break;
      }
    default:
      {
        throw Exception('Invalid IdentityType');
      }
  }

  switch (senderType) {
    case 0:
      {
        final type = {
          'Data': [
            {'name': 'data', 'type': 'string'}
          ]
        };
        final domain = {
          'name': 'EPNS COMM V1',
          'chainId': chainId,
          'verifyingContract': verifyingContract,
        };
        final signature = await signer._signTypedData(domain, type, message);
        verificationProof = 'eip712v2:$signature::uid::$uuid';
        break;
      }
    case 1:
      {
        final hash = generateHash(message);
        final signature = await sign(
          message: hash,
          privateKey: pgpPrivateKey as String,
        );
        verificationProof = 'pgpv2:$signature:meta:$chatId::uid::$uuid';
        break;
      }
    default:
      {
        throw Exception('Invalid SenderType');
      }
  }
  return verificationProof;
}

String getPayloadIdentity({
  required IDENTITY_TYPE identityType,
  required NotificationPayload? payload,
  NOTIFICATION_TYPE? notificationType,
  String? ipfsHash,
  Graph? graph,
}) {
  if (identityType == IDENTITY_TYPE.MINIMAL) {
    return '0+$notificationType+${payload?.notification.title}+${payload?.notification.body}';
  } else if (identityType == IDENTITY_TYPE.IPFS) {
    return '1+$ipfsHash';
  } else if (identityType == IDENTITY_TYPE.DIRECT_PAYLOAD) {
    final payloadJSON = jsonEncode(payload);
    return '2+$payloadJSON';
  } else if (identityType == IDENTITY_TYPE.SUBGRAPH) {
    final graphId = graph?.id;
    final graphCounter = graph?.counter;
    return '3+graph:$graphId+$graphCounter';
  }
  throw Exception('Invalid identityType!');
}

String getSource(int chainId, IDENTITY_TYPE identityType, int senderType) {
  if (senderType == 1) {
    return SOURCE_TYPES.PUSH_VIDEO;
  }
  if (identityType == IDENTITY_TYPE.SUBGRAPH) {
    return SOURCE_TYPES.THE_GRAPH;
  }
  return CHAIN_ID_TO_SOURCE.CHAIN[chainId] ?? CHAIN_ID_TO_SOURCE.DEFAULT_SOURCE;
}

String getCAIPFormat(int chainId, String address) {
  // EVM based chains
  if ([1, 5, 42, 137, 80001, 56, 97, 10, 420, 1442, 1101].contains(chainId)) {
    return 'eip155:$chainId:$address';
  }
  return address;
}
