// ignore_for_file: constant_identifier_names, camel_case_types, non_constant_identifier_names

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
  static const IMAGE = 'Image';
  static const FILE = 'File';
  static const MEDIA_EMBED = 'MediaEmbed';
  static const META = 'Meta';

  /// @deprecated - Use MediaEmbed Instead
  static const GIF = 'GIF';

  static isValidMessageType(String type) {
    return [TEXT, IMAGE, FILE, MEDIA_EMBED, META].contains(type);
  }
}

class AdditionalMetaType {
  static const CUSTOM = 0;
  static const PUSH_VIDEO = 1;

    static isValidAdditionalMetaType(int type) {
    return [CUSTOM, PUSH_VIDEO].contains(type);
  }
}
