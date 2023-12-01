// ignore_for_file: constant_identifier_names, camel_case_types

class ENCRYPTION_TYPE {
  static const PGP_V1 = 'x25519-xsalsa20-poly1305';
  static const PGP_V2 = 'aes256GcmHkdfSha256';
  static const PGP_V3 = 'eip191-aes256-gcm-hkdf-sha256';
  static const NFTPGP_V1 = 'pgpv1:nft';

  static isValidEncryptionType(String type) {
    return [PGP_V1, PGP_V2, PGP_V3, NFTPGP_V1].contains(type);
  }
}

class Pagination {
  static const INITIAL_PAGE = 1;
  static const LIMIT = 10;
  static const LIMIT_MIN = 1;
  static const LIMIT_MAX = 50;
}

class Constants {
  static const Map<String, dynamic> PAGINATION = {
    'INITIAL_PAGE': 1,
    'LIMIT': 10,
    'LIMIT_MIN': 1,
    'LIMIT_MAX': 50,
  };
  
  static const int DEFAULT_CHAIN_ID = 5;
  static const int DEV_CHAIN_ID = 99999;
  static const List<int> NON_ETH_CHAINS = [
    137,
    80001,
    56,
    97,
    10,
    420,
    1442,
    1101
  ];
  static const List<int> ETH_CHAINS = [1, 5];
  static const String ENC_TYPE_V1 = 'x25519-xsalsa20-poly1305';
  static const String ENC_TYPE_V2 = 'aes256GcmHkdfSha256';
  static const String ENC_TYPE_V3 = 'eip191-aes256-gcm-hkdf-sha256';
  static const String ENC_TYPE_V4 = 'pgpv1:nft';
}

class MessageType {
  static const TEXT = 'Text';
  static const VIDEO = 'Video';
  static const AUDIO = 'Audio';
  static const IMAGE = 'Image';
  static const FILE = 'File';
  static const MEDIA_EMBED = 'MediaEmbed';
  static const META = 'Meta';
  static const REACTION = 'Reaction';
  static const COMPOSITE = 'Composite';
  static const REPLY = 'Reply';
  static const RECEIPT = 'Receipt';
  static const USER_ACTIVITY = 'UserActivity';
  static const INTENT = 'Intent';
  static const PAYMENT = 'Payment';

  /// @deprecated - Use MediaEmbed Instead
  static const GIF = 'GIF';

  static isValidMessageType(String type) {
    return [
      TEXT,
      VIDEO,
      AUDIO,
      IMAGE,
      FILE,
      MEDIA_EMBED,
      META,
      REACTION,
      COMPOSITE,
      REPLY,
      USER_ACTIVITY,
      PAYMENT,
      INTENT,
      RECEIPT
    ].contains(type);
  }
}

class CHAT {
  static const String META_GROUP_CREATE = 'CREATE_GROUP';
  static const String META_GROUP_MEMBER_ADD = 'ADD_MEMBER';
  static const String META_GROUP_MEMBER_REMOVE = 'REMOVE_MEMBER';
  static const String META_GROUP_MEMBER_PRIVILEGE = 'ASSIGN_MEMBER_PRIVILEGE';
  static const String META_GROUP_ADMIN_PRIVILEGE = 'ASSIGN_ADMIN_PRIVILEGE';
  static const String META_GROUP_UPDATE_GROUP = 'UPDATE_GROUP';
  static const String META_GROUP_PROFILE_UPDATE = 'UPDATE_GROUP_PROFILE';
  static const String META_GROUP_META_UPDATE = 'UPDATE_GROUP_META';
  static const String META_GROUP_USER_INTERACTION = 'USER_INTERACTION';
  static const String META_SPACE_CREATE = 'CREATE_SPACE';
  static const String META_SPACE_START = 'START_SPACE';
  static const String META_SPACE_END = 'END_SPACE';
  static const String META_SPACE_LISTENER_ADD = 'ADD_LISTENER';
  static const String META_SPACE_LISTENER_REMOVE = 'REMOVE_LISTENER';
  static const String META_SPACE_LISTENER_PRIVILEGE =
      'ASSIGN_LISTENER_PRIVILEGE';
  static const String META_SPACE_LISTENER_PROMOTION_ACCEPT =
      'LISTENER_PROMOTION_ACCEPT';
  static const String META_SPACE_LISTENER_PROMOTION_REJECT =
      'LISTENER_PROMOTION_REJECT';
  static const String META_SPACE_COHOST_PRIVILEGE = 'ASSIGN_COHOST_PRIVILEGE';
  static const String REACTION_THUMBSUP = '\u{1F44D}';
  static const String REACTION_THUMBSDOWN = '\u{1F44E}';
  static const String REACTION_HEART = '\u{2764}\u{FE0F}';
  static const String REACTION_CLAP = '\u{1F44F}';
  static const String REACTION_LAUGH = '\u{1F602}';
  static const String REACTION_SAD = '\u{1F622}';
  static const String REACTION_ANGRY = '\u{1F621}';
  static const String REACTION_SURPRISE = '\u{1F632}';
  static const String REACTION_FIRE = '\u{1F525}';
  static const String RECEIPT_READ = 'READ_RECEIPT';
  static const String UA_LISTENER_JOIN = 'LISTENER_JOIN';
  static const String UA_LISTENER_LEAVE = 'LISTENER_LEAVE';
  static const String UA_LISTENER_REQUEST_MIC = 'LISTENER_REQUEST_MIC';
  static const String UA_SPEAKER_JOIN = 'SPEAKER_JOIN';
  static const String UA_SPEAKER_LEAVE = 'SPEAKER_LEAVE';
  static const String UA_SPEAKER_MIC_ON = 'SPEAKER_MIC_ON';
  static const String UA_SPEAKER_MIC_OFF = 'SPEAKER_MIC_OFF';
  static const String INTENT_ACCEPT = 'ACCEPT_INTENT';
  static const String INTENT_REJECT = 'REJECT_INTENT';
  static const String INTENT_JOIN_GROUP = 'JOIN_GROUP';
  static const String INTENT_LEAVE_GROUP = 'LEAVE_GROUP';
}

class AdditionalMetaType {
  static const CUSTOM = 0;
  static const PUSH_VIDEO = 1;

  static isValidAdditionalMetaType(int type) {
    return [CUSTOM, PUSH_VIDEO].contains(type);
  }
}
